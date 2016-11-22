//
//  IndivResultsTableViewController.swift
//  CubeTimer
//
//  Created by Sophia Lin on 11/16/16.
//  Copyright © 2016 Sophia Lin. All rights reserved.
//

import UIKit
import CoreData

class IndivResultsTableViewController: UITableViewController, UITextFieldDelegate {
    
    // Array of times in core data
    var results = [NSManagedObject]()
    
    var timeViaSegue = ""
    var scrambleViaSegue = ""
    var puzzleViaSegue = ""
    var indexViaSegue = 0
    
    // Update the puzzle type data in core data when the user changes it
    @IBAction func puzzleEditingChanged(sender: AnyObject) {
        let appDel  = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDel.managedObjectContext
        let fetchResults = NSFetchRequest(entityName: "Results")
        
        do {
            let fetchedResults = try context.executeFetchRequest(fetchResults) as! [NSManagedObject]
            for result in fetchedResults {
                let fetchedScramble = result.valueForKey("scramble") as? String
                if fetchedScramble == scrambleViaSegue {
                    result.setValue(puzzleTextField.text, forKey: "puzzle")
                }
            }
            try context.save()
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
    }
    // Update the time data in core data when the user changes it
    @IBAction func timeEditingChanged(sender: AnyObject) {
        let newTime = Double(timeTextField.text!)
        let appDel  = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDel.managedObjectContext
        let fetchResults = NSFetchRequest(entityName: "Results")
        
        do {
            let fetchedResults = try context.executeFetchRequest(fetchResults) as! [NSManagedObject]
            for result in fetchedResults {
                let fetchedScramble = result.valueForKey("scramble") as? String
                if fetchedScramble == scrambleViaSegue {
                    result.setValue(newTime, forKey: "time")
                }
            }
            try context.save()
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
    }
    
    // Dismiss the keyboard when pressing done
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // Allow the user to edit the field when clicking on the text field
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            timeTextField.becomeFirstResponder()
        }
        if indexPath.section == 1 && indexPath.row == 0 {
            puzzleTextField.becomeFirstResponder()
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    @IBOutlet var scrambleCell5: UITableViewCell!
    @IBOutlet var scrambleCell4: UITableViewCell!
    @IBOutlet var scrambleCell3: UITableViewCell!
    @IBOutlet var scrambleCell2: UITableViewCell!
    @IBOutlet var scrambleCell1: UITableViewCell!
    @IBOutlet var puzzleTextField: UITextField!
    @IBOutlet var timeTextField: UITextField!
    
    // Splits a string by space
    func splitStringBySpace(string: String) -> [String] {
        var result = [String]()
        let splitString = string.componentsSeparatedByString(" ")
        var count = 1
        var tempString = ""
        for split in splitString {
            if (count == 10) {
                result.append(tempString)
                tempString = ""
                count = 1
            } else {
                tempString += split + " "
                count += 1
            }
        }
        if count != 1 {
            result.append(tempString)
        }
        return result
    }
    
    // Splits a string by slash, for square-1 puzzle
    func splitStringBySlash(string: String) -> [String] {
        var result:[String] = []
        let splitString = string.componentsSeparatedByString("/")
        var count = 1
        var tempString = ""
        for split in splitString {
            if (count == 6) {
                result.append(tempString)
                tempString = ""
                count = 1
            } else {
                tempString += split + "/"
                count += 1
            }
        }
        if count != 1 {
            result.append(tempString)
        }
        return result
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ttbc = self.tabBarController as! TimesTabBarController
        results = ttbc.results
        
        if Double(timeViaSegue) == -1.0 {
            timeTextField.text = "DNF"
        } else {
            timeTextField.text = timeViaSegue
        }
        puzzleTextField.text = puzzleViaSegue
        
        let splitComponents = scrambleViaSegue.componentsSeparatedByString(" ")
        let len = splitComponents.count
        if scrambleViaSegue.characters.indexOf("/") != nil {
            let splitScramble = splitStringBySlash(scrambleViaSegue)
            scrambleCell1.textLabel?.text = splitScramble[0]
            if splitScramble.count > 1 {
                scrambleCell2.textLabel?.text = splitScramble[1]
            }
        } else if len < 10 {
            scrambleCell1.textLabel?.text = scrambleViaSegue
        } else {
            let splitScramble = splitStringBySpace(scrambleViaSegue)
            scrambleCell1.textLabel?.text = splitScramble[0]
            if splitScramble.count > 1 {
                scrambleCell2.textLabel?.text = splitScramble[1]
            }
            if splitScramble.count > 2 {
                scrambleCell3.textLabel?.text = splitScramble[2]
            }
            if splitScramble.count > 3 {
                scrambleCell4.textLabel?.text = splitScramble[3]
            }
            if splitScramble.count > 4 {
                scrambleCell5.textLabel?.text = splitScramble[4]
            }
        }
        
        self.timeTextField.delegate = self
        self.puzzleTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Results")
        
        do {
            let fetched_results = try managedContext.executeFetchRequest(fetchRequest)
            results = fetched_results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
}