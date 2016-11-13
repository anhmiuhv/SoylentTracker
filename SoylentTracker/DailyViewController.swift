//
//  ViewController.swift
//  SoylentTracker
//
//  Created by Linh Hoang on 11/12/16.
//  Copyright © 2016 Linh Hoang. All rights reserved.
//

import UIKit

class DailyViewController: UIViewController {

    
    var data: SoylentData?
    @IBOutlet weak var counter: CounterView!
    @IBOutlet weak var number: UILabel!

    var date: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        date = Util.string(from: Date())
        // Do any additional setup after loading the view, typically from a nib.
        self.data = loadData()
        if (self.data != nil) {
            let current = self.data!.data[date] != nil ? self.data!.data[date]! : 0
            counter.counter = current
            number.text = "\(counter.counter)"
        } else {
            self.data = SoylentData(data: [:])
            counter.counter = 0
            number.text = "\(counter.counter)"
        }
        let _ = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(DailyViewController.updateData), userInfo: nil, repeats: true)

        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.dailyView = self
    }

    func updateData(){

        let currentDate = Util.string(from: Date())
        if currentDate != date {
            saveData()
            counter.counter = 0
            number.text = "\(counter.counter)"
            self.date = currentDate

        } else {
            saveData()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        saveData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func changeCounter(_ sender: UIButton) {
        if sender.tag == 0 {
            counter.counter += 1
        } else {
            counter.counter -= 1
        }
        number.text = "\(counter.counter)"
    }

    func saveData(){
        self.data!.data[date] = counter.counter
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(data!, toFile: SoylentData.ArchiveURL.path)
        if !isSuccessfulSave {
            print("Failed to save data")
        }
    }

    func loadData() -> SoylentData? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: SoylentData.ArchiveURL.path) as? SoylentData
    }


}

