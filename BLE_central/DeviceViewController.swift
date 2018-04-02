//
//  DeviceViewController.swift
//  BLE_central
//
//  Created by qsc on 2018/3/30.
//  Copyright © 2018年 zerozero. All rights reserved.
//

import UIKit
import NetworkExtension

class DeviceViewController: UIViewController {

    @IBOutlet weak var logView: UITextView!
    
    var device: BLEDevice?
    
    var SSID: String?
    var password: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        device?.log = { [unowned self] content in
            self.log(content)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard device != nil else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        device?.prepare()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        device?.log = nil
    }
    
    @IBAction func didPressConnect(_ sender: Any) {
        connectToWiFi()
    }
    
    @IBAction func didPressClear(_ sender: Any) {
        self.logView.text.removeAll()
    }
    
    @IBAction func didPressCmd1(_ sender: Any) {
        device?.sendCommand(cmd: [0xff, 0xf0]) {[unowned self] data in
            if let ssid = String(data: data, encoding: .utf8) {
                self.SSID = ssid
                print("receive SSID:\(ssid)")
            }
            
        }
    }
    
    @IBAction func didPressCmd2(_ sender: Any) {
        device?.sendCommand(cmd: [0xff, 0xf1]) {[unowned self] data in
            if let passwd = String(data: data, encoding: .utf8) {
                self.password = passwd
                print("receive password:\(passwd)")
            }
        }
    }
    
    
    func log(_ items: Any...) {
        self.logView.text.append("\n")
        self.logView.text.append(String(describing: items))
    }
    
    func connectToWiFi() {
        guard let ssid = self.SSID, let password = self.password else {
            log("ssid: \(String(describing: self.SSID)) and password: \(String(describing: self.password)) not valid ")
            return
        }
        
        let config = NEHotspotConfiguration(ssid: ssid, passphrase: password, isWEP: false)
        NEHotspotConfigurationManager.shared.apply(config) { (error) in
            self.log("apply wifi \(ssid) finished, error:\(String(describing: error))")
        }
    }
    
}
