//
//  ViewController.swift
//  AroundMe
//
//  Created by Javad Rahimipour Anaraki on 2020-05-20.
//  Copyright © 2020 Holland Bloorview Kids Rehabilitation Hospital. All rights reserved.
//

import UIKit
import CoreBluetooth
import AudioToolbox

class ViewController: UIViewController {
    
    @IBOutlet weak var activateSwitch: UISwitch!
    
    @IBOutlet weak var distance: UISlider!
    
    @IBOutlet weak var threshold: UISlider!
    
    @IBOutlet weak var status: UILabel!
    
    @IBOutlet weak var activityIcon: UIActivityIndicatorView!
    
    @IBOutlet weak var counter: UILabel!
    
    var centralManager: CBCentralManager!
    
    var bluetoothStatus = false
    
    var people = 0
    
    //Getters
    func getDistance() -> Float {
        return Float(distance.value)
    }
    
    func getThreshold() -> Int {
        return Int(threshold.value)
    }
    
    //Setters
    func setStatus(value:String) {
        status.text = value
        if value == "Dangerous!" {
            status.textColor = UIColor.red
        } else {
            status.textColor = UIColor.green
        }
    }
    
    func setCounter(value:Int){
        counter.text = String(value)
    }
    
    func initiate()  {
        setStatus(value: "Safe")
        setCounter(value: 0)
        people = 0
    }
    
    func vibrate() {
        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIcon.isHidden = true
        initiate()
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    @IBAction func distanceChanged(_ sender: Any) {
        initiate()
    }
    
    @IBAction func thresholdChanged(_ sender: Any) {
        initiate()
    }
    
    @IBAction func activeMonitoring(_ sender: Any) {
        
        if activateSwitch.isOn {
            centralManager = CBCentralManager(delegate: self, queue: nil)
            activityIcon.isHidden = false
            activityIcon.startAnimating()
        } else {
            centralManager.stopScan()
            activityIcon.stopAnimating()
            activityIcon.isHidden = true
            initiate()
        }
    }
}

extension ViewController: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .resetting:
            bluetoothStatus = false
        case .unsupported:
            bluetoothStatus = false
        case .unauthorized:
            bluetoothStatus = false
        case .poweredOff:
            bluetoothStatus = false
        case .poweredOn:
            bluetoothStatus = true
            centralManager.scanForPeripherals(withServices: nil)
        case .unknown:
            bluetoothStatus = false
        default:
            bluetoothStatus = false
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        let dist:Float = pow(10, ((-80 - Float(truncating: RSSI)) / 20))
        
        if (dist <= getDistance()) {
            people += 1
            setCounter(value: people)
            
        } else {
            people -= 1
            if people < 0 {
                people = 0
            }
            setCounter(value: people)
        }
        
        if (people >= getThreshold()) {
            setStatus(value: "Dangerous!")
            vibrate()
            //sleep(2)
        } else {
            setStatus(value: "Safe")
        }
        
    }
}
