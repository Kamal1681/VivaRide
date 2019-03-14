//
//  CancelOfferedRide.swift
//  W8D2-Ride-Share
//
//  Created by Pavel on 2019-03-14.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps

class CancelOfferedRide: NSObject {

    //Setting Firestore
    static var db: Firestore!
    static var settings: FirestoreSettings!
    
    //Handler for checking user aithorization
    static var user: FirebaseAuth.User?
    static var handle: AuthStateDidChangeListenerHandle? = nil
    
    static func setUpFirestore() {
        // START setup for Firestore
        settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        // END setup for Firestore
        
        // START auth_listener
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.user = user
        }
        // END auth_listener
    }
    
    //MARK: Cancel the ride function
    static func cancelOfferedRide(for ride: Ride, viewController: UIViewController) {
        setUpFirestore()
        
        if let rideStatus = ride.tripStatus,
            rideStatus == TripStatus.cancelled
        {
            errorAlert(errorMessage: "Your ride has been already canceled.", viewController: viewController)
        }
        else if
            Auth.auth().currentUser != nil,
            let rideID = ride.rideID
        {
            //Change ride document status to Cancel in Firestore
            db.collection("rides").document(rideID).setData([ "status": TripStatus.cancelled.rawValue ], merge: true) { err in
                if let err = err {
                    print("Error writing document: \(err.localizedDescription)")
                    errorAlert(errorMessage: "Your ride has not canceled. Please try again or contact Viva Ride Team.", viewController: viewController)
                } else {
                    //Cancel all bookings for that ride
                    if
                        let bookings = ride.bookings,
                        let driver = ride.userInfo
                    {
                        var showAlert = false
                        var index = 0
                        for booking in bookings {
                            index += 1
                            if index == bookings.count {
                                showAlert = true //Show cancelation alert to the user on the last booking in the array of bookings
                            }
                            
                            var notifyPassenger = false //Send push notification for the passenger if his/her ride was not cancelled before
                            if booking.status != BookingStatus.cancelled.rawValue {
                                CancelBookedRide.cancelRide(for: booking, ride: ride, driver: driver, viewController: viewController)
                                notifyPassenger = true
                            }
                            
                            updateRideDetails(ride: ride, booking: booking, viewController: viewController, showAlert: showAlert, notifyPassenger: notifyPassenger)
                        }
                    }
                }
            }
        }
        else {
            print("Error! User do not login")
            errorAlert(errorMessage: "Your ride has not been canceled. Please try again or contact Viva Ride Team.", viewController: viewController)
        }
    }
    
    //MARK: - Update number of available seats for the ride and ride status
    static func updateRideDetails(ride: Ride, booking: Booking, viewController: UIViewController, showAlert: Bool, notifyPassenger: Bool) {
        if
            let startLocation = ride.startLocation,
            let endLocation = ride.endLocation,
            let rideStartDate = ride.tripStartTime,
            let rideID = ride.rideID,
            let numberOfBookingSeats = booking.numberOfBookingSeats,
            let passengerToken = booking.passengerInfo?.pushNotificationToken
        {
            //If showAlert is true that means that booking instanse is last in the array of bookings, so rideStatus could be changed to canceled
            var rideStatus = ""
            if showAlert {
                rideStatus = TripStatus.cancelled.rawValue
            }
            else {
                if let tripStatus = ride.tripStatus?.rawValue {
                    rideStatus = tripStatus
                }
                else {
                    print("Error! Unable to get rideStatus from ride.tripStatus?.rawValue.")
                    return
                }
            }
            
            db.collection("rides").document(rideID).setData([
                "status": rideStatus
            ], merge: true) { err in
                if let err = err {
                    print("Error writing document: \(err.localizedDescription)")
                } else {
                    //Send push notification for the passenger if his/her ride was not cancelled before
                    if notifyPassenger {
                        PushNotification.cancelationMessage(numberOfBookingSeats: numberOfBookingSeats, startLocation: startLocation, endLocation: endLocation, rideStartDate: rideStartDate) { message in
                            PushNotification.sendTo(token: passengerToken, title: "Driver canceled the ride", body: message)
                        }
                    }

                    //Present cancelation alert to the user on the last booking in the array of bookings
                    if showAlert {
                        infoAlert(title: "Cancelation", message: "Your ride was successfully canceled! We will notify the passengers.", dismissVC: true, viewController: viewController)
                        print("Ride was successfully canceled!")
                    }
                }
            }
        }
    }
    
    //MARK: - Alerts functions
    static func errorAlert(errorMessage: String, viewController: UIViewController) {
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    static func infoAlert(title: String, message: String, dismissVC: Bool, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(alert: UIAlertAction!) in
            if dismissVC {
                viewController.dismiss(animated: true, completion: nil)
            }
        }))
        viewController.present(alert, animated: true, completion: nil)
    }
    
}
