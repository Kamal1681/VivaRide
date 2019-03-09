//
//  BookRideConfirmationViewController.swift
//  W8D2-Ride-Share
//
//  Created by Pavel on 2019-02-28.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit

class BookRideConfirmationViewController: UIViewController {
    //Passing properties
    var ride: Ride!
    
    //UI properties
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(ride.userInfo?.name ?? "Did not pass driver name throuht sefue")
        // Do any additional setup after loading the view.
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
