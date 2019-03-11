//
//  BookedRideDetailsViewController.swift
//  W8D2-Ride-Share
//
//  Created by Pavel on 2019-02-28.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit

class BookedRideDetailsViewController: UIViewController {

    @IBOutlet weak var contactTheDriverButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelButton.configure(button: cancelButton)
        contactTheDriverButton.configure(button: contactTheDriverButton)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        sender.pressed()
    }
    @IBAction func contactDriverPressed(_ sender: UIButton) {
        sender.pressed()
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
