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
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
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
    
    @IBAction func changePasswordButtonDidTap(_ sender: UIButton) {
        updatePassword(alertTitle: "Edit your password", alertFirstPlaceHolder: "Enter your new password", alertSecondPlaceHolder: "Repeat your new password")
    }
    
    @IBAction func editPhoto(_ sender: UIButton) {
    }
    
    @IBAction func editNameButton(_ sender: Any) {
        editAlert(alertTitle: "Edit your name", alertPlaceHolder: "Enter your name", fieldName: "name", label: nameLabel)
    }
    
    
    @IBAction func editEmailButton(_ sender: Any) {
        updateEmail(alertTitle: "Edit your email", alertPlaceHolder: "Enter your email")
    }
    
    @IBAction func editPhoneNumberButton(_ sender: Any) {
        editAlert(alertTitle: "Edit your phone number", alertPlaceHolder: "Enter your  phone number", fieldName: "phoneNumber", label: phoneNumberLabel)
    }
    
    @IBAction func editCarModelButton(_ sender: Any) {
        editAlert(alertTitle: "Edit your car model", alertPlaceHolder: "Enter your car model", fieldName: "carModel", label: carModelLabel)
    }
    
    @IBAction func editCarColorButton(_ sender: Any) {
        editAlert(alertTitle: "Edit your car color", alertPlaceHolder: "Enter your car color", fieldName: "carColor", label: carColorLabel)
    }
    
    //MARK: - Edit alert

    func editAlert(alertTitle: String, alertPlaceHolder: String, fieldName: String, label: UILabel) {
        var editNewValue: String = ""
        
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
                        self.errorAlert(errorMessage: err.localizedDescription)
                        print(err.localizedDescription)
                    } else {
                        editNewValue = nameTextField.text ?? ""
                        label.text = editNewValue
                        self.view.setNeedsLayout()
                        self.view.layoutIfNeeded()
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
    }
    
    //MARK: - Update password in Firebase
    
    func updatePassword(alertTitle: String, alertFirstPlaceHolder: String, alertSecondPlaceHolder: String) {
        let alertController = UIAlertController(title: alertTitle, message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = alertFirstPlaceHolder
            textField.isSecureTextEntry = true
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = alertSecondPlaceHolder
            textField.isSecureTextEntry = true
        }
        
        let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let passwordFirstTextField = alertController.textFields![0] as UITextField
            guard let newPassword = passwordFirstTextField.text else {return}
            let passwordSecondTextField = alertController.textFields![1] as UITextField
            guard let newPasswordRepeat = passwordSecondTextField.text else {return}
            
            if newPassword == newPasswordRepeat {

                if let user = self.user {
                    user.updatePassword(to: newPassword) { (error) in
                        if error == nil {
                            print("Password successfully updated!")
                        }
                        else {
                            self.errorAlert(errorMessage: error!.localizedDescription)
                            print(error!.localizedDescription)
                        }
                    }
                }
                else {
                    print("Error! User do not login")
                }
            }
            else {
                self.errorAlert(errorMessage: "Password do not match!")
            }
            
            

        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - Update email in Firebase
    
    func updateEmail(alertTitle: String, alertPlaceHolder: String) {
        let alertController = UIAlertController(title: alertTitle, message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = alertPlaceHolder
        }
        
        let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let emailTextField = alertController.textFields![0] as UITextField
            guard let newEmail = emailTextField.text else {return}
            
            if let user = self.user {
                user.updateEmail(to: newEmail) { (error) in
                    if error == nil {
                        self.emailLabel.text = newEmail
                        self.view.setNeedsLayout()
                        self.view.layoutIfNeeded()
                        print("Email successfully updated!")
                    }
                    else {
                        self.errorAlert(errorMessage: error!.localizedDescription)
                        print(error!.localizedDescription)
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
    }
    
    //MARK: - Get profile info from Firebase and set labels
    
    func setProfileLabelsFromFirebase() {
        if let user = user {
            let email = user.email
            self.emailLabel.text = email
            
            self.db.collection("users").whereField("uid", isEqualTo: user.uid).getDocuments { (snapshot, err) in
                if let err = err {
                    self.errorAlert(errorMessage: err.localizedDescription)
                    print("Error getting documents: \(err.localizedDescription)")
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
    
    func errorAlert(errorMessage: String) {
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
