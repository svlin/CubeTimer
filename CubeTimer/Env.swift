//
//  Env.swift
//  SwiftCharts
//
//  Created by ischuetz on 07/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

// Citation: https://github.com/i-schuetz/SwiftCharts/blob/master/Examples/Examples/Env.swift

import UIKit

class Env {
    
    static var iPad: Bool {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad
    }
}