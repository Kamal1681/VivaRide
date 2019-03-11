//
//  RegisterEmailViewController.swift
//  W8D2-Ride-Share
//
//  Created by Pavel on 2019-03-01.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit
import Firebase

class RegisterEmailViewController: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var repeatPasswordField: UITextField!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signUpButton.configure(button: signUpButton)
        // [START setup]
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        
        //Helps to check names with apostrof
        nameField.smartQuotesType = .no
    }
    
    @IBAction func backButtonDidTap(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUpButtonDidTap(_ sender: UIButton) {
        sender.pressed()
        let name = nameField.text
        let email = emailField.text
        let password = passwordField.text
        let repeatPassword = repeatPasswordField.text
        let phoneNumber = phoneNumberField.text
        
        //Check email and password is empty
        if (email == "" || password == "" || repeatPassword == "") || (email == nil || password == nil || repeatPassword == nil) {
            let alert = UIAlertController(title: "Alert", message: "Email or Password can not be empty!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
            
        //Check email is valid
        else if !isValidEmail(email: email!) {
            let alert = UIAlertController(title: "Alert", message: "Email is not valid! Please check your email address.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            emailField.backgroundColor = UIColor.red
        }
            
        //Check password match repeated password
        else if password != repeatPassword {
            let alert = UIAlertController(title: "Alert", message: "Passwords not match.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            passwordField.backgroundColor = UIColor.red
            repeatPasswordField.backgroundColor = UIColor.red
        }
            
        //Check pasword is valid
        else if !isPasswordValid(password: password!) {
            let alert = UIAlertController(title: "Alert", message: "Passwords is not valid. Ensure that your password has at least 1 uppercase letter, 1 special case letter, 1 digit and 1 lowercase letter. Passwords must be at least 8 characters in length.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            passwordField.backgroundColor = UIColor.red
            repeatPasswordField.backgroundColor = UIColor.red
        }
            
        //Check phone number is valid
        else if !isPhoneNumberValid(phoneNumber: phoneNumber!) {
            let alert = UIAlertController(title: "Alert", message: "Phone number is not valid. Phone number must have this format: +16471112233.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            phoneNumberField.backgroundColor = UIColor.red
        }
        
        //Check name is valid
        else if !isNameValid(name: name!) {
            let alert = UIAlertController(title: "Alert", message: "Name is not valid.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            nameField.backgroundColor = UIColor.red
        }
            
        //Create user if everything is good
        else {
            
            //Creating new user in Firebase
            Auth.auth().createUser(withEmail: email!, password: password!) { authResult, error in
                guard let authResult = authResult, error == nil else {
                    
                    //Error during creting new user from Firebase
                    print(error!.localizedDescription)
                    
                    if let errCode = AuthErrorCode(rawValue: error!._code) {
                        switch errCode {
                        
                        //Invalid email
                        case .invalidEmail:
                            let alert = UIAlertController(title: "Alert", message: "Email is not valid! Please check your email address.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            self.emailField.backgroundColor = UIColor.red
                        
                        //Email is already in use
                        case .emailAlreadyInUse:
                            let alert = UIAlertController(title: "Alert", message: "The email address is already in use by another account! Please check your email address or use Fogot the password form.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            self.emailField.backgroundColor = UIColor.red
                            
                        //Any other errors will present on the screen
                        default:
                            let alert = UIAlertController(title: "Alert", message: error!.localizedDescription, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            print("Create User Error: \(error!)")
                        }
                    }
                    
                    return
                }
            
                //Login as a new user to be able to add aditional infromation about user to Firebase
                
                Auth.auth().signIn(withEmail: email!, password: password!, completion: { (authDataResult, errorCurrent) in
                    if authDataResult != nil {
                        //Get user UID
                        let user = Auth.auth().currentUser
                        if user != nil {
                            
                            //Input additional information about useer to the Firebase
                            self.db.collection("users").document(user!.uid).setData([
                                "uid": user!.uid,
                                "name": name!,
                                "phoneNumber": phoneNumber!
                            ], merge: true) { err in
                                if let err = err {
                                    print("Error writing document: \(err)")
                                } else {
                                    print("Additional user information successfully written in Firebase!")
                                }
                            }
                            
                            //Print some information about authentification
                            print("\(authResult.user.email!) created")
                            
                            //Make all text field white
                            self.nameField.backgroundColor = UIColor.white
                            self.emailField.backgroundColor = UIColor.white
                            self.passwordField.backgroundColor = UIColor.white
                            self.repeatPasswordField.backgroundColor = UIColor.white
                            self.phoneNumberField.backgroundColor = UIColor.white
                            
                            //Alert that user is successfully registered and logged in
                            let alert = UIAlertController(title: "Alert", message: "You have been successfully registered and logged in.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                                self.dismiss(animated: true, completion: nil)
                            }))
                            self.present(alert, animated: true, completion: nil)
                            
                        }
                        else {
                            print("Error has happend during autologin process after creating a new user.")
                            return
                        }
                    }
                })

            }
            
        }
        
    }
    
    //MARK: - Validate email function
    func isValidEmail(email : String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    //MARK: - Validate password function
    func isPasswordValid(password : String) -> Bool {
        let passwordRegEx = "^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z]).{8,}$"
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: password)
    }
    
    //MARK: - Validate phone number
    func  isPhoneNumberValid(phoneNumber: String) -> Bool {
        let phoneNumberRegex = "^[+][0-9]{11}$"
        
        let phoneNumberTest = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex)
        return phoneNumberTest.evaluate(with: phoneNumber)
    }
    
    //MARK: - Validate name
    func isNameValid(name: String) -> Bool {
        let nameRegex = "^[A-Z][a-zA-Z ']*"
        
        let nameTest = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        return nameTest.evaluate(with: name)
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
