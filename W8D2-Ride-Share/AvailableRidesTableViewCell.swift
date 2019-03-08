//
//  AvailableRidesTableViewCell.swift
//  W8D2-Ride-Share
//
//  Created by Pavel on 2019-02-28.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit

class AvailableRidesTableViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var startTimeLabel: UILabel!
    
    @IBOutlet weak var estimatedArrivalTimeLabel: UILabel!
    
    @IBOutlet weak var startPointLabel: UILabel!
    
    @IBOutlet weak var endPointLabel: UILabel!
    

    @IBOutlet weak var driverName: UILabel!
    
    @IBOutlet weak var price: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configureCell(ride: Ride) {
        
//        dateLabel.text = "March-03-2019"
//        startTimeLabel.text = "9:00 PM"
//        estimatedArrivalTimeLabel.text = "11:00 AM"
//        startPointLabel.text = "Toronto ON"
//        endPointLabel.text = "Vancouver BC"
        dateLabel.text = stringDateFormat(from: ride.tripStartTime!)
        startTimeLabel.text = stringHoursMinutesFormat(from: ride.tripStartTime!)
        estimatedArrivalTimeLabel.text = stringHoursMinutesFormat(from: ride.estimatedArrivalTime!)
        
        driverName.text = ride.tripDuration
        price.text = ride.price?.description
        distanceLabel.text = "\(Int(ride.distance)) km"
        
        
        
//        dateLabel.text = String(ride.tripStartTime)
//        startTimeLabel.text =
//        estimatedArrivalTimeLabel.text = ride.estimatedArrivalTime
//        startPointLabel.text = ride.startLocation
//        endPointLabel.text = ride.endLocation
//        driverName.text = ride.driverName
//        price.text = (ride.price as! String)
//        distanceLabel.text = ride.distance
        
        
    }
    
    func stringDateFormat(from date: Date) -> String {
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "E - MMMM dd, yyyy"
        // convert date to string
        let myString = formatter.string(from: date)
        
        return myString
    }
    
    func stringHoursMinutesFormat(from date: Date) -> String {
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "hh:mm a"
        // convert date to string
        let myString = formatter.string(from: date)
        
        return myString
    }

}
