//
//  TestViewController.swift
//  W8D2-Ride-Share
//
//  Created by Pavel on 2019-03-19.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps

class TestViewController: UIViewController {

    //Class properties
    var ridesArray = [Ride]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        VRFirestoreQuery.getQRides(for: "EKi05RTabLZiqA3AUkNexwQDSo13", sortedByDate: true, completion:{ridesArrayResult in
            self.ridesArray = ridesArrayResult
            for (index, ride) in self.ridesArray.enumerated() {
                VRFirestoreQuery.getQBookings(for: ride, completion: { (rideResult) in
//                    self.ridesArray[index].bookings = []
//                    for booking in bookingsArrayResult {
//                        self.ridesArray[index].bookings?.append(booking)
//                    }
                    self.ridesArray[index] = rideResult
                    if let bookings = self.ridesArray[index].bookings {
                        for booking in bookings {
                            print("Booking ID: \(booking.bookingID) Ride ID: \(booking.rideID)")
                        }
                    }
                })
            }
        })
        
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
