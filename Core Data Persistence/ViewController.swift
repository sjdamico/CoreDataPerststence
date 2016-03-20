//
//  ViewController.swift
//  Core Data Persistence
//
//  Created by Steve D'Amico on 3/18/16.
//  Copyright © 2016 Steve D'Amico. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    private static let lineEntityName = "Line"
    private static let lineNumberKey = "lineNumber"
    private static let lineTextKey = "lineText"
    @IBOutlet var lineFields:[UITextField]!

    override func viewDidLoad() {
        super.viewDidLoad()
        /* Do any additional setup after loading the view, typically from a nib.
        Check whether there is any existing data */
        
        // Get the managed object context
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        // Create a fetch request and pass it the entity name
        let request = NSFetchRequest(entityName: ViewController.lineEntityName)
        
        do {
            // do - catch block for logging any error
            let objects = try context.executeFetchRequest(request)
            
            // Give us evey Line object in the store and update the text fields
            for object in objects {
                let lineNum = object.valueForKey(ViewController.lineNumberKey)!.integerValue
                let lineText = object.valueForKey(ViewController.lineTextKey) as? String ?? ""
                let textField = lineFields[lineNum]
                textField.text = lineText
            }
            // Register to be notified when the application is about to move out of the active state
            let app = UIApplication.sharedApplication()
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillResignActive:", name: UIApplicationWillResignActiveNotification, object: app)
        } catch {
            // Error thrown from executeFetchRequest()
            print("There was an error in executeFetchRequest(): \(error)")
        }
    }
    
    func applicationWillResignActive(notification:NSNotification) {
        
        // Get a reference to the application delegate and use this as a pointer to the application's default managed object context
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDelegate.managedObjectContext
        
        // Loop executes once for each text field and gets a reference to the correct field
        for var i = 0; i < lineFields.count; i++ {
            let textField = lineFields[i]
            
            /* Create fetch request for the Line entry with a predicate that identifies the correct object for the field by using the index of the text field as the record key. */
            let request = NSFetchRequest(entityName: ViewController.lineEntityName)
            let pred = NSPredicate(format: "%K = %d", ViewController.lineNumberKey, i)
            request.predicate = pred
            
            do {
                // Execute the fetch request against the context,
                // do - catch block reports any error reported by the Core Data
                let objects = try context.executeFetchRequest(request)
                
                // Declare a variable called the Line of type NSManagedObject (optional, is there data?)
                var theLine:NSManagedObject! = objects.first as? NSManagedObject
                if theLine == nil {
                    theLine = NSEntityDescription.insertNewObjectForEntityForName(ViewController.lineEntityName, inManagedObjectContext: context) as NSManagedObject
                }
                // Uses key-value coding to set the line number and text for the managed object
                theLine.setValue(i, forKey: ViewController.lineNumberKey)
                theLine.setValue(textField.text, forKey: ViewController.lineTextKey)
            } catch {
                print("/there was an error in executeFetchRequest(): \(error)")
            }
        }
        // Save changes
        appDelegate.saveContext()
    }
}
