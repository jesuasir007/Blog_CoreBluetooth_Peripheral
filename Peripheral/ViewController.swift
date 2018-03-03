//
//  ViewController.swift
//  Peripheral
//
//  Created by Uy Nguyen Long on 1/5/18.
//  Copyright © 2018 Uy Nguyen Long. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBPeripheralManagerDelegate {

    var peripheralManager: CBPeripheralManager!
    
    let kServiceUUID = "1FA2FD8A-17E0-4D3B-AF45-305DA6130E39" // uuidgen
    let kCharacteristicUUID = "463FED20-DA93-45E7-B00F-B5CD99775150"
    let kCharacteristicUUID2 = "463FED21-DA93-45E7-B00F-B5CD99775150"
    let kCharacteristicUUID3 = "463FED22-DA93-45E7-B00F-B5CD99775150"
    
    var service: CBMutableService? = nil
    
    var myValue = "Uy Nguyen blog."
    
    var chars : [String: CBCharacteristic]  = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error = error {
            print("Add service failed: \(error.localizedDescription)")
            return
        }
        print("Add service Succeeded")
        print("Chars \(service.characteristics)")
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("Start advertising failed: \(error.localizedDescription)")
            return
        }
        print("Start advertising Succeeded")
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        print("peripheralManagerIsReady")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        print("Read request")
        
        if request.characteristic.uuid.uuidString == kCharacteristicUUID3 {
            request.value = self.chars[kCharacteristicUUID3]!.value!
        }
        else {
            request.value = myValue.data(using: .utf8)
        }
        
        peripheral.respond(to: request, withResult: .success)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("Subcribe to chars \(characteristic.uuid.uuidString)")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        print("Unsubcribe to chars \(characteristic.uuid.uuidString)")
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        print("Write request")
        self.myValue = String.init(data: requests[0].value!, encoding: .utf8)!
        peripheral.respond(to: requests[0], withResult: .success)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("peripheralManagerDidUpdateState \(peripheral.state.rawValue)")
        
        if peripheral.state == .poweredOn {
            let serviceUUID = CBUUID(string: kServiceUUID)
            self.service = CBMutableService(type: serviceUUID, primary: true)
            
            let readWriteChar = CBMutableCharacteristic.init(
                type: CBUUID(string: kCharacteristicUUID),
                properties: [.read, .write, .notify],
                value: nil,
                permissions: [CBAttributePermissions.readable, CBAttributePermissions.writeable])
            
            let encryptedChar = CBMutableCharacteristic.init(
                type: CBUUID(string: kCharacteristicUUID2),
                properties: [.read, .notify, .notifyEncryptionRequired],
                value: nil,
                permissions: [.readable])
            
            let readOnlyChar = CBMutableCharacteristic.init(
                type: CBUUID(string: kCharacteristicUUID3),
                properties: [.read],
                value: "Hahaha".data(using: .utf8),
                permissions: [.readable])
            
            chars[kCharacteristicUUID] = readWriteChar
            chars[kCharacteristicUUID2] = encryptedChar
            chars[kCharacteristicUUID3] = readOnlyChar
            
            self.service?.characteristics = []
            self.service?.characteristics?.append(readWriteChar)
            self.service?.characteristics?.append(encryptedChar)
            self.service?.characteristics?.append(readOnlyChar)
            
            self.peripheralManager.add(self.service!)
            
            peripheralManager.startAdvertising([CBAdvertisementDataLocalNameKey: "Titan",
                                                CBAdvertisementDataServiceUUIDsKey : [self.service!.uuid]])
        }
    }

}

