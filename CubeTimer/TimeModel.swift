//
//  TimeModel.swift
//  CubeTimer
//
//  Created by Sophia Lin on 11/3/16.
//  Copyright © 2016 Sophia Lin. All rights reserved.
//

import UIKit

// Stores all times of the user, and calculates various statistics for the times
class TimeModel: NSObject {
    
    // All times that the user logs in the current session, stored as an array of doubles
    var sessionTimes: [Double] = []
    // All scrambles that the user logs in the current session, stored as an array of strings
    var sessionScrambles: [String] = []
    // All puzzles that the user used for each time in the current session, stored as an array of strings
    var sessionPuzzles: [String] = []
    // Current puzzle that the user chose, default puzzle is 3x3x3
    var currentPuzzle: String = "3x3x3"
    // Current inspection time, default is 0
    var currentInspectionTime: String = ""
    
    let smallCubeMoves = ["F", "F'", "F2", "B", "B'", "B2", "U", "U'", "U2", "D", "D'", "D2", "L", "L'", "L2", "R", "R'", "R2"]
    let mediumCubeMoves = ["F", "F'", "F2", "Fw", "Fw'", "Fw2",
                        "B", "B'", "B2", "Bw", "Bw'", "Bw2",
                        "U", "U'", "U2", "Uw", "Uw'", "Uw2",
                        "D", "D'", "D2", "Dw", "Dw'", "Dw2",
                        "L", "L'", "L2", "Lw", "Lw'", "Lw2",
                        "R", "R'", "R2", "Rw", "Rw'", "Rw2"]
    let largeCubeMoves = ["F", "F'", "F2", "Fw", "Fw'", "Fw2", "3Fw", "3Fw'", "3Fw2",
                        "B", "B'", "B2", "Bw", "Bw'", "Bw2", "3Bw", "3Bw'", "3Bw2",
                        "U", "U'", "U2", "Uw", "Uw'", "Uw2", "3Uw", "3Uw'", "3Uw2",
                        "D", "D'", "D2", "Dw", "Dw'", "Dw2", "3Dw", "3Dw'", "3Dw2",
                        "L", "L'", "L2", "Lw", "Lw'", "Lw2", "3Lw", "3Lw'", "3Lw2",
                        "R", "R'", "R2", "Rw", "Rw'", "Rw2", "3Rw", "3Rw'", "3Rw2"]
    let pyraminxLayerMoves = ["B", "B'", "U", "U'", "L", "L'", "R", "R'"]
    let pyraminxTipMoves = ["b", "b'", "u", "u'", "l", "l'", "r", "r'"]
    let square1Moves = ["(-3, -3)", "(1, -5)", "(-3, 0)", "(-1, -4)", "(6, 3)", "(6, -4)", "(-1, 0)", "(3, -4)", "(-4, 0)", "(3, -1)", "(5, -1)", "(6, -3)", "(2, -1)", "(1, 0)", "(-3, -1)", "(0, -3)", "(0, 3)", "(0, -4)", "(5, 0)", "(4, 3)", "(2, 0)", "(4, 0)", "(-2, -2)", "(-5, -2)", "(3, 0)"]
    let clockMoves = ["D6+", "U2-", "UR6+", "D2+", "DL", "U3+", "DR1-", "UR1+", "UR3+", "R5-", "L6+", "L4-", "UR1-", "ALL1-", "UL2+", "DR4+", "UR", "UL3-", "UR2+", "R4-", "L2+", "UL1+", "UR3-", "L5+", "R3+", "ALL1+", "UL4-", "ALL3+", "R1+", "DL2-", "U1+", "UL5+", "ALL6+", "DR", "DR3-", "U2+", "DL4-"]
    
    /*
    Calculates the mean of 3 for the three most recent times of the user, and returns this value in String form. If the user has not logged three solves yet, then the function returns "--", which is the initial value of the text label. If the user has logged a DNF, then the function returns "DNF".
    
    - Returns: Mean of 3 as a String
    */
    func meanOfThree() -> String {
        if (sessionTimes.count >= 3) {
            let lastThree = sessionTimes.suffix(3)
            if lastThree.contains(-1.0) {
                return "DNF"
            }
            let sum = lastThree.reduce(0, combine: +)
            return String(roundTwoDecimals(sum / 3.0, toNearest: 0.01)) + "s"
        }
        return "--"
    }
    
    /*
     Calculates the average of NumSolves times, for the NumSolves most recent times of the user. If the user has not logged NumSolves times yet, then the function returns "--". If the user has logged a DNF, then the DNF is counted as the slowest time.
    
     - Parameters: NumSolves: number of times to calculate the average for
     - Returns: Average of NumSolves times: the fastest and slowest times are disregarded, and the mean of 3 is calculated for the remaining times
    */
    func calculateAverage(NumSolves: Int) -> String {
        if (sessionTimes.count >= NumSolves) {
            let lastTimes = sessionTimes.suffix(NumSolves)
            var min = 99999.0
            var max = 0.0
            if lastTimes.contains(-1.0) {
                if isAverageDNF(lastTimes) {
                    return "DNF"
                } else {
                    for time in lastTimes {
                        if time < min && time != -1.0 {
                            min = time
                        }
                    }
                    max = -1.0
                }
            } else {
                min = lastTimes.minElement()!
                max = lastTimes.maxElement()!
            }
            var sum = 0.0
            for time in lastTimes {
                if time != min && time != max {
                    sum += time
                }
            }
            return String(roundTwoDecimals(sum / Double(NumSolves - 2), toNearest: 0.01)) + "s"
        }
        return "--"
    }
    
    // Determines if there are 2 or more DNF's in an array of times. 
    func isAverageDNF(times: ArraySlice<Double>) -> Bool {
        var count = 0
        for time in times {
            if time == -1.0 {
                count += 1
            }
        }
        return count >= 2
    }
    
    // Rounds a given double to the nearest two decimals
    func roundTwoDecimals(number: Double, toNearest: Double) -> Double {
        return round(number / toNearest) * toNearest
    }
    
    /*
    Generates a random scramble for the 2x2x2 puzzle. Scramble length of 9.
    Each consecutive move has to be from a different face of the cube (F, B, U, D, L, R)
    
    - Returns: Scramble as a string
    */
    func generate2x2x2Scramble() -> String {
        var scramble = ""
        var moveIndex = Int(arc4random_uniform(18))
        scramble += smallCubeMoves[moveIndex] + " "
        var lastMove = moveIndex
        for _ in 1...9 {
            moveIndex = Int(arc4random_uniform(18))
            while (abs(lastMove - moveIndex) < 3) {
                moveIndex = Int(arc4random_uniform(18))
            }
            scramble += smallCubeMoves[moveIndex] + " "
            lastMove = moveIndex
        }
        return scramble
    }
    
    /*
    Generates a random scramble for the 3x3x3 puzzle (Rubik's Cube). Scramble length ranging from 19 to 25.
    Each consecutive move has to be from a different face of the cube (F, B, U, D, L, R)
    
    - Returns: Scramble as a string
    */
    func generate3x3x3Scramble() -> String {
        var scramble = ""
        let numMoves = Int(arc4random_uniform(6) + 19)
        var moveIndex = Int(arc4random_uniform(18))
        scramble += smallCubeMoves[moveIndex] + " "
        var lastMove = moveIndex
        for _ in 1...(numMoves-1) {
            moveIndex = Int(arc4random_uniform(18))
            while (abs(lastMove - moveIndex) < 3) {
                moveIndex = Int(arc4random_uniform(18))
            }
            scramble += smallCubeMoves[moveIndex] + " "
            lastMove = moveIndex
        }
        return scramble
    }
    
    /*
    Generates a random scramble for the 4x4x4 puzzle. Scramble length of 39.
    Each consecutive move has to be from a different face of the cube (F, B, U, D, L, R)
    
    - Returns: Scramble as a string
    */
    func generate4x4x4Scramble() -> String {
        var scramble = ""
        var moveIndex = Int(arc4random_uniform(36))
        scramble += mediumCubeMoves[moveIndex] + " "
        var lastMove = moveIndex
        for _ in 1...39 {
            moveIndex = Int(arc4random_uniform(36))
            while (abs(lastMove - moveIndex) < 6) {
                moveIndex = Int(arc4random_uniform(36))
            }
            scramble += mediumCubeMoves[moveIndex] + " "
            lastMove = moveIndex
        }
        return scramble
    }
    
    /*
    Generates a random scramble for the 5x5x5 puzzle. Scramble length of 59.
    Each consecutive move has to be from a different face of the cube (F, B, U, D, L, R)
    
    - Returns: Scramble as a string
    */
    func generate5x5x5Scramble() -> String {
        var scramble = ""
        var moveIndex = Int(arc4random_uniform(36))
        scramble += mediumCubeMoves[moveIndex] + " "
        var lastMove = moveIndex
        for _ in 1...59 {
            moveIndex = Int(arc4random_uniform(36))
            while (abs(lastMove - moveIndex) < 6) {
                moveIndex = Int(arc4random_uniform(36))
            }
            scramble += mediumCubeMoves[moveIndex] + " "
            lastMove = moveIndex
        }
        return scramble
    }
    
    /*
    Generates a random scramble for the 6x6x6 puzzle. Scramble length of 79.
    Each consecutive move has to be from a different face of the cube (F, B, U, D, L, R)
    
    - Returns: Scramble as a string
    */
    func generate6x6x6Scramble() -> String {
        var scramble = ""
        var moveIndex = Int(arc4random_uniform(54))
        scramble += largeCubeMoves[moveIndex] + " "
        var lastMove = moveIndex
        for _ in 1...79 {
            moveIndex = Int(arc4random_uniform(54))
            while (abs(lastMove - moveIndex) < 9) {
                moveIndex = Int(arc4random_uniform(54))
            }
            scramble += largeCubeMoves[moveIndex] + " "
            lastMove = moveIndex
        }
        return scramble
    }
    
    /*
    Generates a random scramble for the 7x7x7 puzzle. Scramble length of 99.
    Each consecutive move has to be from a different face of the cube (F, B, U, D, L, R)
    
    - Returns: Scramble as a string
    */
    func generate7x7x7Scramble() -> String {
        var scramble = ""
        var moveIndex = Int(arc4random_uniform(54))
        scramble += largeCubeMoves[moveIndex] + " "
        var lastMove = moveIndex
        for _ in 1...99 {
            moveIndex = Int(arc4random_uniform(54))
            while (abs(lastMove - moveIndex) < 9) {
                moveIndex = Int(arc4random_uniform(54))
            }
            scramble += largeCubeMoves[moveIndex] + " "
            lastMove = moveIndex
        }
        return scramble
    }
    
    /*
    Generates a random scramble for the Pyraminx puzzle. Scramble length ranging from 8 to 15, where the tip moves make up a maximum of 4 of the last moves.
    Each consecutive move has to be from a different face of the cube (B, U, L, R)
    
    - Returns: Scramble as a string
    */
    func generatePyraminxScramble() -> String {
        var scramble = ""
        let totalMoves = Int(arc4random_uniform(7) + 8)
        let tipMoves = Int(arc4random_uniform(4) + 1)           // tip moves make up 1 - 4 moves in the total moves
        let layerMoves = totalMoves - tipMoves                  // layer moves make up the rest
        
        var moveIndex = Int(arc4random_uniform(8))
        scramble += pyraminxLayerMoves[moveIndex] + " "
        var lastMove = moveIndex
        for _ in 1...(layerMoves-1) {
            moveIndex = Int(arc4random_uniform(8))
            while (abs(lastMove - moveIndex) < 2) {
                moveIndex = Int(arc4random_uniform(8))
            }
            scramble += pyraminxLayerMoves[moveIndex] + " "
            lastMove = moveIndex
        }
        moveIndex = Int(arc4random_uniform(8))
        scramble += pyraminxTipMoves[moveIndex] + " "
        lastMove = moveIndex
        for _ in 0...(tipMoves-1) {
            moveIndex = Int(arc4random_uniform(8))
            while (abs(lastMove - moveIndex) < 2) {
                moveIndex = Int(arc4random_uniform(8))
            }
            scramble += pyraminxTipMoves[moveIndex] + " "
            lastMove = moveIndex
        }
        return scramble
    }
    
    /*
    Generates a random scramble for the Square-1 puzzle. Scramble length ranging from 8 to 13.
    Each consecutive move has to be different.
    
    - Returns: Scramble as a string
    */
    func generateSquare1Scramble() -> String {
        var scramble = ""
        let numMoves = Int(arc4random_uniform(5) + 8)
        var moveIndex = Int(arc4random_uniform(25))
        scramble += square1Moves[moveIndex] + "/"
        var lastMove = moveIndex
        for _ in 1...(numMoves-1) {
            moveIndex = Int(arc4random_uniform(25))
            while (lastMove == moveIndex) {
                moveIndex = Int(arc4random_uniform(25))
            }
            scramble += square1Moves[moveIndex] + "/"
            lastMove = moveIndex
        }
        let lastTurn = Int(arc4random_uniform(2))
        if lastTurn == 0 {
            scramble.removeAtIndex(scramble.endIndex.predecessor())
        }
        return scramble
    }
    
    /*
    Generates a random scramble for the Skewb puzzle. Scramble length either 7 or 8.
    Each consecutive move has to be from a different face of the cube (B, U, L, R)
    
    - Returns: Scramble as a string
    */
    func generateSkewbScramble() -> String {
        var scramble = ""
        let numMoves = Int(arc4random_uniform(1) + 7)
        var moveIndex = Int(arc4random_uniform(8))
        scramble += pyraminxLayerMoves[moveIndex] + " "
        var lastMove = moveIndex
        for _ in 1...(numMoves-1) {
            moveIndex = Int(arc4random_uniform(8))
            while (abs(lastMove - moveIndex) < 2) {
                moveIndex = Int(arc4random_uniform(8))
            }
            scramble += pyraminxLayerMoves[moveIndex] + " "
            lastMove = moveIndex
        }
        return scramble
    }
    
    /*
    Generates a random scramble for the Clock puzzle. Scramble length ranging from 11 to 15.
    Each consecutive move has to be from a different face of the cube (F, B, U, D, L, R)
    
    - Returns: Scramble as a string
    */
    func generateClockScramble() -> String {
        var scramble = ""
        let numMoves = Int(arc4random_uniform(4) + 11)
        var moveIndex = Int(arc4random_uniform(37))
        scramble += clockMoves[moveIndex] + " "
        var lastMove = moveIndex
        for i in 1...(numMoves-1) {
            if i == (numMoves / 2) {
                scramble += "y2 "
            } else {
                moveIndex = Int(arc4random_uniform(37))
                while (abs(lastMove - moveIndex) < 2) {
                    moveIndex = Int(arc4random_uniform(37))
                }
                scramble += clockMoves[moveIndex] + " "
                lastMove = moveIndex
            }
        }
        return scramble
    }
    
}