//
//  TimesTabBarController.swift
//  CubeTimer
//
//  Created by Sophia Lin on 11/3/16.
//  Copyright © 2016 Sophia Lin. All rights reserved.
//

import UIKit
import CoreData

class TimesTabBarController: UITabBarController {
    
    // TimeModel object
    var myTime = TimeModel()
    
    // Array of times and settings in core data
    var results = [NSManagedObject]()
    var settings = [NSManagedObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Settings")
        
        do {
            let fetched_results = try managedContext.executeFetchRequest(fetchRequest)
            settings = fetched_results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}