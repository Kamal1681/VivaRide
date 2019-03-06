//
//  OfferRideDetailsViewController.swift
//  W8D2-Ride-Share
//
//  Created by Pavel on 2019-02-28.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit

class OfferRideDetailsViewController: UIViewController {

    var ride: Ride?
    var startAddress: String?
    var destinationAddress: String?
    var startTimeText: String?
    var estimatedArrivalTimeText: String?
    var tripDuration: String?
    
    @IBOutlet weak var numberOfSeatsLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var startAddressLabel: UILabel!
    @IBOutlet weak var destinationAddressLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var estimatedArrivalTimeLabel: UILabel!
    @IBOutlet weak var tripDurationLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startAddressLabel.text =  startAddress
        destinationAddressLabel.text = destinationAddress
        startTimeLabel.text = startTimeText
        estimatedArrivalTimeLabel.text = estimatedArrivalTimeText
        tripDurationLabel.text = tripDuration
        
        

        // Do any additional setup after loading the view.
    }
    

    @IBAction func backButton(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func editNumberOfSeats(_ sender: UIStepper!) {
        numberOfSeatsLabel.text = String(Int(sender.value))
        
        ride?.numberOfSeats = Int(sender.value)
        
    }
    @IBAction func confirm(_ sender: Any) {
        guard  let ride = ride, let numberOfSeatsLabel = numberOfSeatsLabel, let priceLabel = priceLabel else {
            return
        }
        ride.tripStatus = TripStatus.available
        ride.numberOfSeats = Int(numberOfSeatsLabel.text!)!
        ride.price = Float(priceLabel.text!)!
        
    }
    
    @IBAction func editPrice(_ sender: UIStepper!) {
        priceLabel.text = String(sender.value)
    }
    /*
     @IBAction func confirm(_ sender: Any) {
     }
     @IBAction func confirm(_ sender: Any) {
     }
     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
