//
//  MenuViewController.swift
//  W8D2-Ride-Share
//
//  Created by Pavel on 2019-02-28.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit

// [START usermanagement_view_import]
import Firebase
// [END usermanagement_view_import]

class MenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Firebase check for autentification
        if Auth.auth().currentUser != nil {
            print("User auth")
        } else {
            print("user not auth")
            performSegue(withIdentifier: "goLoginVC", sender: nil)
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
