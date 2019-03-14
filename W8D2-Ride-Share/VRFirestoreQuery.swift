//
//  VRFirestoreQuery.swift
//  W8D2-Ride-Share
//
//  Created by Pavel on 2019-03-13.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps

class VRFirestoreQuery {

    //Setting Firestore
    static var db: Firestore!
    static var settings: FirestoreSettings!
    
    //Handler for checking user aithorization
    static var user: FirebaseAuth.User?
    static var handle: AuthStateDidChangeListenerHandle? = nil
    
    //MARK: - Rides
    static func getRides(for driverID: String, completion: @escaping ([Ride]) -> Void) {
        setUpFirestore()
        setUpAuthListener()
        
        var ridesArray = [Ride]()
        getRideDocuments(for: driverID, completion: {ridesArrayResult in
            ridesArray = ridesArrayResult
            
            var index = -1
            for ride in ridesArray {
                index += 1
                if let rideID = ride.rideID {
                    getBookingDocuments(for: rideID, completion: { (bookingArrayResult) in
                        ridesArray[index].bookings = bookingArrayResult
                        
                        if ridesArray.count == index + 1 {
                            completion(ridesArray)
                        }
                    })
                }
                else
                {
                    print("Error! Unable to get rideID from rideArray.")
                }
                
            }
        })
    }
    
    static func getRideDocuments(for driver: String, completion: @escaping (_ ridesArrayResult: [Ride]) -> Void) {
        var ridesArray = [Ride]()
        let query = createQueryRides(for: driver)
        
        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in snapshot!.documents {
                    getRideDetails(from: document, completion: { rideResult in
                        if let rideResult = rideResult {
                            ridesArray.append(rideResult)
                        }
                        else
                        {
                            print("Error! Can not proceed let ride = getRideFields(from: document)")
                        }
                    })
                }
                completion(ridesArray)
                
                //Get rides and drivers infromation from Firestore Rides and Users collections
//                self.getRidesInfo() {self.getDriverInfo()}
            
            }
        }
        
    }
    
    static func getRideDetails(from document: QueryDocumentSnapshot, completion: @escaping (Ride?) -> Void) {
        print("\(document.documentID) => \(document.data())")
        
        guard
            let startLocationGeoPoint = document.get("startLocation") as? GeoPoint,
            let endLocationGeoPoint = document.get("endLocation") as? GeoPoint,
            let price = document.get("price") as? Float,
            let tripDuration = document.get("tripDuration") as? String,
            let distance = document.get("distance") as? String,
            let numberOfSeats = document.get("numberOfSeats") as? Int,
            let numberOfAvailableSeats = document.get("numberOfAvailableSeats") as? Int,
            let tripStatusRawValue = document.get("status") as? String,
            let tripStatus = TripStatus(rawValue: tripStatusRawValue),
            let tripStartTime = document.get("tripStartTime") as? Timestamp,
            let estimatedArrivalTime = document.get("estimatedArrivalTime") as? Timestamp,
            let userID = document.get("userID") as? String,
            let rideID = document.get("rideID") as? String
            else {
                print("Error! Can not get data from Rides document.")
                return
        }
        
        let ride = Ride(startLocation: CLLocationCoordinate2D(latitude: startLocationGeoPoint.latitude, longitude: startLocationGeoPoint.longitude), endLocation: CLLocationCoordinate2D(latitude: endLocationGeoPoint.latitude, longitude: endLocationGeoPoint.longitude), tripStartTime: tripStartTime.dateValue(), estimatedArrivalTime: estimatedArrivalTime.dateValue(), tripDuration: tripDuration, distance: distance, userID: userID, rideID: rideID, userInfo: nil, price: price, numberOfSeats: numberOfSeats, numberOfAvailableSeats: numberOfAvailableSeats, tripStatus: tripStatus, bookings: nil)
     
        completion(ride)
    }
    
    static func createQueryRides(for driverID: String) -> Query {
        //Query for documnets in rides collection
        let docRef = db.collection("rides")
        let query = docRef
            .whereField("userID", isEqualTo: driverID)
        return query
    }
    
    //MARK: - Bookings documents for ride
    static func getBookingDocuments(for rideID: String, completion:@escaping ([Booking]) -> Void) {
        var bookingArray = [Booking]()
        createQueryBookings(for: rideID, completion: {query in
            
            query.getDocuments { snapshot, error in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    var index = -1
                    for document in snapshot!.documents {
                        index += 1
                        getBookingDetails(from: document, completion: {bookingResult in
                            if let booking = bookingResult {
                                bookingArray.append(booking)
                                if index + 1 == snapshot?.documents.count {
                                    getPasengerInfo(for: bookingArray, completion: { bookingArrayResult in
                                        completion(bookingArrayResult)
                                    })
                                }
                            }
                            else
                            {
                                print("Error! Can not get booking details from document.")
                            }
                        })
                    }
                    //Get rides and drivers infromation from Firestore Rides and Users collections
                    //                self.getRidesInfo() {self.getDriverInfo()}
                    
                }
            }
        })
    }
    
    static func getBookingDetails(from document: QueryDocumentSnapshot, completion:@escaping (Booking?) -> Void) {
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
        
        completion(booking)
    }
    
    static func createQueryBookings(for rideID: String, completion:@escaping (Query) -> Void){
        //Query for documnets in bookings collection
        let docRef = db.collection("bookings")
        let query = docRef
            .whereField("rideID", isEqualTo: rideID)
        completion(query)
    }
    
    //MARK: - SetUp Firestore and Auth listener
    static func setUpFirestore() {
        // START setup for Firestore
        settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        // END setup for Firestore
    }
    
    static func setUpAuthListener() {
        // START auth_listener
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.user = user
        }
        // END auth_listener
    }
    
    //MARK: - Passenger info
    
    static func getPasengerInfo(for bookingsArray: [Booking], completion:@escaping ([Booking]) -> Void) {

        //Get driver infromation from Firestore user collection
        for index in 0..<bookingsArray.count {
            var passengerInfo: UserInfo?
            guard let passengerID = bookingsArray[index].passengerID else {
                print("Error! Can not get userID from Rides collection")
                return
            }

            let passenger = db.collection("users").whereField("uid", isEqualTo: passengerID)

            passenger.getDocuments { snapshot, error in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    guard
                        let passengerUID = snapshot!.documents.first?.get("uid") as? String,
                        let name = snapshot!.documents.first?.get("name") as? String,
                        let phoneNumber = snapshot!.documents.first?.get("phoneNumber") as? String,
                        let carModel = snapshot!.documents.first?.get("carModel") as? String,
                        let carColor = snapshot!.documents.first?.get("carColor") as? String,
                        let pushNotificationToken = snapshot!.documents.first?.get("pushNotificationToken") as? String
                        else {
                            print("Error! Can not get information about the driver from Firestore document in Find Ride VC.")
                            return
                    }

                    passengerInfo = UserInfo(userID: passengerUID, name: name, phoneNumber: phoneNumber, carModel: carModel, carColor: carColor, photo: nil, pushNotificationToken: pushNotificationToken)

                    bookingsArray[index].passengerInfo = passengerInfo
                    if index + 1 == bookingsArray.count {
                        completion(bookingsArray)
                    }
                }
            }
        }

    }
}
