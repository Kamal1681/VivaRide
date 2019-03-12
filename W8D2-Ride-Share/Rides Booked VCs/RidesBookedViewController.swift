//
//  RidesBookedViewController.swift
//  W8D2-Ride-Share
//
//  Created by Pavel on 2019-02-28.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps

class RidesBookedViewController: UIViewController {

    //Setting Firestore
    var db: Firestore!
    var settings: FirestoreSettings!
    
    //Handler for checking user aithorization
    var user: FirebaseAuth.User?
    var handle: AuthStateDidChangeListenerHandle? = nil
    
    //Other properties
    var ride: Ride?
    var booking: Booking?
    
    //Booked rides array
    var ridesArray = [Ride]()
    var bookingsArray = [Booking]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            
            //Make arrays empty when view appear in case user came from ride details VC
            self.ridesArray = []
            self.bookingsArray = []
            
            //Get bookings infromation from Firestore
            self.getRidesBooked()
        }
        // END auth_listener

    }
    
    func getRidesBooked() {
        
        if let user = self.user {
            
            //Query for documnets in rides collection
            let docRef = db.collection("bookings")
            let query = docRef
                .whereField("passengerID", isEqualTo: user.uid)
            
            query.getDocuments { snapshot, error in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    for document in snapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        
                        guard
                            let bookingID = document.get("bookingID") as? String,
                            let passengerID = document.get("passengerID") as? String,
                            let rideID = document.get("rideID") as? String,
                            let numberOfBookingSeats = document.get("numberOfBookingSeats") as? Int,
                            let status = document.get("status") as? String
                            else {
                                print("Error! Can not get data from Bookings collection.")
                                return
                        }
                        
                        let booking = Booking(bookingID: bookingID, passengerID: passengerID, rideID: rideID, rideInfo: nil, numberOfBookingSeats: numberOfBookingSeats, status: status)
                        
                        self.bookingsArray.append(booking)
                    }
                    //Get rides infromation from Firestore Rides collection
                    self.getRidesInfo()
                    
//                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func getRidesInfo() {
        for index in 0..<self.bookingsArray.count {
            var ride: Ride?
            guard let rideID = self.bookingsArray[index].rideID
                else {
                    print("Error! Can not get rideID from array of Booked rides.")
                    return
            }
            
            let bookedRidesCollection = self.db.collection("rides").whereField("rideID", isEqualTo: rideID)
            
            bookedRidesCollection.getDocuments { snapshot, error in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    guard
                        let startLocationGeoPoint = snapshot?.documents.first?.get("startLocation") as? GeoPoint,
                        let endLocationGeoPoint = snapshot?.documents.first?.get("endLocation") as? GeoPoint,
                        let price = snapshot?.documents.first?.get("price") as? Float,
                        let tripDuration = snapshot?.documents.first?.get("tripDuration") as? String,
                        let distance = snapshot?.documents.first?.get("distance") as? String,
                        let numberOfSeats = snapshot?.documents.first?.get("numberOfSeats") as? Int,
                        let numberOfAvailableSeats = snapshot?.documents.first?.get("numberOfAvailableSeats") as? Int,
                        let tripStatusRawValue = snapshot?.documents.first?.get("status") as? String,
                        let tripStatus = TripStatus(rawValue: tripStatusRawValue),
                        let tripStartTime = snapshot?.documents.first?.get("tripStartTime") as? Timestamp,
                        let estimatedArrivalTime = snapshot?.documents.first?.get("estimatedArrivalTime") as? Timestamp,
                        let userID = snapshot?.documents.first?.get("userID") as? String,
                        let rideID = snapshot?.documents.first?.get("rideID") as? String
                        else {
                            print("Error! Can not get data from Rides document.")
                            return
                    }
                    
                    ride = Ride(startLocation: CLLocationCoordinate2D(latitude: startLocationGeoPoint.latitude, longitude: startLocationGeoPoint.longitude), endLocation: CLLocationCoordinate2D(latitude: endLocationGeoPoint.latitude, longitude: endLocationGeoPoint.longitude), tripStartTime: tripStartTime.dateValue(), estimatedArrivalTime: estimatedArrivalTime.dateValue(), tripDuration: tripDuration, distance: distance, userID: userID, rideID: rideID, userInfo: nil, price: price, numberOfSeats: numberOfSeats, numberOfAvailableSeats: numberOfAvailableSeats, tripStatus: tripStatus)
                    
                    self.bookingsArray[index].rideInfo = ride
                    
                }
            }
        }
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
