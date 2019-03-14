//
//  PassengersListTableViewCell.swift
//  W8D2-Ride-Share
//
//  Created by Pavel on 2019-02-28.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit

class PassengersListTableViewCell: UITableViewCell {
    
    //UI Properties
    @IBOutlet weak var passengerNameLabel: UILabel!
    @IBOutlet weak var numberOfBookedSeatsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(booking: Booking) {
        
        if let passengerName = booking.passengerInfo?.name {
            passengerNameLabel.text = passengerName
        }
        else {
            print("Error! Unable to get number of booked seats")
        }
        
        if let numberOfBookedSeats = booking.numberOfBookingSeats {
            if numberOfBookedSeats == 1 {
                numberOfBookedSeatsLabel.text = "\(numberOfBookedSeats) seat"
            }
            else if numberOfBookedSeats > 1 {
                numberOfBookedSeatsLabel.text = "\(numberOfBookedSeats) seats"
            }
            else {
                numberOfBookedSeatsLabel.text = "no seats"
            }
        }
        else {
            print("Error! Unable to get number of booked seats")
        }
        
    }

}
