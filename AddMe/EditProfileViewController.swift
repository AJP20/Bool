//
//  EditProfileViewController.swift
//  AddMe
//
//  Created by Andrew Phillips on 10/2/17.
//  Copyright © 2017 Andrew Phillips. All rights reserved.
//

import UIKit
import CoreBluetooth
import Firebase

class EditProfileViewController: UIViewController,CBCentralManagerDelegate {
    
    var manager: CBCentralManager!
    var ref: DatabaseReference?
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var snapchat: UITextField!
    @IBOutlet weak var instagram: UITextField!
    @IBOutlet weak var twitter: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        manager = CBCentralManager(delegate: self, queue: nil)
        self.ref = Database.database().reference()
        
        guard let UID = UIDevice.current.identifierForVendor?.uuidString else{ return }
        ref?.child("Users").child(UID).observeSingleEvent(of: .value, with: { snapshot in
            let snapshotValue = snapshot.value as? NSDictionary
            self.firstName.text = snapshotValue!["firstname"] as? String
            self.lastName.text = snapshotValue!["lastname"] as? String
            self.phoneNumber.text = snapshotValue!["phonenumber"] as? String
            self.snapchat.text = snapshotValue!["snapchat"] as? String
            self.instagram.text = snapshotValue!["instagram"] as? String
            self.twitter.text = snapshotValue!["twitter"] as? String
        })
        
    }
    
    @IBAction func updateButton(_ sender: UIButton) {
        //Activity indicator
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        myActivityIndicator.center = view.center
        myActivityIndicator.hidesWhenStopped = false
        myActivityIndicator.startAnimating()
        view.addSubview(myActivityIndicator)
        
        //Updates values in Firebase based
        let values = ["firstname": self.firstName.text, "lastname": self.lastName.text, "phonenumber": self.phoneNumber.text, "snapchat": self.snapchat.text, "instagram": self.instagram.text, "twitter": self.twitter.text]
        self.ref = Database.database().reference()
        guard let uid = UIDevice.current.identifierForVendor?.uuidString else{ return }
        ref?.child("Users").child(uid).updateChildValues(values, withCompletionBlock:{(error: Error?, ref: DatabaseReference) in
            self.removeActivityIndicator(activityIndicator: myActivityIndicator)
            if error != nil{
                self.displayMessage(userMessage: "Error.")
                return
            }
            else{
                self.displayMessage(userMessage: "Succesful.")
            }
        })
        
    }
    
    @IBAction func cancelButton(_ sender: UIButton) {
        //*FIX*
        self.dismiss(animated: true, completion: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var msg = ""
        switch (central.state) {
            
        case .poweredOff:
            msg = "Bluetooth switched off"
            displayMessage(userMessage: "Please turn bluetooth on.")
        case .poweredOn:
            msg = "Bluetooth switched on. ID : \(UIDevice.current.identifierForVendor!.uuidString)"
            manager.scanForPeripherals(withServices: nil, options:nil)
        case .unsupported:
            msg = "Bluetooth not available"
        default: break
        }
        print("State: \(msg)")
    }
    
    func displayMessage(userMessage:String) -> Void{
        DispatchQueue.main.async {
            let alertController = UIAlertController(title:"Alert", message: userMessage, preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title:"OK", style: .default){(action:UIAlertAction!)in
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: {})
                }
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    func removeActivityIndicator(activityIndicator: UIActivityIndicatorView){
        DispatchQueue.main.async {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
    }
    
    //bulit in method, act whenever the user touches screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
