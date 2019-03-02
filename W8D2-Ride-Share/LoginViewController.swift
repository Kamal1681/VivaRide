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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
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
        

            // [START headless_email_auth]
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
        
//            Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
//                guard let strongSelf = self else { return }
//                // [START_EXCLUDE]
//                strongSelf.hideSpinner {
//                    if let error = error {
//                        strongSelf.showMessagePrompt(error.localizedDescription)
//                        return
//                    }
//                    strongSelf.navigationController?.popViewController(animated: true)
//                }
//                // [END_EXCLUDE]
//            }
//            // [END headless_email_auth]

        
//        self.dismiss(animated: true, completion: nil)


    }
    
    @IBAction func signUpButton(_ sender: UIButton) {
    }
    
    
    @IBAction func fogotPassButton(_ sender: UIButton) {
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
