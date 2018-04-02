//
//  BLEManager.swift
//  BLE_central
//
//  Created by qsc on 2018/3/30.
//  Copyright © 2018年 zerozero. All rights reserved.
//

import Foundation
import CoreBluetooth

let bleQueue = DispatchQueue(label: "com.zerozero.ble_central")

class BLEManager: NSObject {
    
    private var centralManager: CBCentralManager?
    
    var devices = [BLEDevice]()
    
    var connectingIndex = -1
    
    var processScanResult: ((_ peripheral: CBPeripheral, _ rssi: Int) -> ())?
    
    var deviceConnected: ((_ device: BLEDevice) -> ())?
    
    override init() {
        super.init()
    }
    
    func setup() {
        centralManager = CBCentralManager(delegate: self, queue: .main)
    }
    
    func startScan() {
        centralManager?.scanForPeripherals(withServices:[CBUUID(string: BLEDevice.ServiceUUID)],
                                           options: [CBCentralManagerScanOptionAllowDuplicatesKey: NSNumber(booleanLiteral: false)])
        
    }
    
    func clean() {
        devices.removeAll()
    }
    
    func stopScan() {
        centralManager?.stopScan()
    }
    
    func connectDevice(at index: Int) {
        connectingIndex = index
        centralManager?.connect(devices[index].peripheral, options: nil)
    }
    
    func disconnect() {
        centralManager?.cancelPeripheralConnection(devices[connectingIndex].peripheral)
    }
}

extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let log_perfix = "central state changed: "
        
        var state = ""
        
        switch central.state {
        case .unknown:
            state = "unknown"
        case .poweredOff:
            state = "poweredOff"
        case .poweredOn:
            startScan()
            state = "poweredOn"
        case .resetting:
            state = "resetting"
        case .unauthorized:
            state = "unauthorized"
        case .unsupported:
            state = "unsupported"
        }
        
        print("\(log_perfix)\(state)")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("discover peripheral:\(String(describing: peripheral.name)), RSSI:\(RSSI)")
        
        processScanResult?(peripheral, RSSI.intValue)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard devices[connectingIndex].peripheral == peripheral else {
            print("connected peripheral is not wanted！")
            return
        }
        
        let device = devices[connectingIndex]
        peripheral.delegate = device
        print("已连接设备：\(String(describing: peripheral.name))")
        
        deviceConnected?(device)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("连接设备 \(String(describing: peripheral.name)) 失败: \(error.debugDescription)")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("设备 \(String(describing: peripheral.name)) 断开连接")
    }
}
