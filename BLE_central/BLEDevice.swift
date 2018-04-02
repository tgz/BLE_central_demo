//
//  BLEDevice.swift
//  BLE_central
//
//  Created by qsc on 2018/3/30.
//  Copyright © 2018年 zerozero. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLEDevice: NSObject {
    
    static let ServiceUUID: String = "7C40"
    static let CharacteristicUUID: String = "7c4003e7-e889-46db-a124-e1ac994f8113"

    
    let peripheral: CBPeripheral
    var characteristic: CBCharacteristic? = nil
    var rssi: Int?
    
    typealias CommandCallback = (Data) -> Void
    
    var commandCallback: CommandCallback?
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
    }
    
    func prepare() {
        peripheral.discoverServices([CBUUID(string: BLEDevice.ServiceUUID)])
    }
    
    func sendCommand(cmd: [UInt8], response: CommandCallback?) {
        guard let c = characteristic else {
            log?("no characteristic, can not send command")
            return
        }
        commandCallback = response
        peripheral.writeValue(Data(bytes: cmd), for: c, type: .withResponse)
    }

    var log: ((String) -> Void)?
}

extension BLEDevice: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services, services.count > 0 else {
            print("peripheral service is empty")
            log?("peripheral service is empty")
            return
        }
        for svs in services {
            print("发现服务：\(svs)")
            log?("发现服务：\(svs)")
            peripheral.discoverCharacteristics([CBUUID(string: BLEDevice.CharacteristicUUID)], for: svs)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics, characteristics.count > 0 else {
            print("peripheral characteristics is empty")
            log?("peripheral characteristics is empty")
            return
        }
        for charact in characteristics {
            print("发现特征：\(charact)")
            log?("发现特征：\(charact)")
        }
        
        characteristic = characteristics.last!
        
        peripheral.setNotifyValue(true, for: characteristic!)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let err = error {
            print("订阅失败：\(err)")
            log?("订阅失败：\(err)")
        }
        
        if characteristic.isNotifying {
            print("订阅成功")
            log?("订阅成功")
        } else {
            print("订阅取消")
            log?("订阅取消")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        print("update value:\(String(data: characteristic.value!, encoding: .utf8) ?? "--")")
        
        log?("update value:\(String(data: characteristic.value!, encoding: .utf8) ?? "--")")
        
        if let callback = commandCallback, let data = characteristic.value {
            callback(data)

            commandCallback = nil
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didWriteValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        print("write value finished,error:\(error)")
        log?("write value finished,error:\(error)")
    }
}
