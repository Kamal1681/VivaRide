//
//  ProfileViewController.swift
//  W8D2-Ride-Share
//
//  Created by Pavel on 2019-02-28.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var photoLabel: UIImageView!
    @IBOutlet weak var carModelLabel: UILabel!
    @IBOutlet weak var carColorLabel: UILabel!
    
    var db: Firestore!
    
    var name: String = ""
    var phoneNumber: String = ""
    var email: String = ""
    var carModel: String = ""
    var carColor: String = ""
    
    var user: FirebaseAuth.User?
    var handle: AuthStateDidChangeListenerHandle? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // [START setup]
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // START auth_listener
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.user = user
            self.setProfileLabelsFromFirebase()
        }
        // END auth_listener
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // START remove_auth_listener
        Auth.auth().removeStateDidChangeListener(handle!)
        // END remove_auth_listener
    }

    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signOutButtonDidTap(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func editNameButton(_ sender: Any) {
        nameLabel.text = editAlert(alertTitle: "Edit your name", alertPlaceHolder: "Enter your name", fieldName: "name")
    }
    
    
    @IBAction func editEmailButton(_ sender: Any) {

    }
    
    @IBAction func editPhoneNumberButton(_ sender: Any) {
        phoneNumberLabel.text = editAlert(alertTitle: "Edit your phone number", alertPlaceHolder: "Enter your  phone number", fieldName: "phoneNumber")
    }
    
    @IBAction func editCarModelButton(_ sender: Any) {
        carModelLabel.text = editAlert(alertTitle: "Edit your car model", alertPlaceHolder: "Enter your car model", fieldName: "carModel")
    }
    
    @IBAction func editCarColorButton(_ sender: Any) {
        carColorLabel.text = editAlert(alertTitle: "Edit your car color", alertPlaceHolder: "Enter your car color", fieldName: "carColor")
    }
    
    //MARK: - Edit alert

    func editAlert(alertTitle: String, alertPlaceHolder: String, fieldName: String) -> String {
        var editStringValue: String = ""
        
        let alertController = UIAlertController(title: alertTitle, message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = alertPlaceHolder
        }
        
        let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let nameTextField = alertController.textFields![0] as UITextField
            
            //Update information in Firebase
            if let user = self.user {
                self.db.collection("users").document(user.uid).setData([ fieldName: nameTextField.text ?? "" ], merge: true) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        editStringValue = nameTextField.text ?? ""
                        print("Document successfully written!")
                    }
                }
            }
            else {
                print("Error! User do not login")
            }
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
        return editStringValue
    }
    
    
    //MARK - Get profile info from Firebase and set labels
    
    func setProfileLabelsFromFirebase() {
        if let user = user {
            let email = user.email
            self.emailLabel.text = email
            
            self.db.collection("users").whereField("uid", isEqualTo: user.uid).getDocuments { (snapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    let document = snapshot!.documents[0]
                    let docId = document.documentID
                    self.name = document.get("name") as? String ?? "Unknown name"
                    self.phoneNumber = document.get("phoneNumber") as? String ?? "Unknown phone number"
                    self.carModel = document.get("carModel") as? String ?? "Unknown car model"
                    self.carColor = document.get("carColor") as? String ?? "Unknown car color"
                    print(docId, self.name, self.phoneNumber, self.carModel, self.carColor)
                    
                    //Set labels with information from Firebase
                    OperationQueue.main.addOperation {
                        self.nameLabel.text = self.name
                        self.phoneNumberLabel.text = self.phoneNumber
                        self.carModelLabel.text = self.carModel
                        self.carColorLabel.text = self.carColor
                    }
                }
            }
        }
        else {
            print("Error! User do not login")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
