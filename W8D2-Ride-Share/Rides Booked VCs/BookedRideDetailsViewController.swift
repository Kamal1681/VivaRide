//
//  BookedRideDetailsViewController.swift
//  W8D2-Ride-Share
//
//  Created by Pavel on 2019-02-28.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit
import GoogleMaps

class BookedRideDetailsViewController: UIViewController {

    //Passing data from previous VC
    var booking: Booking?
    
    //UI Properties
    
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var startLocationLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var endLocationLabel: UILabel!
    @IBOutlet weak var numberOfBookingSeatsLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var carModelLabel: UILabel!
    @IBOutlet weak var carColorLabel: UILabel!
    @IBOutlet weak var contactTheDriverButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelButton.configure(button: cancelButton)
        contactTheDriverButton.configure(button: contactTheDriverButton)
        
        //Load information to the View Controller
        if let booking = booking {
            loadRideInfo(booking: booking)
        }
        else {
            print("Error! Can not load information to the view controller from booking property.")
        }

    }
    
    //MARK: - UI Actions
    @IBAction func cancelPressed(_ sender: UIButton) {
        sender.pressed()
    }
    @IBAction func contactDriverPressed(_ sender: UIButton) {
        sender.pressed()
    }
    
    //MARK: - Navigation
    
    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Loading information to VC
    
    func loadRideInfo(booking: Booking) {
        
        if let startLocation = booking.rideInfo?.startLocation, let endLocation = booking.rideInfo?.endLocation {
            getAddressFromLocation(location: startLocation, complete: { (city) in
                OperationQueue.main.addOperation {
                    self.startLocationLabel.text = city
                }
            })
            getAddressFromLocation(location: endLocation, complete: { (city) in
                OperationQueue.main.addOperation {
                    self.endLocationLabel.text = city
                }
            })
        }
        
        if let tripStartTime = booking.rideInfo?.tripStartTime {
            startDateLabel.text = stringDateFormat(from: tripStartTime)
            startTimeLabel.text = stringHoursMinutesFormat(from: tripStartTime)
        }
        else {
            print("Error! Unable to get tripStartTime")
        }
        
        if let estimatedArrivalTime = booking.rideInfo?.estimatedArrivalTime {
            endTimeLabel.text = stringHoursMinutesFormat(from: estimatedArrivalTime)
        }
        else {
            print("Error! Unable to get estimatedArrivalTimeLabel")
        }
        
        if let numberOfBookingSeats = booking.numberOfBookingSeats {
            numberOfBookingSeatsLabel.text = formatedString(for: numberOfBookingSeats)
        } else {
            print("Error! Unable to get numberOfBookingSeats")
        }
        
        if let price = booking.rideInfo?.price {
            let priceFormated = String(format:"%.2f", price)
            priceLabel.text = "CAD \(priceFormated)"
        }
        else {
            print("Error! Unable to get price")
        }
        
        if let driverName = booking.driverInfo?.name {
            driverNameLabel.text = "Driver name: \(driverName)"
        } else {
            print("Error! Unable to get driverName")
        }
        
        if let carModel = booking.driverInfo?.carModel {
            carModelLabel.text = carModel
        }
        else {
            print("Error! Unable to get carModel")
        }
        
        if let carColor = booking.driverInfo?.carColor {
            carColorLabel.text = carColor
        }
        else {
            print("Error! Unable to get carColor")
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
    
    func formatedString(for numberOfBookingSeats: Int) -> String {
        var resultString = ""
        
        if numberOfBookingSeats == 1 {
            resultString = "\(numberOfBookingSeats) seat was booked"
        }
        else if numberOfBookingSeats > 1 {
            resultString = "\(numberOfBookingSeats) seats were booked"
        }
        
        return resultString
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
