//
//  RidesOfferedTableViewCell.swift
//  W8D2-Ride-Share
//
//  Created by Pavel on 2019-02-28.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit

class RidesOfferedTableViewCell: UITableViewCell {
    //UI Properties
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var rideStatusLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var startPointLabel: UILabel!
    @IBOutlet weak var estimatedArrivalTimeLabel: UILabel!
    @IBOutlet weak var endPointLabel: UILabel!
    @IBOutlet weak var numberOfBookedSeatsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(ride: Ride) {
    
        if let startLocation = ride.startLocation, let endLocation = ride.endLocation {
            GeoPlace.getAddressFromLocation(location: startLocation, complete: { (city) in
                OperationQueue.main.addOperation {
                    self.startPointLabel.text = city
                }
            })
            GeoPlace.getAddressFromLocation(location: endLocation, complete: { (city) in
                OperationQueue.main.addOperation {
                    self.endPointLabel.text = city
                }
            })
        }
        
        if let tripStartTime = ride.tripStartTime {
            startDateLabel.text = StringFormat.Date(from: tripStartTime)
            startTimeLabel.text = StringFormat.HoursMinutes(from: tripStartTime)
        }
        else {
            print("Error! Unable to get tripStartTime")
        }
        
        if let estimatedArrivalTime = ride.estimatedArrivalTime {
            estimatedArrivalTimeLabel.text = StringFormat.HoursMinutes(from: estimatedArrivalTime)
        }
        else {
            print("Error! Unable to get estimatedArrivalTimeLabel")
        }
        
        if
            let numberOfAvailableSeats = ride.numberOfAvailableSeats,
            let numberOfSeats = ride.numberOfSeats
        {
            numberOfBookedSeatsLabel.text = StringFormat.numberOfBookedSeats(from: numberOfSeats, numberOfAvailableSeats: numberOfAvailableSeats)
        }
        else {
            print("Error! Unable to get estimatedArrivalTimeLabel")
        }
        
        
        if let rideStatus = TripStatus(rawValue: ride.tripStatus!.rawValue) {
            rideStatusLabel.text = rideStatus.rawValue
            switch rideStatus {
            case .available:
                rideStatusLabel.textColor = .green
            case .booked:
                rideStatusLabel.textColor = .black
            case .started:
                rideStatusLabel.textColor = .blue
            case .cancelled:
                rideStatusLabel.textColor = .red
            case .finished:
                rideStatusLabel.textColor = .darkGray
            }
        }
        else {
            print("Error! Unable to get rideStatus")
        }
    }

}
