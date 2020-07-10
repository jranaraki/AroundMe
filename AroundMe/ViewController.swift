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
        
    @IBOutlet weak var counter: UILabel!
    
    @IBOutlet weak var infoButton: UIImageView!
        
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var circleSafe: UIView!
    
    @IBOutlet weak var circleCaution: UIView!
    
    @IBOutlet weak var thresholdLabel: UILabel!
        
    @IBOutlet weak var checkmark: UIImageView!
    
    @IBOutlet weak var exclamationmark: UIImageView!
    
    var centralManager: CBCentralManager!
    
    var bluetoothStatus = false
    
    var people = 0
    
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
    let userLicenseAgreement = "The information included in this application is solely for general use and educational purposes and should not be considered, or used as a substitute for, professional, regulated or technical advice. This application does not constitute the practice of any professional advice and is not a replacement for a qualified professional. In no event shall the University of Toronto, the application developers, its contributors, affiliated institutions, and supporting partners, be liable for damages of any kind in connection with the use, misuse, or reliance upon the information provided in this application."
    
    let about = "AroundMe " + String(Bundle.main.releaseVersionNumber ?? "1") + "(" + String(Bundle.main.buildVersionNumber ?? "0") + ") is implemented by Javad Rahimipour Anaraki, and the UI is desgined by Chu Li, to continuously monitor surroundings, keep the user aware of higher risk environments, and remind them to wear PPEs. For more info visit individual.utoronto.ca/jrahimipour/"
    
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
        if value == "CAUTION" {
            circleSafe.isHidden = true
            checkmark.isHidden = true
            circleCaution.isHidden = false
            exclamationmark.isHidden = false
            
        } else {
            circleSafe.isHidden = false
            checkmark.isHidden = false
            circleCaution.isHidden = true
            exclamationmark.isHidden = true
        }
    }
    
    func setCounter(){
        counter.text = "There are \(String(people)) people within \(floor(distance.value)) meters."
    }
    
    func initiate() {
        setStatus(value: "SAFE")
        people = 0
        setCounter()
    }
       
    func vibrate() {
        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        requestNotificationAuthorization()
        initiate()
        appStatus()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(!appDelegate.hasAlreadyLaunched) {
            appDelegate.sethasAlreadyLaunched()
            let alert = UIAlertController(title: "License Agreement", message: userLicenseAgreement, preferredStyle: .alert)
            let declineAction = UIAlertAction(title: "Decline" , style: .destructive) { (action) -> Void in }
            let acceptAction = UIAlertAction(title: "Accept", style: .default) { (action) -> Void in }
            alert.addAction(declineAction)
            alert.addAction(acceptAction)
            //alert.setValue(justifyText(value: userLicenseAgreement), forKey: "attributedMessage")
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func appStatus(){
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc func appMovedToBackground() {
        removeOldNotifications()
        
        let content = UNMutableNotificationContent()
        content.title = "AroundMe"
        content.body = "The app should be stayed open to function"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (10*60), repeats: false)
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        // Schedule the request with the system.
        userNotificationCenter.add(request) { (error) in
            if error != nil {
                // Handle any errors.
            }
        }
    }
    
    func requestNotificationAuthorization() {
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
        
        self.userNotificationCenter.requestAuthorization(options: authOptions) { (success, error) in
            if let error = error {
                print("Error: ", error)
            }
        }
    }
    
    func removeOldNotifications() {
        userNotificationCenter.removeAllDeliveredNotifications()
        userNotificationCenter.removeAllPendingNotificationRequests()
    }
    
    func justifyText(value:String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .justified

        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle
        ]

        let attributedQuote = NSAttributedString(string: value, attributes: attributes)
        return attributedQuote
    }
    
    @IBAction func distanceChanged(_ sender: Any) {
        initiate()
        self.distanceLabel.text = "\(floor(distance.value)) m"
        let trackRect = (sender as AnyObject).trackRect(forBounds: (sender as AnyObject).frame)
        let thumbRect = (sender as AnyObject).thumbRect(forBounds: (sender as AnyObject).bounds, trackRect: trackRect, value: (sender as AnyObject).value)
        self.distanceLabel.center = CGPoint(x: thumbRect.midX + 35, y: self.distanceLabel.center.y)
    }
    
    @IBAction func thresholdChanged(_ sender: Any) {
        initiate()
        self.thresholdLabel.text = "\(Int(floor(threshold.value))) people"
        let trackRect = (sender as AnyObject).trackRect(forBounds: (sender as AnyObject).frame)
        let thumbRect = (sender as AnyObject).thumbRect(forBounds: (sender as AnyObject).bounds, trackRect: trackRect, value: (sender as AnyObject).value)
        self.thresholdLabel.center = CGPoint(x: thumbRect.midX + 35, y: self.thresholdLabel.center.y)    }
    
    @IBAction func activeMonitoring(_ sender: Any) {
        
        if activateSwitch.isOn {
            centralManager = CBCentralManager(delegate: self, queue: nil)
        } else {
            centralManager.stopScan()
            initiate()
        }
    }
    
    @IBAction func infoButton(_ sender: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "About", message: about, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close", style: .default) { (action) -> Void in }
        alert.addAction(closeAction)
        //alert.setValue(justifyText(value: about), forKey: "attributedMessage")
        self.present(alert, animated: true, completion: nil)
    }
}

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
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
            centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey : false])
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
            setCounter()
            
        } else {
            people -= 1
            if people < 0 {
                people = 0
            }
            setCounter()
        }
        
        if (people >= getThreshold()) {
            setStatus(value: "CAUTION")
            vibrate()
            //sleep(2)
        } else {
            setStatus(value: "SAFE")
        }
        
    }
}
