//
//  CancelBookedRide.swift
//  W8D2-Ride-Share
//
//  Created by Pavel on 2019-03-12.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps

class CancelBookedRide {

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
    static func cancelRide(for booking: Booking, ride: Ride, driver: UserInfo, viewController: UIViewController) {
        setUpFirestore()
        
        if let bookingStatus = booking.status,
            bookingStatus == BookingStatus.cancelled.rawValue
        {
            errorAlert(errorMessage: "Your booking has been already canceled.", viewController: viewController)
        }
        else if
            Auth.auth().currentUser != nil,
            let bookingID = booking.bookingID
        {
            //Change booking document status to Cancel in Firestore
            db.collection("bookings").document(bookingID).setData([ "status": BookingStatus.cancelled.rawValue ], merge: true) { err in
                if let err = err {
                    print("Error writing document: \(err.localizedDescription)")
                    errorAlert(errorMessage: "Your booking has not canceled. Please try again or contact Viva Ride Team.", viewController: viewController)
                } else {
                    //Increase number of available seats  in Rides collection after booking cancelation
                    updateRideDetails(ride: ride, booking: booking, driver: driver, viewController: viewController)
                }
            }
        }
        else {
            print("Error! User do not login")
            errorAlert(errorMessage: "Your booking has not canceled. Please try again or contact Viva Ride Team.", viewController: viewController)
        }
    }

    //MARK: - Update number of available seats for the ride and ride status
    static func updateRideDetails(ride: Ride, booking: Booking, driver: UserInfo, viewController: UIViewController) {
        if
            let startLocation = ride.startLocation,
            let endLocation = ride.endLocation,
            let rideStartDate = ride.tripStartTime,
            let rideID = ride.rideID,
            let numberOfBookingSeats = booking.numberOfBookingSeats,
            let numberOfAvailableSeats = ride.numberOfAvailableSeats,
            let numberOfSeats = ride.numberOfSeats,
            let driverToken = driver.pushNotificationToken
        {
            let newNumberOfAvailableSeats = numberOfAvailableSeats + numberOfBookingSeats
            
            if newNumberOfAvailableSeats > numberOfSeats  {
                print("Error! New number of available seats cound not be more than number of seats in the car.")
                return
            }
            
            db.collection("rides").document(rideID).setData([
                "numberOfAvailableSeats": newNumberOfAvailableSeats
            ], merge: true) { err in
                if let err = err {
                    print("Error writing document: \(err.localizedDescription)")
                } else {
                    //Send push notification for the driver
                    PushNotification.cancelationMessage(numberOfBookingSeats: numberOfBookingSeats, startLocation: startLocation, endLocation: endLocation, rideStartDate: rideStartDate) { message in
                        PushNotification.sendTo(token: driverToken, title: "Booking cancelation", body: message)
                    }

                    
                    //Present cancelation alert to the user
                    infoAlert(title: "Cancelation", message: "Your ride was successfully canceled! We will notify the driver.", dismissVC: true, viewController: viewController)
                    print("Booking was successfully canceled! Number of available seats for the rideID \(rideID) was successfully updated!")
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
