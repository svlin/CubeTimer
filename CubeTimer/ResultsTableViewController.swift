//
//  ResultsTableViewController.swift
//  CubeTimer
//
//  Created by Sophia Lin on 11/3/16.
//  Copyright © 2016 Sophia Lin. All rights reserved.
//

import UIKit
import CoreData

class ResultsTableViewController: UITableViewController {
    
    // Array of times in core data
    var results = [NSManagedObject]()
    var currentSession = ""

    // Add the Clear button to let the user clear/delete all rows in the Results table
    @IBAction func clearAction(sender: AnyObject) {
        let alertController = UIAlertController(title: "Clear Results", message: "Are you sure you want to clear all your results?", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action:UIAlertAction!) in
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            
            // Clear the results for the current session
            let fetchRequest = NSFetchRequest(entityName: "Results")
            fetchRequest.includesPropertyValues = false
            do {
                let items = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
                for item in items {
                    let sessionNumber = item.valueForKey("sessionNumber") as? String
                    if sessionNumber == self.currentSession {
                        managedContext.deleteObject(item)
                    }
                }
                self.results.removeAll()
                try managedContext.save()
                self.tableView.reloadData()
            } catch {
                // Error Handling
            }
        }
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true, completion:nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ttbc = self.tabBarController as! TimesTabBarController
        results = ttbc.results
        
        // Gets the current session
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchResults = NSFetchRequest(entityName: "Session")
        do {
            let fetchedResults = try managedContext.executeFetchRequest(fetchResults) as! [NSManagedObject]
            if fetchedResults.count > 0 {
                let result = fetchedResults[0]
                let fetchedSession = result.valueForKey("currentSession") as? String
                currentSession = fetchedSession!
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        
        // Updates the session times according to the current session
        let fetchRequest = NSFetchRequest(entityName: "Results")
        results.removeAll()
        do {
            let items = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            for item in items {
                let sessionNumber = item.valueForKey("sessionNumber") as? String
                if sessionNumber == currentSession {
                    results.append(item)
                }
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    // Add the function to swipe left on a row to delete it from the table
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let result_time = results[indexPath.row]
            let scramble = result_time.valueForKey("scramble") as? String
            let time = result_time.valueForKey("time") as? Double
            confirmDelete(scramble!, resultToDelete: String(time!), time: time!, index: indexPath.row)
        }
    }
    
    // Delete a result in the table
    func confirmDelete(scramble: String, var resultToDelete: String, time: Double, index: Int) {
        if Double(resultToDelete) == -1.0 {
            resultToDelete = "DNF"
        } else {
            resultToDelete += "s"
        }
        let alertController = UIAlertController(title: "Delete a result", message: "Are you sure you want to delete this solve of \(resultToDelete)?", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action:UIAlertAction!) in
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
            let appDel  = UIApplication.sharedApplication().delegate as! AppDelegate
            let context = appDel.managedObjectContext
            let fetchResults = NSFetchRequest(entityName: "Results")
            
            do {
                let fetchedResults = try context.executeFetchRequest(fetchResults) as! [NSManagedObject]
                for result in fetchedResults {
                    let fetchedScramble = result.valueForKey("scramble") as? String
                    if fetchedScramble == scramble {
                        context.deleteObject(result)
                    }
                }
                try context.save()
                self.results.removeAtIndex(index)
                self.tableView.reloadData()
            } catch let error as NSError {
                print("Fetch failed: \(error.localizedDescription)")
            }
        }
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true, completion:nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Gets the current session
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchResults = NSFetchRequest(entityName: "Session")
        do {
            let fetchedResults = try managedContext.executeFetchRequest(fetchResults) as! [NSManagedObject]
            if fetchedResults.count > 0 {
                let result = fetchedResults[0]
                let fetchedSession = result.valueForKey("currentSession") as? String
                currentSession = fetchedSession!
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
        
        // Updates the session times according to the current session
        let fetchRequest = NSFetchRequest(entityName: "Results")
        results.removeAll()
        do {
            let items = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            for item in items {
                let sessionNumber = item.valueForKey("sessionNumber") as? String
                if sessionNumber == currentSession {
                    results.append(item)
                }
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TimeCell", forIndexPath: indexPath)
        
        let result_time = results[indexPath.row]
        let time = result_time.valueForKey("time") as? Double
        if (time == -1.0) {
            cell.textLabel?.text = String(indexPath.row + 1) + ".    " + "DNF"
        } else {
            cell.textLabel?.text = String(indexPath.row + 1) + ".    " + String(time!) + "s"
        }
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "SendDataSegue" {
            if let destination = segue.destinationViewController as? IndivResultsTableViewController {
                if let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell) {
                    let result_time = results[indexPath.row]
                    let puzzle = result_time.valueForKey("puzzle") as? String
                    let scramble = result_time.valueForKey("scramble") as? String
                    let time = result_time.valueForKey("time") as? Double
                    destination.scrambleViaSegue = scramble!
                    destination.puzzleViaSegue = puzzle!
                    destination.indexViaSegue = indexPath.row
                    destination.timeViaSegue = String(time!)
                }
            }
        }
    }

}