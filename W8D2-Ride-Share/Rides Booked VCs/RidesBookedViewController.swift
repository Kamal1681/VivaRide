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

class RidesBookedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //Setting Firestore
    var db: Firestore!
    var settings: FirestoreSettings!
    
    //Handler for checking user aithorization
    var user: FirebaseAuth.User?
    var handle: AuthStateDidChangeListenerHandle? = nil
    
    //Other properties
    var booking: Booking?
    
    //Booked rides array
    var bookingsArray = [Booking]()
    
    //UI elements
    @IBOutlet weak var ridesBookedTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // START setup for Firestore
        settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        // END setup for Firestore
        
        ridesBookedTableView.delegate = self
        ridesBookedTableView.dataSource = self
        ridesBookedTableView.rowHeight = 140
//        ridesBookedTableView.estimatedRowHeight = 200
//        ridesBookedTableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // START auth_listener
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.user = user
            
            //Make arrays empty when view appear in case user came from ride details VC
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
                        
                        let booking = Booking(bookingID: bookingID, passengerID: passengerID, rideID: rideID, rideInfo: nil, numberOfBookingSeats: numberOfBookingSeats, status: status, driverInfo: nil, passengerInfo: nil)
                        
                        self.bookingsArray.append(booking)
                    }
                    //Get rides and drivers infromation from Firestore Rides and Users collections
                    self.getRidesInfo() {self.getDriverInfo()}
                    
                    self.ridesBookedTableView.reloadData()
                }
            }
        }
    }
    
    func getRidesInfo(completionHandler: @escaping () -> Void) {
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
                    
                    ride = Ride(startLocation: CLLocationCoordinate2D(latitude: startLocationGeoPoint.latitude, longitude: startLocationGeoPoint.longitude), endLocation: CLLocationCoordinate2D(latitude: endLocationGeoPoint.latitude, longitude: endLocationGeoPoint.longitude), tripStartTime: tripStartTime.dateValue(), estimatedArrivalTime: estimatedArrivalTime.dateValue(), tripDuration: tripDuration, distance: distance, userID: userID, rideID: rideID, userInfo: nil, price: price, numberOfSeats: numberOfSeats, numberOfAvailableSeats: numberOfAvailableSeats, tripStatus: tripStatus, bookings: nil)
                    
                    self.bookingsArray[index].rideInfo = ride
                }
                completionHandler()
                self.ridesBookedTableView.reloadData()
            }
        }
    }
    
    func getDriverInfo() {
        
        //Get driver infromation from Firestore user collection
        for index in 0..<self.bookingsArray.count {
            var userInfo: UserInfo?
            guard let userID = self.bookingsArray[index].rideInfo?.userID else {
                print("Error! Can not get userID from Rides collection")
                return
            }
            
            let driver = self.db.collection("users").whereField("uid", isEqualTo: userID)
            
            driver.getDocuments { snapshot, error in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    guard
                        let userUID = snapshot!.documents.first?.get("uid") as? String,
                        let name = snapshot!.documents.first?.get("name") as? String,
                        let phoneNumber = snapshot!.documents.first?.get("phoneNumber") as? String,
                        let carModel = snapshot!.documents.first?.get("carModel") as? String,
                        let carColor = snapshot!.documents.first?.get("carColor") as? String,
                        let pushNotificationToken = snapshot!.documents.first?.get("pushNotificationToken") as? String
                        else {
                            print("Error! Can not get information about the driver from Firestore document in Find Ride VC.")
                            return
                    }
                    
                    userInfo = UserInfo(userID: userUID, name: name, phoneNumber: phoneNumber, carModel: carModel, carColor: carColor, photo: nil, pushNotificationToken: pushNotificationToken)
   
                    self.bookingsArray[index].driverInfo = userInfo
                }
                self.ridesBookedTableView.reloadData()
            }
        }
        
    }
    
    //MARK: - Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookingsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ridesBookedTableViewCell", for: indexPath) as! RidesBookedTableViewCell
        
        booking = self.bookingsArray[indexPath.row]
        
        guard let booking = booking else {
            return cell
        }
        
        cell.configureCell(booking: booking)
        return cell
    
    }

    
    //MARK: - Navigation
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Segue to the second view controller
        self.performSegue(withIdentifier: "goToBookedRideDetails", sender: self)
    }
    
    // This function is called before the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToBookedRideDetails", let destinationVC = segue.destination as? BookedRideDetailsViewController {
            if let indexPath = ridesBookedTableView.indexPathForSelectedRow {
                destinationVC.booking = bookingsArray[indexPath.row]
            }
            
        }
    }
    
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
