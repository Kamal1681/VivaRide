//
//  OfferedRideDetailsViewController.swift
//  W8D2-Ride-Share
//
//  Created by Pavel on 2019-02-28.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit
import GoogleMaps

class OfferedRideDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //Passing data from previous VC
    var ride: Ride?
    
    //UI Properties
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var rideStatusLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var startPointLabel: UILabel!
    @IBOutlet weak var estimatedArrivalTimeLabel: UILabel!
    @IBOutlet weak var endPointLabel: UILabel!
    @IBOutlet weak var numberOfBookedSeatsLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var additionalInfoHeaderLabel: UILabel!
    @IBOutlet weak var additionalInfoLabel: UITextView!
    @IBOutlet weak var passengersTableVIew: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelButton.configure(button: cancelButton)
        
        passengersTableVIew.delegate = self
        passengersTableVIew.dataSource = self
        
        //Load information to the View Controller
        if let ride = ride {
            loadInfo(for: ride)
        }
        else {
            print("Error! Can not load information to the view controller from ride property.")
        }
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Load ride detils info to the VC
    func loadInfo(for ride: Ride) {
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
        
        //Hiding additional info block
        additionalInfoHeaderLabel.text = ""
        additionalInfoHeaderLabel.frame.size.height = 0
        additionalInfoLabel.text = ""
        additionalInfoLabel.frame.size.height = 0
        additionalInfoLabel.translatesAutoresizingMaskIntoConstraints = true
        additionalInfoLabel.sizeToFit()
    }
    
    //MARK: - Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let numberOfRows = ride?.bookings?.count else {
            return 0
        }
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PassengerCell", for: indexPath) as! PassengersListTableViewCell
        guard let booking = self.ride?.bookings?[indexPath.row] else {
            print("Error! Unable to get bookings infro from ride array.")
            return cell
        }
        
        cell.configureCell(booking: booking)
        
        return cell
    }
    
    //MARK: - Ride cancelation
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        sender.pressed()
        
        if let ride = ride {
            CancelOfferedRide.cancelOfferedRide(for: ride, viewController: self)
        }
    }
    
    //MARK: - Navigation
    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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
