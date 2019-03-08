//
//  AvailableRidesTableViewCell.swift
//  W8D2-Ride-Share
//
//  Created by Pavel on 2019-02-28.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit
import GoogleMaps

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


        getAddressFromLocation(location: ride.startLocation!, complete: { (city) in
            OperationQueue.main.addOperation {
                self.startPointLabel.text = city
            }
        })
        getAddressFromLocation(location: ride.endLocation!, complete: { (city) in
            OperationQueue.main.addOperation {
                self.endPointLabel.text = city
            }
       })

        dateLabel.text = stringDateFormat(from: ride.tripStartTime!)
        startTimeLabel.text = stringHoursMinutesFormat(from: ride.tripStartTime!)
        estimatedArrivalTimeLabel.text = stringHoursMinutesFormat(from: ride.estimatedArrivalTime!)
        
        driverName.text = ride.tripDuration
        price.text = ride.price?.description
        distanceLabel.text = "\(Int(ride.distance)) km"
       
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
    
        



