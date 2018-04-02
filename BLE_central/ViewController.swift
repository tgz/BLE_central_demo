//
//  ViewController.swift
//  BLE_central
//
//  Created by qsc on 2018/3/29.
//  Copyright © 2018年 zerozero. All rights reserved.
//

import UIKit
import CoreBluetooth

private let SerivceUUID: String = "7C40"
private let CharacteristicUUID: String = "7c4003e7-e889-46db-a124-e1ac994f8113"

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var bleManager = BLEManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bleManager.processScanResult = { [unowned self] peripheral, rssi in
            self.addOrUpdateFoundedDevice(peripheral, rssi)
        }
        
        bleManager.deviceConnected = { [unowned self] device in
            
            guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeviceViewController") as? DeviceViewController else {
                print("no target viewcontroller!")
                
                return
            }
            
            vc.device = device
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        bleManager.setup()
    }
    
    @IBAction func didPressRefresh(_ sender: Any) {
        bleManager.stopScan()
        bleManager.clean()
        
        tableView.reloadData()
        
        bleManager.startScan()
    }
    
    func addOrUpdateFoundedDevice(_ peripheral: CBPeripheral,_ rssi: Int) {
        if let index = bleManager.devices.index(where: {d in d.peripheral == peripheral}) {
            // update row for index
            bleManager.devices[index].rssi = rssi
            let indexPath = IndexPath(row: index, section: 0)
            
            (tableView.cellForRow(at: indexPath) as? DeviceTableViewCell)?.rssi.text = "\(rssi)"
        } else {
            let d = BLEDevice(peripheral: peripheral)
            d.rssi = rssi
            bleManager.devices.append(d)
            if bleManager.devices.count == 1 {
                tableView.reloadData()
            } else {
                let index = IndexPath(row: bleManager.devices.count - 1, section: 0)
                tableView.insertRows(at: [index], with: .automatic)
            }
        }
    }
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bleManager.devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DeviceTableViewCell.reuseID, for: indexPath) as! DeviceTableViewCell
        
        let d = bleManager.devices[indexPath.row]
        cell.name.text = (d.peripheral.name ?? "<null>")
        if let rssi = d.rssi {
            cell.rssi.text = "\(rssi)"
        } else {
            cell.rssi.text = "--"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        bleManager.stopScan()
        bleManager.connectDevice(at: indexPath.row)
        
    }
}
