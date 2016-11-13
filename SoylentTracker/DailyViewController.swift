//
//  ViewController.swift
//  SoylentTracker
//
//  Created by Linh Hoang on 11/12/16.
//  Copyright © 2016 Linh Hoang. All rights reserved.
//

import UIKit
import PebbleKit
class DailyViewController: UIViewController, PBPebbleCentralDelegate, UITabBarControllerDelegate {

    
    @IBOutlet weak var CaffeinCounter: UILabel!
    @IBOutlet weak var CaloriesCounter: UILabel!
    @IBOutlet weak var ConnectingButton: UIButton!
    var data: SoylentData?
    @IBOutlet weak var counter: CounterView!
    @IBOutlet weak var number: UILabel!
    var delegate: AppDelegate?
    var date: String = ""
    var connectedWatch: PBWatch? {
        didSet {
            if let connectedWatch = connectedWatch {

                ConnectingButton.setBackgroundImage(UIImage(named: "ConnectButton"), for: .normal)
                UIView.animate(withDuration: 0.12, delay: 0, options: [.curveEaseOut, .beginFromCurrentState], animations: {
                    self.ConnectingButton.alpha = 1
                }, completion: nil)
                connectedWatch.appMessagesLaunch({ (_, error) in
                    if error == nil {
                        NSLog("App launched!")
                    }

                })

                connectedWatch.appMessagesAddReceiveUpdateHandler({
                    (watch, dict) -> Bool in
                    if ((dict[0]) != nil){
                        if let i = dict[0] as? Int {
                            self.counter.counter = i
                            self.number.text = "\(self.counter.counter)"
                        }
                    }
                    return true
                })
                let sent :Dictionary = [0: counter.counter]

                self.connectedWatch?.appMessagesPushUpdate(sent as [NSNumber : Any]) {
                    (watch, dict, error) -> () in
                    if (error == nil){
                        NSLog("sucessful")
                    } else {
                        NSLog("error sending \(error) ")
                    }
                }

            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        date = Util.string(from: Date())
        // Do any additional setup after loading the view, typically from a nib.
        self.data = Util.loadData()
        if (self.data != nil) {
            let current = self.data!.data[date] != nil ? self.data!.data[date]! : 0
            counter.counter = current

        } else {
            self.data = SoylentData(data: [:])
            counter.counter = 0
        }
        number.text = "\(counter.counter)"
        CaloriesCounter.text = "Calories: \(counter.counter * 400) kcal"
        let _ = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(DailyViewController.updateData), userInfo: nil, repeats: true)

        delegate = UIApplication.shared.delegate as? AppDelegate
        delegate?.dailyView = self
        let central = PBPebbleCentral.default()
        central.delegate = self

    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        saveData()
    }

    @IBAction func connectToPebble(_ sender: UIButton) {

        sender.setBackgroundImage(UIImage(named: "ButtonConnecting") , for: .normal)
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseInOut, .repeat, .autoreverse, .allowUserInteraction], animations: {() -> Void in
            sender.alpha = 0.0
        }, completion: {(finished: Bool) -> Void in
        })
        PBPebbleCentral.default().run()
    }

    func updateData(){

        let currentDate = Util.string(from: Date())
        if currentDate != date {
            saveData()
            counter.counter = 0
            number.text = "\(counter.counter)"
            CaloriesCounter.text = "Calories: \(counter.counter * 400) kcal"
            self.date = currentDate

        } else {
            saveData()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
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

        let sent :Dictionary = [0: counter.counter]
        
        self.connectedWatch?.appMessagesPushUpdate(sent as [NSNumber : Any]) {
            (watch, dict, error) -> () in
            if (error == nil){
                print("sucessful")
            } else {
                print("error sending \(error) ")
            }
        }
        number.text = "\(counter.counter)"
        CaloriesCounter.text = "Calories: \(counter.counter * 400) kcal"
    }

    func saveData(){
        self.data!.data[date] = counter.counter
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(data!, toFile: SoylentData.ArchiveURL.path)
        if !isSuccessfulSave {
            print("Failed to save data")
        }
    }


    func pebbleCentral(_ central: PBPebbleCentral, watchDidConnect watch: PBWatch, isNew: Bool) {
        self.connectedWatch = watch
    }

    func pebbleCentral(_ central: PBPebbleCentral, watchDidDisconnect watch: PBWatch) {
        if self.connectedWatch == watch {
            self.connectedWatch = nil
        }
    }

}

