//
//  RidesBookedTableViewCell.swift
//  W8D2-Ride-Share
//
//  Created by Pavel on 2019-02-28.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit
import GoogleMaps

class RidesBookedTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var startTimeLabel: UILabel!
    
    @IBOutlet weak var estimatedArrivalTimeLabel: UILabel!
    
    @IBOutlet weak var startPointLabel: UILabel!
    
    @IBOutlet weak var endPointLabel: UILabel!
    
    @IBOutlet weak var driverNameLabel: UILabel!

    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(booking: Booking) {
        
        if let startLocation = booking.rideInfo?.startLocation, let endLocation = booking.rideInfo?.endLocation {
            getAddressFromLocation(location: startLocation, complete: { (city) in
                OperationQueue.main.addOperation {
                    self.startPointLabel.text = city
                }
            })
            getAddressFromLocation(location: endLocation, complete: { (city) in
                OperationQueue.main.addOperation {
                    self.endPointLabel.text = city
                }
            })
        }
        
        if let tripStartTime = booking.rideInfo?.tripStartTime {
            dateLabel.text = stringDateFormat(from: tripStartTime)
            startTimeLabel.text = stringHoursMinutesFormat(from: tripStartTime)
        }
        else {
            print("Error! Unable to get tripStartTime")
        }
        
        if let driverName = booking.driverInfo?.name {
            driverNameLabel.text = "Driver name: \(driverName)"
        } else {
            print("Error! Unable to get driverName")
        }
        
        if let estimatedArrivalTime = booking.rideInfo?.estimatedArrivalTime {
            estimatedArrivalTimeLabel.text = stringHoursMinutesFormat(from: estimatedArrivalTime)
        }
        else {
            print("Error! Unable to get estimatedArrivalTimeLabel")
        }

        if let price = booking.rideInfo?.price {
            let priceFormated = String(format:"%.2f", price)
            priceLabel.text = "CAD \(priceFormated)"
        }
        else {
            print("Error! Unable to get price")
        }
        
    }
    
    func getAddressFromLocation (location: CLLocationCoordinate2D, complete: @escaping (String) -> Void) {
        
        var city: String? = ""
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(String(describing: location.latitude)),\(String(describing: location.longitude))&location_type=APPROXIMATE&result_type=locality&language=en&key=\(Constants.googleApiKey)")
        
        let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
            
            do {
                if data != nil{
                    let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as!  NSDictionary
                    let results = dict["results"] as! NSArray
                    let addressComponents = results.value(forKey: "address_components") as! NSArray
                    let components = (addressComponents[0] as! NSArray)[0] as! NSDictionary
                    city = (components.value(forKey: "long_name") as! String)
                    
                    complete(city ?? "")
                }
            }catch {
                print("Error request")
            }
        }
        task.resume()
        
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
