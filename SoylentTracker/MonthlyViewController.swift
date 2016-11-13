//
//  MonthlyViewController.swift
//  SoylentTracker
//
//  Created by Linh Hoang on 11/13/16.
//  Copyright © 2016 Linh Hoang. All rights reserved.
//

import Charts
import UIKit

class MonthlyViewController: UIViewController {
    var data: SoylentData?
    @IBOutlet weak var chart: LineChartView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.


    }

    override func viewWillAppear(_ animated: Bool) {
        self.data = Util.loadData()
        if (self.data == nil) {
            self.data = SoylentData(data: [:])
        }
        var dataEntries: [ChartDataEntry] = []
        var i = 0;
        for (key, value) in data!.data{
            print("\(key)")
            let entry = ChartDataEntry(x: Double(i), y: Double(value))
            i += 1
            dataEntries.append(entry)
        }
        if i != 0 {
            chart.data = LineChartData(dataSets: [LineChartDataSet(values: dataEntries, label: nil)])
            chart.setNeedsDisplay()
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
