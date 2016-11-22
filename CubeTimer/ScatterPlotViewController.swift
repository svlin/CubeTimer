//
//  ScatterPlotViewController.swift
//  CubeTimer
//
//  Created by Sophia Lin on 11/22/16.
//  Copyright © 2016 Sophia Lin. All rights reserved.
//

// Citation: https://github.com/i-schuetz/SwiftCharts/blob/master/Examples/Examples/HelloWorld.swift

import UIKit
import SwiftCharts

class ScatterPlotViewController: UIViewController {
    
    var chart: Chart? // arc

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // map model data to chart points
        let chartPoints: [ChartPoint] = [(2, 2), (4, 4), (6, 6), (8, 10), (12, 14)].map{ChartPoint(x: ChartAxisValueInt($0.0), y: ChartAxisValueInt($0.1))}
        
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        // define x and y axis values (quick-demo way, see other examples for generation based on chartpoints)
        let xValues: [ChartAxisValue] = [0, 2, 4, 6, 8, 10, 12, 14, 16].map {ChartAxisValueInt($0, labelSettings: labelSettings)}
        let yValues: [ChartAxisValue] = [0, 2, 4, 6, 8, 10, 12, 14, 16].map {ChartAxisValueInt($0, labelSettings: labelSettings)}
        
        //let xValues = stride(from: 0, through: 16, by: 2).map {ChartAxisValueInt($0, labelSettings: labelSettings)}
        //let yValues = stride(from: 0, through: 16, by: 2).map {ChartAxisValueInt($0, labelSettings: labelSettings)}
        
        // create axis models with axis values and axis title
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Axis title", settings: labelSettings.defaultVertical()))
        
        let chartFrame = ExamplesDefaults.chartFrame(self.view.bounds)
        
        // generate axes layers and calculate chart inner frame, based on the axis models
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: ExamplesDefaults.chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxis, yAxis, innerFrame) = (coordsSpace.xAxis, coordsSpace.yAxis, coordsSpace.chartInnerFrame)
        
        // create layer with guidelines
        let guidelinesLayerSettings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.blackColor(), linesWidth: ExamplesDefaults.guidelinesWidth)
        let guidelinesLayer = ChartGuideLinesDottedLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, settings: guidelinesLayerSettings)
        
        // view generator - this is a function that creates a view for each chartpoint
        let viewGenerator = {(chartPointModel: ChartPointLayerModel, layer: ChartPointsViewsLayer, chart: Chart) -> UIView? in
            let viewSize: CGFloat = Env.iPad ? 30 : 20
            let center = chartPointModel.screenLoc
            let label = UILabel(frame: CGRect(x: center.x - viewSize / 2, y: center.y - viewSize / 2, width: viewSize, height: viewSize))
            label.backgroundColor = UIColor.greenColor()
            label.textAlignment = NSTextAlignment.Center
            label.text = chartPointModel.chartPoint.y.description
            label.font = ExamplesDefaults.labelFont
            return label
        }
        
        // create layer that uses viewGenerator to display chartpoints
        let chartPointsLayer = ChartPointsViewsLayer(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, viewGenerator: viewGenerator)
        
        // create chart instance with frame and layers
        let chart = Chart(
            frame: chartFrame,
            layers: [
                coordsSpace.xAxis,
                coordsSpace.yAxis,
                guidelinesLayer,
                chartPointsLayer
            ]
        )
        
        self.view.addSubview(chart.view)
        self.chart = chart
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        //self.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let leadingConstraint = NSLayoutConstraint(item: chart.view, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: chart.view, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: chart.view, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: chart.view, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0)
        view.addConstraints([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

}
