//
//  SettingsViewController.swift
//  CubeTimer
//
//  Created by Sophia Lin on 11/10/16.
//  Copyright © 2016 Sophia Lin. All rights reserved.
//

import UIKit
import CoreData

class SettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // Array of times in core data
    var settings = [NSManagedObject]()
    var currentSession = ""

    @IBAction func textFieldEditingDidChange(sender: AnyObject) {
        self.updateCurrentInspectionTime(inspectionTimeField.text!)
    }
    @IBOutlet var sessionPickerView: UIPickerView!
    @IBOutlet var inspectionTimeField: UITextField!
    @IBOutlet var currentPuzzleLabel: UILabel!
    @IBOutlet var puzzlePickerView: UIPickerView!
    let pickerDataSource = ["2x2x2", "3x3x3", "4x4x4", "5x5x5", "6x6x6", "7x7x7", "Pyraminx", "Square-1", "Skewb", "Clock"]
    let sessionDataSource = ["Session 1", "Session 2", "Session 3", "Session 4", "Session 5"]

    override func viewDidLoad() {
        super.viewDidLoad()
        let ttbc = self.tabBarController as! TimesTabBarController
        settings = ttbc.settings
        
        // Do any additional setup after loading the view.
        self.puzzlePickerView.dataSource = self
        self.puzzlePickerView.delegate = self
        
        self.sessionPickerView.dataSource = self
        self.sessionPickerView.delegate = self
        
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
        
        // Update the settings
        let fetchRequest = NSFetchRequest(entityName: "Settings")
        settings.removeAll()
        do {
            let fetched_results = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            for item in fetched_results {
                let sessionNumber = item.valueForKey("sessionNumber") as? String
                if sessionNumber == currentSession {
                    settings.append(item)
                }
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }

        // Update the row of the puzzle picker
        let currentSettings = settings[0]
        let currentPuzzle = currentSettings.valueForKey("currentPuzzle") as? String
        let pickerRow = getPuzzlePickerRow(currentPuzzle!)
        puzzlePickerView.selectRow(pickerRow, inComponent: 0, animated: false)
        currentPuzzleLabel.text = "Puzzle: " + currentPuzzle!
        
        // Update the row of the session picker
        let currentRow = Int(currentSession)! - 1
        sessionPickerView.selectRow(currentRow, inComponent: 0, animated: false)
        
        // Update the inspection time field
        let currentInspectionTime = currentSettings.valueForKey("inspectionTime") as? String
        inspectionTimeField.text = currentInspectionTime
        
        self.addDoneButtonToKeyboard()
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
        
        // Update the settings
        let fetchRequest = NSFetchRequest(entityName: "Settings")
        settings.removeAll()
        do {
            let fetched_results = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            for item in fetched_results {
                let sessionNumber = item.valueForKey("sessionNumber") as? String
                if sessionNumber == currentSession {
                    settings.append(item)
                }
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        // Update the row of the puzzle picker
        let currentSettings = settings[0]
        let currentPuzzle = currentSettings.valueForKey("currentPuzzle") as? String
        let pickerRow = getPuzzlePickerRow(currentPuzzle!)
        puzzlePickerView.selectRow(pickerRow, inComponent: 0, animated: false)
        currentPuzzleLabel.text = "Puzzle: " + currentPuzzle!
        
        // Update the row of the session picker
        let currentRow = Int(currentSession)! - 1
        sessionPickerView.selectRow(currentRow, inComponent: 0, animated: false)
        
        // Update the inspection time field
        let currentInspectionTime = currentSettings.valueForKey("inspectionTime") as? String
        inspectionTimeField.text = currentInspectionTime
    }
    
    // Returns the row number of the given puzzle in the Puzzle multi-value picker
    func getPuzzlePickerRow(currentPuzzle: String) -> Int {
        if (currentPuzzle == "2x2x2") {
            return 0
        } else if (currentPuzzle == "3x3x3") {
            return 1
        } else if (currentPuzzle == "4x4x4") {
            return 2
        } else if (currentPuzzle == "5x5x5") {
            return 3
        } else if (currentPuzzle == "6x6x6") {
            return 4
        } else if (currentPuzzle == "7x7x7") {
            return 5
        } else if (currentPuzzle == "Pyraminx") {
            return 6
        } else if (currentPuzzle == "Square-1") {
            return 7
        } else if (currentPuzzle == "Skewb") {
            return 8
        } else {
            return 9
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == puzzlePickerView {
            return pickerDataSource.count
        } else {
            return sessionDataSource.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == puzzlePickerView {
            return pickerDataSource[row]
        } else {
            return sessionDataSource[row]
        }
    }
    
    // Picker view function for Puzzle and Session multi-value picker
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == puzzlePickerView {
            var newPuzzle = ""
            if (row == 0) {
                newPuzzle = "2x2x2"
            } else if(row == 1) {
                newPuzzle = "3x3x3"
            } else if(row == 2) {
                newPuzzle = "4x4x4"
            } else if (row == 3) {
                newPuzzle = "5x5x5"
            } else if (row == 4) {
                newPuzzle = "6x6x6"
            } else if (row == 5) {
                newPuzzle = "7x7x7"
            } else if (row == 6) {
                newPuzzle = "Pyraminx"
            } else if (row == 7) {
                newPuzzle = "Square-1"
            } else if (row == 8) {
                newPuzzle = "Skewb"
            } else {
                newPuzzle = "Clock"
            }
            self.updateCurrentPuzzle(newPuzzle)
            currentPuzzleLabel.text = "Puzzle: " + newPuzzle
        } else {
            let newSession = String(row + 1)
            self.updateCurrentSession(newSession)
            currentSession = newSession
            
            // Update the settings
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            let fetchRequest = NSFetchRequest(entityName: "Settings")
            settings.removeAll()
            do {
                let fetched_results = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
                for item in fetched_results {
                    let sessionNumber = item.valueForKey("sessionNumber") as? String
                    if sessionNumber == currentSession {
                        settings.append(item)
                    }
                }
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
            
            // Update the row of the puzzle picker
            let currentSettings = settings[0]
            let currentPuzzle = currentSettings.valueForKey("currentPuzzle") as? String
            let pickerRow = getPuzzlePickerRow(currentPuzzle!)
            puzzlePickerView.selectRow(pickerRow, inComponent: 0, animated: false)
            currentPuzzleLabel.text = "Puzzle: " + currentPuzzle!
            
            // Update the row of the session picker
            let currentRow = Int(currentSession)! - 1
            sessionPickerView.selectRow(currentRow, inComponent: 0, animated: false)
            
            // Update the inspection time field
            let currentInspectionTime = currentSettings.valueForKey("inspectionTime") as? String
            inspectionTimeField.text = currentInspectionTime
        }
    }
    
    // Add the done button to the numeric pad keyboard
    func addDoneButtonToKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        doneToolbar.barStyle = UIBarStyle.Default
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: Selector("doneButtonAction"))
        
        var items = [UIBarButtonItem]()
        items.append(flexibleSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inspectionTimeField.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction() {
        self.inspectionTimeField.resignFirstResponder()
    }
    
    // Update the current puzzle in core data
    func updateCurrentPuzzle(newPuzzle: String) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Settings")
        fetchRequest.includesPropertyValues = false
        
        do {
            let items = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            for item in items {
                let sessionNumber = item.valueForKey("sessionNumber") as? String
                if sessionNumber == currentSession {
                    item.setValue(newPuzzle, forKey: "currentPuzzle")
                }
            }
            try managedContext.save()
        } catch {
            // Error Handling
        }
    }
    
    // Update the current inspection time in core data
    func updateCurrentInspectionTime(newInspectionTime: String) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Settings")
        fetchRequest.includesPropertyValues = false
        
        do {
            let items = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            for item in items {
                let sessionNumber = item.valueForKey("sessionNumber") as? String
                if sessionNumber == currentSession {
                    item.setValue(newInspectionTime, forKey: "inspectionTime")
                }
            }
        } catch {
            // Error Handling
        }
    }
    
    // Update the current session in core data
    func updateCurrentSession(newSession: String) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Session")
        fetchRequest.includesPropertyValues = false
        
        do {
            let items = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            if items.count == 0 {
                let entity2 =  NSEntityDescription.entityForName("Session", inManagedObjectContext:managedContext)
                let new_result2 = NSManagedObject(entity: entity2!, insertIntoManagedObjectContext: managedContext)
                new_result2.setValue("1", forKey: "currentSession")
                
                do {
                    try managedContext.save()
                } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                }
            } else {
                let currentSettings = items[0]
                currentSettings.setValue(newSession, forKey: "currentSession")
                try managedContext.save()
            }
        } catch {
            // Error Handling
        }
    }

}
