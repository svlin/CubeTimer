//
//  CubeTimerTests.swift
//  CubeTimerTests
//
//  Created by Sophia Lin on 11/2/16.
//  Copyright © 2016 Sophia Lin. All rights reserved.
//

import XCTest
@testable import CubeTimer

class CubeTimerTests: XCTestCase {
    
    var puzzleTimes:TimeModel!
    
    override func setUp() {
        super.setUp()
        puzzleTimes = TimeModel()
    }
    
    override func tearDown() {
        super.tearDown()
        puzzleTimes = nil
    }
    
    // Testing the mean of three function
    func testMeanOfThree() {
        // Less than 3 solves, so the mean of 3 function returns -1.0
        puzzleTimes.sessionTimes = [1.18, 19.42]
        var mo3 = puzzleTimes.meanOfThree()
        XCTAssertEqual(mo3, "--")
        //XCTAssertEqualWithAccuracy(mo3, -1.0, accuracy: 0.00000000001)
        
        // Returns the correct mean of 3 for the 3 times
        puzzleTimes.sessionTimes = [34.55, 80.1, 10.11]
        mo3 = puzzleTimes.meanOfThree()
        XCTAssertEqual(mo3, "41.59s")
        
        // Returns the correct mean of 3 for the 3 most recent times
        puzzleTimes.sessionTimes = [91.20, 10.24, 11.50, 29.65, 41.24, 14.22]
        mo3 = puzzleTimes.meanOfThree()
        XCTAssertEqual(mo3, "28.37s")
    }
    
    // Testing the average of 5 function
    func testAverageOfFive() {
        // Less than 5 solves, so the avg of 5 returns -1.0
        puzzleTimes.sessionTimes = [1.25, 6.74, 15.20, 10.9]
        var ao5 = puzzleTimes.calculateAverage(5)
        XCTAssertEqual(ao5, "--")
        
        // Returns the correct average of 5 for the 5 times
        puzzleTimes.sessionTimes = [34.22, 10.45, 56.22, 43.32, 19.55]
        ao5 = puzzleTimes.calculateAverage(5)
        XCTAssertEqual(ao5, "32.36s")
        
        // Returns the correct average of 5 for the 5 most recent times
        puzzleTimes.sessionTimes = [2.44, 10.56, 34.29, 16.54, 65.02, 5.44, 18.52]
        ao5 = puzzleTimes.calculateAverage(5)
        XCTAssertEqual(ao5, "23.12s")
    }
    
    // Testing the average of 12 function
    func testAverageOfTwelve() {
        // Less than 12 solves, so the avg of 12 returns -1.0
        puzzleTimes.sessionTimes = [1.25, 6.74, 15.20, 10.9, 8.23, 34.4, 42.5, 23.32, 39.1]
        var ao5 = puzzleTimes.calculateAverage(12)
        XCTAssertEqual(ao5, "--")
        
        // Returns the correct average of 12 for the 12 times
        puzzleTimes.sessionTimes = [34.22, 10.45, 56.22, 43.32, 19.55, 22.1, 0.5, 2.54, 20.53, 95.6, 1.65, 19.4]
        ao5 = puzzleTimes.calculateAverage(12)
        XCTAssertEqual(ao5, "23.0s")
        
        // Returns the correct average of 12 for the 12 most recent times
        puzzleTimes.sessionTimes = [2.44, 10.56, 34.29, 16.54, 65.02, 5.44, 18.52, 23.3, 10.3, 4.5, 0.01, 99.2, 30.1, 12.4, 49.5, 10.2, 40.1, 1.1]
        ao5 = puzzleTimes.calculateAverage(12)
        XCTAssertEqual(ao5, "20.0s")
    }
    
    // Testing the average of 25 function
    func testAverageOfTwentyFive() {
        // Less than 25 solves, so the avg of 25 returns -1.0
        puzzleTimes.sessionTimes = [1.25, 6.74, 15.20, 10.9, 12.23, 23.4, 52.4, 8.35, 59.5, 20.34, 23.4, 43.1, 1.0]
        var ao5 = puzzleTimes.calculateAverage(25)
        XCTAssertEqual(ao5, "--")
        
        // Returns the correct average of 25 for the 25 times
        puzzleTimes.sessionTimes = [34.22, 40.45, 56.22, 43.32, 59.55, 1.25, 66.74, 15.20, 10.9, 32.23, 53.4, 52.4, 8.35, 59.5, 80.34, 73.4, 43.1, 0.01, 92.44, 10.56, 34.29, 16.54, 65.02, 5.44, 18.52]
        ao5 = puzzleTimes.calculateAverage(25)
        XCTAssertEqual(ao5, "38.3s")
        
        // Returns the correct average of 25 for the 25 most recent times
        puzzleTimes.sessionTimes = [34.22, 10.45, 56.22, 43.32, 2.44, 10.56, 34.29, 16.54, 65.02, 5.44, 18.52, 23.3, 10.3, 4.5, 0.01, 99.2, 30.1, 12.4, 91.20, 10.24, 11.50, 29.65, 41.24, 14.22, 49.5, 1.25, 6.74, 15.20, 10.9, 8.23, 34.4, 42.5, 23.32, 39.1, 2.54, 20.53, 95.6, 1.65, 19.4]
        ao5 = puzzleTimes.calculateAverage(25)
        XCTAssertEqual(ao5, "26.58s")
    }
    
    func testDNFMeanOf3() {
        // DNF for mean of 3, whenever there is at least one DNF
        puzzleTimes.sessionTimes = [-1.0, 19.42, 0.55]
        var mo3 = puzzleTimes.meanOfThree()
        XCTAssertEqual(mo3, "DNF")
        
        puzzleTimes.sessionTimes = [-1.0, -1.0, 0.55]
        mo3 = puzzleTimes.meanOfThree()
        XCTAssertEqual(mo3, "DNF")
    }
    
    func testDNFAverages() {
        // Disregard the DNF in average of 5, when there is one DNF
        puzzleTimes.sessionTimes = [-1.0, 6.74, 15.20, 10.9, 3.7]
        var ao5 = puzzleTimes.calculateAverage(5)
        XCTAssertEqual(ao5, "10.95s")
        
        // DNF for average of 5, when there are at least two DNF
        puzzleTimes.sessionTimes = [-1.0, -1.0, 15.20, 10.9, 3.7]
        ao5 = puzzleTimes.calculateAverage(5)
        XCTAssertEqual(ao5, "DNF")
    }
    
}