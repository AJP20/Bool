//
//  ProfileViewController.swift
//  etact
//
//  Created by Andrew Phillips on 9/17/17.
//  Copyright © 2017 Andrew Phillips. All rights reserved.
//

import UIKit
import Contacts
import FirebaseDatabase

class ProfileViewController: UIViewController {
    
    var ref: DatabaseReference?
    var refHandle: DatabaseHandle?
    var fname=""
    var lname=""
    var pnum=""
    var snap=""
    var insta=""
    var twit=""
    
    @IBOutlet weak var profileName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Activity indicator *ADD* allowed in viewDidLoad()?
        
        self.ref = Database.database().reference()
        
        //Loads profile based off global var clickedUID
        ref?.child("Users").child(clickedPeripheral).observeSingleEvent(of: .value, with: { snapshot in
            let snapshotValue = snapshot.value as? NSDictionary
            self.fname = snapshotValue!["firstname"] as! String
            self.lname = snapshotValue!["lastname"] as! String
            self.pnum = snapshotValue!["phonenumber"] as! String
            self.snap = snapshotValue!["snapchat"] as! String
            self.insta = snapshotValue!["instagram"] as! String
            self.twit = snapshotValue!["twitter"] as! String
            self.profileName.text = self.fname+" "+self.lname
        })
    }
    
    func displayMessage(userMessage:String) -> Void{
        DispatchQueue.main.async {
            let alertController = UIAlertController(title:"Alert", message: userMessage, preferredStyle: .alert)
            let OKAction = UIAlertAction(title:"OK", style: .default){(action:UIAlertAction!)in
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func snapchatButton(_ sender: UIButton) {
        let snapchatExtention = "snapchat://add/"+snap
        let snapchatUrl = URL(string: snapchatExtention)
        if UIApplication.shared.canOpenURL(snapchatUrl! as URL)
        {
            UIApplication.shared.open(snapchatUrl!)
            
        } else {
            //Opens current app in the app store if URL can't open
            UIApplication.shared.open(URL(string: "https://itunes.apple.com/in/app/snapchat/id447188370?mt=8")!)
        }
    }
    
    @IBAction func instagramButton(_ sender: UIButton) {
        let instagramExtention = "instagram://user?username="+insta
        let instagramUrl = URL(string: instagramExtention)
        if UIApplication.shared.canOpenURL(instagramUrl! as URL)
        {
            UIApplication.shared.open(instagramUrl!)
            
        } else {
            //Opens current app in the app store if URL can't open
            UIApplication.shared.open(URL(string: "https://itunes.apple.com/in/app/instagram/id389801252?m")!)
        }
    }
    
    @IBAction func twitterButton(_ sender: UIButton) {
        let twitterExtention = "twitter://user?screen_name="+twit
        let twitterUrl = URL(string: twitterExtention)
        if UIApplication.shared.canOpenURL(twitterUrl! as URL)
        {
            UIApplication.shared.open(twitterUrl!)
            
        } else {
            //Opens current app in the app store if URL can't open
            UIApplication.shared.open(URL(string: "https://itunes.apple.com/in/app/twitter/id333903271?mt=8")!)
        }
    }
    
    //*ADD*
    @IBAction func facebookButton(_ sender: UIButton) {
        let facebookExtention = "fb://profile/1473315556"
        let facebookUrl = URL(string: facebookExtention)
        if UIApplication.shared.canOpenURL(facebookUrl! as URL)
        {
            UIApplication.shared.open(facebookUrl!)
            
        } else {
            //opens current app in the app store if URL can't open
            UIApplication.shared.open(URL(string: "https://itunes.apple.com/in/app/facebook/id284882215?mt=8")!)
        }
    }
    
    @IBAction func phoneNumberButton(_ sender: UIButton) {
        
        // Creating a mutable object to add to the contact
        let contact = CNMutableContact()
        
        contact.givenName = fname
        contact.familyName = lname
        
        //let homeEmail = CNLabeledValue(label:CNLabelHome, value:"ajp20@live.com")
        //contact.emailAddresses = [homeEmail]
        
        contact.phoneNumbers = [CNLabeledValue(
            label:CNLabelPhoneNumberiPhone,
            value:CNPhoneNumber(stringValue:pnum))]
        
        /*let homeAddress = CNMutablePostalAddress()
        homeAddress.street = "32 Fraser Dr"
        homeAddress.city = "Salem"
        homeAddress.state = "NH"
        homeAddress.postalCode = "03079"
        contact.postalAddresses = [CNLabeledValue(label:CNLabelHome, value:homeAddress)]
        
        let birthday = NSDateComponents()
        birthday.day = 30
        birthday.month = 4
        birthday.year = 1997  // You can omit the year value for a yearless birthday
        contact.birthday = birthday as DateComponents*/
        
        // Saving the newly created contact
        let store = CNContactStore()
        let saveRequest = CNSaveRequest()
        saveRequest.add(contact, toContainerWithIdentifier:nil)
        try! store.execute(saveRequest)
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        //*FIX*
        self.dismiss(animated: true, completion: nil)
    }
}
