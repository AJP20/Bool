//
//  ViewController.swift
//  TestContact
//
//  Created by Andrew Phillips on 8/27/17.
//  Copyright © 2017 Andrew Phillips. All rights reserved.
//
import UIKit
import CoreBluetooth
import Firebase

//Global var for UID of tapped device *FIX*?
var clickedPeripheral: String!

class HomeViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var centralManager: CBCentralManager!
    var peripherals = Array<CBPeripheral>()
    var peripheralManager: CBPeripheralManager!
    var peripheral: CBPeripheral!
    
    var ref: DatabaseReference?
    
    @IBOutlet weak var tableViewname: UITableView!
    @IBOutlet weak var settingsImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        guard let UUID = UIDevice.current.identifierForVendor?.uuidString else{ return }
        
        self.ref = Database.database().reference()
        ref?.child("Users").observeSingleEvent(of: .value, with: { snapshot in
            if !snapshot.hasChild(UUID){
                self.performSegue(withIdentifier: "RegisterSegue", sender: nil)
            }
        })
        //Tapped settings button *FIX*?
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.imageTapped(gesture:)))
        // add it to the image view
        settingsImage.addGestureRecognizer(tapGesture)
        // make sure imageView can be interacted with by user
        settingsImage.isUserInteractionEnabled = true
        //Check bluetooths state
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard let UID = UIDevice.current.identifierForVendor?.uuidString else{ return }
        switch (central.state) {
        case .poweredOff:
            print("centralManagerDidUpdateState: OFF")
            displayMessage(userMessage: "Please turn bluetooth on.")
        case .poweredOn:
            print("centralManagerDidUpdateState: ON \(String(describing: UID))")
            let serviceUUID = CBUUID(string: "591D25F5-DB0B-4C3E-8A35-B0F61D338FAE")
            centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
        case .unsupported:
            print("Bluetooth not available")
        default: break
        }
    }
    
    func displayMessage(userMessage:String) -> Void{
        DispatchQueue.main.async {
            let alertController = UIAlertController(title:"Alert", message: userMessage, preferredStyle: .alert)
            let OKAction = UIAlertAction(title:"OK", style: .default){(action:UIAlertAction!)in
                DispatchQueue.main.async {}}
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("Peripheral discovered: \(String(describing: peripheral.name))")
        
        if(peripherals.isEmpty && peripheral.name != nil){
            print("Array is empty adding peripheral discovered: \(String(describing: peripheral.name))")
            peripherals.append(peripheral)
            self.tableViewname.reloadData()
        }
        else{
            if(peripheral.name != nil){
                var i = 1
                for perph in peripherals{
                    print("Itteration: \(String(describing: perph.name))")
                    if(peripheral == perph){
                        i = 0
                        print("Peripheral: \(String(describing: perph.name)) already exisits")
                    }
                }
                if(i == 1){
                    print("Adding peripheral: \(String(describing: peripheral.name))")
                    peripherals.append(peripheral)
                    self.tableViewname.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = peripherals[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*** Tapped device in peripherals<> ***/
        
        let clicked = peripherals[indexPath.row]
        print("Tapped device UID: \(clicked)")
        centralManager.stopScan()
        
        centralManager.connect(clicked, options: nil)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            print("peripheralManagerDidUpdateState: ON")
            
            let serviceUUID = CBUUID(string: "591D25F5-DB0B-4C3E-8A35-B0F61D338FAE")
            let characteristicUUID = CBUUID(string: "1F47BB7F-2ED5-4F4F-A252-4018CBF2ED7F")
            
            let service = CBMutableService(type: serviceUUID, primary: true)
            
            let properties: CBCharacteristicProperties = [.read]
            let permissions: CBAttributePermissions = [.readable]
            let characteristic = CBMutableCharacteristic(
                type: characteristicUUID,
                properties: properties,
                value: UIDevice.current.identifierForVendor?.uuidString.data(using: .utf8),
                permissions: permissions)
            service.characteristics = [characteristic]
            peripheralManager.add(service)
        } else if peripheral.state == .poweredOff {
            print("peripheralManagerDidUpdateState: OFF")
            peripheralManager.stopAdvertising()
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager,didAdd service: CBService,error: Error?){
        if let error = error{
            print("peripheralManagerDidAddService Failed… error: \(error)")
            return
        }
        print("peripheralManagerDidAddService: \(service)")
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey : [service.uuid], CBAdvertisementDataLocalNameKey: UIDevice.current.name])
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager,error: Error?){
        if let error = error {
            print("peripheralManagerDidStartAdvertising: Failed… error: \(error)")
            return
        }
        print("peripheralManagerDidStartAdvertising: \(peripheral)")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral){
        print("centralManagerdidConnect to: \(String(describing: peripheral.name))")
        peripheral.delegate = self
        let serviceUUID = CBUUID(string: "591D25F5-DB0B-4C3E-8A35-B0F61D338FAE")
        peripheral.discoverServices([serviceUUID])
    }
    
    func centralManager(_ central: CBCentralManager,didFailToConnect peripheral: CBPeripheral,error: Error?){
        if error != nil{
            print("didFailToConnect: Error: \(String(describing: error))")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?){
        if let error = error {
            print("peripheraldidDiscoverServices: Failed… error: \(error)")
            return
        }
        let characteristicUUID = CBUUID(string: "1F47BB7F-2ED5-4F4F-A252-4018CBF2ED7F")
        for service in peripheral.services!{
            print("peripheraldidDiscoverServices: \(service)")
            peripheral.discoverCharacteristics([characteristicUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?){
        if let error = error {
            print("peripheraldidDiscoverCharacteristics: Failed… error: \(error)")
            return
        }
        for characteristic in service.characteristics!{
            print("peripheraldidDiscoverCharacteristics: \(characteristic)")
            peripheral.readValue(for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?){
        let data = characteristic.value
        clickedPeripheral = String(data: data!, encoding: String.Encoding.utf8) as String!
        print("characteristic.value: \(clickedPeripheral)")
        
        //Check if peripheralID is in DB *ADD*
        ref?.child("Users").observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.hasChild(clickedPeripheral){
                self.performSegue(withIdentifier: "ProfileSegue", sender: nil)
            }
            else{
                self.displayMessage(userMessage: "This device is slacking.")
            }
        })
    }
    
    @objc func imageTapped(gesture: UIGestureRecognizer) {
        if (gesture.view as? UIImageView) != nil {
            print("Settings image has been tapped")
            performSegue(withIdentifier: "EditProfileSegue", sender: nil)
        }
    }
}

