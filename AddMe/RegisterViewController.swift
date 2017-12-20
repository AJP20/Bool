//
//  RegisterViewController.swift
//  etact
//
//  Created by Andrew Phillips on 8/28/17.
//  Copyright © 2017 Andrew Phillips. All rights reserved.
//

import UIKit
import CoreBluetooth
import Firebase

class RegisterViewController: UIViewController,CBCentralManagerDelegate {
    
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
        //Check bluetooths state
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        if(firstName.text?.isEmpty)! || (lastName.text?.isEmpty)! || (phoneNumber.text?.isEmpty)!{
            self.displayMessage(userMessage: "First name, last name, and phone number are required.")
         }
        
        //Activity indicator
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        myActivityIndicator.center = view.center
        myActivityIndicator.hidesWhenStopped = false
        myActivityIndicator.startAnimating()
        view.addSubview(myActivityIndicator)
        
        //Users Bluetooth UID for iPhone
        guard let UID = UIDevice.current.identifierForVendor?.uuidString else{ return }
        
        //Import values into Firebase
        let values = ["firstname": self.firstName.text, "lastname": self.lastName.text, "phonenumber": self.phoneNumber.text, "snapchat": self.snapchat.text, "instagram": self.instagram.text, "twitter": self.twitter.text]
        self.ref = Database.database().reference()
        self.ref?.child("Users").child(UID).setValue(values, withCompletionBlock:{(error: Error?, ref: DatabaseReference) in
            self.removeActivityIndicator(activityIndicator: myActivityIndicator)
            if error != nil{
                self.displayMessage(userMessage: "Error when signing up.")
                return
            }
            else{
                self.displayMessage(userMessage: "Succesful sign up.")
            }
        })
    }
    
    //Register cancel *ADD*
    @IBAction func cancelButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var msg = ""
        switch (central.state) {
        case .poweredOff:
            msg = "Bluetooth switched off"
            displayMessage(userMessage: "Please turn bluetooth on.")
        case .poweredOn:
            msg = "Bluetooth switched on with UID: \(String(describing: UIDevice.current.identifierForVendor?.uuidString))"
        case .unsupported:
            msg = "Bluetooth not available"
            displayMessage(userMessage: msg)
        default: break
        }
        print("Register State: \(msg)")
    }
    
    func displayMessage(userMessage:String) -> Void{
        DispatchQueue.main.async {
            let alertController = UIAlertController(title:"Alert", message: userMessage, preferredStyle: .alert)
            let OKAction = UIAlertAction(title:"OK", style: .default){(action:UIAlertAction!)in
                DispatchQueue.main.async {
                    if(userMessage=="Succesful sign up."){
                        self.dismiss(animated: true, completion: nil)
                    }
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
    
    //bulit in method, act whenever the user touches screen *FIX*?
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
