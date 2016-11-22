//
//  TimerViewController.swift
//  CubeTimer
//
//  Created by Sophia Lin on 11/2/16.
//  Copyright © 2016 Sophia Lin. All rights reserved.
//

// Tutorial for building a timer in Swift:
// http://www.ios-blog.co.uk/tutorials/swift/swift-timer-tutorial-create-a-counter-timer-application-using-nstimer/
// Icons used in toolbar:
// https://icons8.com/

import UIKit
import CoreData

class TimerViewController: UIViewController {
    
    // Array of times in core data
    var results = [NSManagedObject]()
    var settings = [NSManagedObject]()
    var currentSession = ""
    
    var timer = NSTimer()
    var countdownClock = NSTimer()
    var counter = 0.0
    var countdownTime = 0
    
    // TimeModel object
    var puzzleTimes = TimeModel()
    
    @IBOutlet var scrambleLabel: UILabel!
    @IBOutlet var avgTwentyFiveLabel: UILabel!
    @IBOutlet var avgTwelveLabel: UILabel!
    @IBOutlet var meanThreeLabel: UILabel!
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var avgFiveLabel: UILabel!
    @IBOutlet var tapView: UIView!
    @IBOutlet var tapRec: UITapGestureRecognizer!
    @IBOutlet var longPressRec: UILongPressGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Initializes the TimeModel object
        let ttbc = self.tabBarController as! TimesTabBarController
        puzzleTimes = ttbc.myTime
        results = ttbc.results
        settings = ttbc.settings
        
        // Initializes the gestures for the app
        tapRec.addTarget(self, action: "tappedView:")
        longPressRec.addTarget(self, action: "longPressedView:")
        tapView.addGestureRecognizer(tapRec)
        tapView.addGestureRecognizer(longPressRec)
        tapView.userInteractionEnabled = true
        
        // Initializes the timer label and statistics labels
        timerLabel.text = "00.00"
        updateTimes()
        
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
        
        // Gets the settings
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
        
        // Initializes the scramble
        scrambleLabel.text = generateScramble()
    }
    
    /* 
        Creates an array of doubles out of the times in the core data, then assigns it to the sessionTimes
        Calls updateStatistics() to update the labels of the statistics
    */
    func updateTimes() {
        var sessionTimes: [Double] = []
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Results")
        fetchRequest.includesPropertyValues = false
        
        do {
            let items = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            for item in items {
                let sessionNumber = item.valueForKey("sessionNumber") as? String
                if sessionNumber == currentSession {
                    let time = item.valueForKey("time") as? Double
                    sessionTimes.append(time!)
                }
            }
        } catch {
            // Error Handling
        }
        
        puzzleTimes.sessionTimes = sessionTimes
        updateStatistics()
    }
    
    // Updates the values of the statistics
    func updateStatistics() {
        let meanThree = puzzleTimes.meanOfThree()
        meanThreeLabel.text = "mo3: " + meanThree
        let avgFive = puzzleTimes.calculateAverage(5)
        avgFiveLabel.text = "ao5: " + avgFive
        let avgTwelve = puzzleTimes.calculateAverage(12)
        avgTwelveLabel.text = "ao12: " + avgTwelve
        let avgTwentyFive = puzzleTimes.calculateAverage(25)
        avgTwentyFiveLabel.text = "ao25: " + avgTwentyFive
    }
    
    // Updates the timer page each time the UI is displayed
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        // Gets the current session
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
        
        scrambleLabel.text = generateScramble()
        // Updates the times and statistics for the current session
        updateTimes()
    }
    
    // Handles a tap on the screen, to stop the timer
    func tappedView(sender: UITapGestureRecognizer) {
        if timer.valid {
            timer.invalidate()
            // Save a result to core data
            self.saveResult(counter, puzzle: getCurrentPuzzle(), scramble: scrambleLabel.text!)
            counter = 0.0
            scrambleLabel.text = generateScramble()
            updateTimes()
        } else {
            if countdownClock.valid {
                countdownClock.invalidate()
                timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target:self, selector: Selector("updateCounter"), userInfo: nil, repeats: true)
            }
        }
    }
    
    // Handles a long press on the screen, to start the timer
    func longPressedView(sender: UILongPressGestureRecognizer) {
        if (sender.state == .Ended) {
            if Int(getCurrentInspectionTime()) > 0 {
                countdownTime = Int(getCurrentInspectionTime())!
                countdownClock = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "countdown", userInfo: nil, repeats: true)
            } else {
                timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target:self, selector: Selector("updateCounter"), userInfo: nil, repeats: true)
            }
        }
    }
    
    // Countdown timer
    func countdown() {
        if countdownTime > 0 {
            countdownTime--
            timerLabel.textColor = UIColor.redColor()
            timerLabel.text = String(countdownTime)
        } else {
            timerLabel.textColor = UIColor.redColor()
            timerLabel.text = "DNF!"
            // save to core data
            self.saveResult(-1.0, puzzle: getCurrentPuzzle(), scramble: scrambleLabel.text!)
            scrambleLabel.text = generateScramble()
            updateTimes()
            countdownClock.invalidate()
        }
    }
    
    // Returns the current puzzle of the settings
    func getCurrentPuzzle() -> String {
        let currentSettings = settings[0]
        let currentPuzzle = currentSettings.valueForKey("currentPuzzle") as? String
        return currentPuzzle!
    }
    
    // Returns the current inspection time of the settings
    func getCurrentInspectionTime() -> String {
        let currentSettings = settings[0]
        let currentInspectionTime = currentSettings.valueForKey("inspectionTime") as? String
        return currentInspectionTime!
    }
    
    // Updates the counter label, rounding the time value to two decimals
    func updateCounter() {
        counter += 0.01
        counter = roundTwoDecimals(counter, toNearest: 0.01)
        timerLabel.textColor = UIColor.blackColor()
        timerLabel.text = String(self.counter)
    }
    
    // Rounds a given double to the nearest two decimals
    func roundTwoDecimals(number: Double, toNearest: Double) -> Double {
        return round(number / toNearest) * toNearest
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Calls the appropriate function to generate a scramble of the given puzzle type
    func generateScramble() -> String {
        let puzzleType = getCurrentPuzzle()
        if puzzleType == "2x2x2" {
            scrambleLabel.font = scrambleLabel.font.fontWithSize(25)
            return puzzleTimes.generate2x2x2Scramble()
        } else if puzzleType == "3x3x3" {
            scrambleLabel.font = scrambleLabel.font.fontWithSize(25)
            return puzzleTimes.generate3x3x3Scramble()
        } else if puzzleType == "4x4x4" {
            scrambleLabel.font = scrambleLabel.font.fontWithSize(25)
            return puzzleTimes.generate4x4x4Scramble()
        } else if puzzleType == "5x5x5" {
            scrambleLabel.font = scrambleLabel.font.fontWithSize(20)
            return puzzleTimes.generate5x5x5Scramble()
        } else if puzzleType == "6x6x6" {
            scrambleLabel.font = scrambleLabel.font.fontWithSize(18)
            return puzzleTimes.generate6x6x6Scramble()
        } else if puzzleType == "7x7x7" {
            scrambleLabel.font = scrambleLabel.font.fontWithSize(18)
            return puzzleTimes.generate7x7x7Scramble()
        } else if puzzleType == "Pyraminx" {
            scrambleLabel.font = scrambleLabel.font.fontWithSize(25)
            return puzzleTimes.generatePyraminxScramble()
        } else if puzzleType == "Square-1" {
            scrambleLabel.font = scrambleLabel.font.fontWithSize(20)
            return puzzleTimes.generateSquare1Scramble()
        } else if puzzleType == "Skewb" {
            scrambleLabel.font = scrambleLabel.font.fontWithSize(25)
            return puzzleTimes.generateSkewbScramble()
        } else {
            scrambleLabel.font = scrambleLabel.font.fontWithSize(25)
            return puzzleTimes.generateClockScramble()
        }
    }
    
    // Saves the time, puzzle, and scramble into the given session in CoreData
    func saveResult(time: Double, puzzle: String, scramble: String) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entityForName("Results", inManagedObjectContext:managedContext)
        let new_result = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        let fetchResults = NSFetchRequest(entityName: "Session")
        do {
            let fetchedResults = try managedContext.executeFetchRequest(fetchResults) as! [NSManagedObject]
            if fetchedResults.count > 0 {
                let result = fetchedResults[0]
                let fetchedSession = result.valueForKey("currentSession") as? String
                currentSession = fetchedSession!
                new_result.setValue(fetchedSession, forKey: "sessionNumber")
                new_result.setValue(time, forKey: "time")
                new_result.setValue(puzzle, forKey: "puzzle")
                new_result.setValue(scramble, forKey: "scramble")
                try managedContext.save()
                results.append(new_result)
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
    }

}