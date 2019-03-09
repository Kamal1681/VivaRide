//
//  RideDetailsViewController.swift
//  W8D2-Ride-Share
//
//  Created by Pavel on 2019-02-28.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase

class RideDetailsViewController: UIViewController {
    //Passing properties
    var ride: Ride!
    
    //IBOutlet properties
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tripStartTimeLabel: UILabel!
    @IBOutlet weak var startLocationLabel: UILabel!
    @IBOutlet weak var estimatedArrivalTimeLabel: UILabel!
    @IBOutlet weak var endLocationLabel: UILabel!
    @IBOutlet weak var numberOfAvailableSeats: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var driverPhotoImageView: UIImageView!
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var carModelLabel: UILabel!
    @IBOutlet weak var carColorLabel: UILabel!
    @IBOutlet weak var additionalInfoTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Distance is: \(ride!.distance)")
        
        //Setting labels and other UI
        getAddressFromLocation(location: ride.startLocation!, complete: { (city) in
            OperationQueue.main.addOperation {
                self.startLocationLabel.text = city
            }
        })
        getAddressFromLocation(location: ride.endLocation!, complete: { (city) in
            OperationQueue.main.addOperation {
                self.endLocationLabel.text = city
            }
        })
        
        dateLabel.text = stringDateFormat(from: ride.tripStartTime!)
        tripStartTimeLabel.text = stringHoursMinutesFormat(from: ride.tripStartTime!)
        estimatedArrivalTimeLabel.text = stringHoursMinutesFormat(from: ride.estimatedArrivalTime!)
        
        driverNameLabel.text = ride.tripDuration
        price.text = ride.price?.description
        additionalInfoTextView.text = "Additional information will apperar in that field and distance of the ride is \(Int(ride.distance)) km."
        
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Navigation
    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Functions
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
