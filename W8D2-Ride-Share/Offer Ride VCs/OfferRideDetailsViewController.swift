//
//  OfferRideDetailsViewController.swift
//  W8D2-Ride-Share
//
//  Created by Pavel on 2019-02-28.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit
import Firebase

class OfferRideDetailsViewController: UIViewController {
    
    //Setting Firestore
    var db: Firestore!
    var settings: FirestoreSettings!
    
    //Handler for checking user aithorization
    var user: FirebaseAuth.User?
    var handle: AuthStateDidChangeListenerHandle? = nil
    
    //Other properties
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
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var confirmButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        confirmButton.configure(button: confirmButton)
        startAddressLabel.text =  startAddress
        destinationAddressLabel.text = destinationAddress
        startTimeLabel.text = startTimeText
        estimatedArrivalTimeLabel.text = estimatedArrivalTimeText
        tripDurationLabel.text = tripDuration
        distanceLabel.text = ride?.distance
        
        // START setup for Firestore
        settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        // END setup for Firestore
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // START auth_listener
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.user = user
            self.calculatePrice()
        }
        // END auth_listener
    }

    @IBAction func backButton(_ sender: Any) {

        self.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func editNumberOfSeats(_ sender: UIStepper!) {
        numberOfSeatsLabel.text = String(Int(sender.value))
        
        ride?.numberOfSeats = Int(sender.value)
        
    }
    
    @IBAction func confirm(_ sender: UIButton) {
        sender.pressed()
        let alert = UIAlertController(title: "Confirm", message: "Confirm Ride Details", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { alert -> Void in
        
            guard  let ride = self.ride, let numberOfSeatsLabel = self.numberOfSeatsLabel, let priceLabel = self.priceLabel else {
                return
            }
            ride.tripStatus = TripStatus.available
            ride.numberOfSeats = Int(numberOfSeatsLabel.text!)!
            ride.numberOfAvailableSeats = ride.numberOfSeats //When offering ride number of sets and number of available seats is the same
            ride.price = Float(priceLabel.text!)!
            
            //Create a new ride in Firestore
            self.createRide(startLocation: GeoPoint(latitude: ride.startLocation!.latitude, longitude: ride.startLocation!.longitude), endLocation: GeoPoint(latitude: ride.endLocation!.latitude, longitude: ride.endLocation!.longitude), tripStartTime: ride.tripStartTime!, estimatedArrivalTime: ride.estimatedArrivalTime!, tripDuration: ride.tripDuration!, distance: ride.distance, numberOfSeats: ride.numberOfSeats!, numberOfAvailableSeats: ride.numberOfAvailableSeats!, price: ride.price!, tripStatus: TripStatus.available.rawValue)
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { alert -> Void in
                self.dismiss(animated: true, completion: nil)
        }))
     
            self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func editPrice(_ sender: UIStepper!) {
        priceLabel.text = "\(Int(ride?.price ?? 0) + Int(sender.value))"
    }
    
    
    //MARK: Create new ride

    func createRide(startLocation: GeoPoint, endLocation: GeoPoint, tripStartTime: Date, estimatedArrivalTime: Date, tripDuration: String, distance: String, numberOfSeats:Int, numberOfAvailableSeats: Int, price: Float, tripStatus: TripStatus.RawValue) {

        if let user = self.user {
            //Create a new ride document in Firestore
            
            var ref: DocumentReference? = nil
            ref = db.collection("rides").addDocument(data: [
                "rideID": ref?.documentID ?? "noRideID",
                "userID": user.uid,
                "status": tripStatus,
                "startLocation": startLocation,
                "endLocation": endLocation,
                "tripStartTime": tripStartTime,
                "estimatedArrivalTime": estimatedArrivalTime,
                "tripDuration": tripDuration,
                "distance": distance,
                "numberOfSeats": numberOfSeats,
                "numberOfAvailableSeats": numberOfAvailableSeats,
                "price": price
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err.localizedDescription)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                    // Add rideID as a documentID
                    self.addRideID(documentID: ref!.documentID)
                }
            }
        }
        else {
            print("Error! User do not login")
        }
    }
    
    //MARK: Add rideID to the newly created ride
    func addRideID(documentID: String) {
        db.collection("rides").document(documentID).setData([ "rideID": documentID ], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err.localizedDescription)")
            } else {
                print("RideID successfully written!")
            }
        }
    }
    
    func calculatePrice() {
        let distanceInKm = ((ride?.distance as! NSString).replacingOccurrences(of: ",", with: "") as! NSString).floatValue
        if (distanceInKm < 50) {
            ride?.price = distanceInKm * 0.5
        }
        if (distanceInKm > 50 && distanceInKm < 100) {
            ride?.price = distanceInKm * 0.25
        }
        if (distanceInKm > 100) {
            ride?.price = distanceInKm * 0.1
        }
        priceLabel.text = "\(Int(ride?.price ?? 0))"
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
