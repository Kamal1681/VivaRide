//
//  LoginViewController.swift
//  W8D2-Ride-Share
//
//  Created by Pavel on 2019-02-28.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var fogotPassButton: UIButton!
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var originalViewHeight: CGFloat = 0.0
    var viewHeight: CGFloat = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //If keyboard appears/hide view size will change
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        originalViewHeight = self.view.frame.size.height
        viewHeight = self.view.frame.size.height
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // If user already login go to previous VC
        if Auth.auth().currentUser != nil {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true)
//    }
    
    @IBAction func signInButton(_ sender: UIButton) {
        
        guard let email = self.emailField.text, let password = self.passwordField.text else {
            print("Error")
            return
        }
        
        if email == "" || password == "" {
            let alert = UIAlertController(title: "Alert", message: "Email or Password can not be empty!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, errorCurrent) in
                if authDataResult != nil {
                    self.dismiss(animated: true, completion: nil)
                }
                else {
                    let alert = UIAlertController(title: "Alert", message: "Email and/or Password is incorrect!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    print(authDataResult ?? "No authDataResult")
                }
            
        }

    }
    
    @IBAction func signUpButton(_ sender: UIButton) {
    }
    
    
    @IBAction func fogotPassButton(_ sender: UIButton) {
    }
    
    
    //MARK: Keyboard appears/hide view size
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if viewHeight == originalViewHeight {
                viewHeight -= keyboardSize.height
                self.view.frame.size.height = viewHeight
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if viewHeight != originalViewHeight {
            self.viewHeight = self.originalViewHeight
            self.view.frame.size.height = self.viewHeight
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func emailEditingDidEnd(_ sender: Any) {
        emailField.resignFirstResponder()
    }
    @IBAction func passwordEditingDidEnd(_ sender: Any) {
        passwordField.resignFirstResponder()
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
