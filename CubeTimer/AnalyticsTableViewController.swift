//
//  AnalyticsTableViewController.swift
//  CubeTimer
//
//  Created by Sophia Lin on 11/22/16.
//  Copyright © 2016 Sophia Lin. All rights reserved.
//

import UIKit

class AnalyticsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "ScatterPlotSegue" {
            if let _ = segue.destinationViewController as? ScatterPlotViewController {
                //if let _ = self.tableView.indexPathForCell(sender as! UITableViewCell) {
                //}
            }
        }
    }

}
