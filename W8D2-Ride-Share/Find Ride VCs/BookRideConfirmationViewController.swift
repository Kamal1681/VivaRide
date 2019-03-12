//
//  BookRideConfirmationViewController.swift
//  W8D2-Ride-Share
//
//  Created by Pavel on 2019-02-28.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit
import Firebase

class BookRideConfirmationViewController: UIViewController {
    //Setting Firestore
    var db: Firestore!
    var settings: FirestoreSettings!
    
    //Handler for checking user aithorization
    var user: FirebaseAuth.User?
    var handle: AuthStateDidChangeListenerHandle? = nil
    
    //Passing properties
    var ride: Ride!
    
    //UI properties
    @IBOutlet weak var numberOfBookingSeatsLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    @IBAction func bookButton(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // START setup for Firestore
        settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        // END setup for Firestore
        
        print(ride.userInfo?.name ?? "Did not pass driver name throuht sefue")
        
        if ride.numberOfAvailableSeats! > 0 {
            numberOfBookingSeatsLabel.text = "1"
            totalPriceLabel.text = "Price: CAD \(ride.price as! Float)"
        }
        else {
            numberOfBookingSeatsLabel.text = "0"
            totalPriceLabel.text = "Price: CAD 0.0"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // START auth_listener
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.user = user
        }
        // END auth_listener
    }
    
    //MARK: - IB Actions
    @IBAction func minusButtonDidTap(_ sender: UIButton) {
        //Calculating number of booking seats for the ride
        var numberOfBookingSeats: Int = Int(numberOfBookingSeatsLabel.text ?? "1")!
        if numberOfBookingSeats > 1 {
            numberOfBookingSeats -= 1
        }
        numberOfBookingSeatsLabel.text = "\(numberOfBookingSeats)"
        
        //Calculating the total price for the ride
        guard let ridePrice = ride.price  else {
            print("Error! Can not calculate the total price.")
            return
        }
        if numberOfBookingSeats > 0 {
            let totalPrice = Float(numberOfBookingSeats) * ridePrice
            totalPriceLabel.text = "Price: CAD \(totalPrice)"
        }
    }
    
    @IBAction func plusButtonDidTap(_ sender: UIButton) {
        //Calculating number of booking seats for the ride
        var numberOfBookingSeats: Int = Int(numberOfBookingSeatsLabel.text ?? "1")!
        
        guard let numberOfAvailableSeats = ride.numberOfAvailableSeats else {
            print("Error! Value of available seats is nil.")
            return
        }
        if numberOfBookingSeats < numberOfAvailableSeats {
            numberOfBookingSeats += 1
        }
        numberOfBookingSeatsLabel.text = "\(numberOfBookingSeats)"
        
        //Calculating the total price for the ride
        guard let ridePrice = ride.price  else {
            print("Error! Can not calculate the total price.")
            return
        }
        if numberOfBookingSeats > 0 {
            let totalPrice = Float(numberOfBookingSeats) * ridePrice
            totalPriceLabel.text = "Price: CAD \(totalPrice)"
        }
    }
    
    //MARK: - Booking
    @IBAction func bookButtonDidTap(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Confirm", message: "Confirm Booking", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { alert -> Void in
            guard
                let rideID = self.ride.rideID,
                let numberOfBookingSeats = Int(self.numberOfBookingSeatsLabel.text!),
                //            let numberOfSeats = ride.numberOfSeats,
                let numberOfAvailableSeats = self.ride.numberOfAvailableSeats
                else {
                    print("Error in book button did tap method! Can not assign rideID and numberOfBookingSeats to the variables.")
                    return
            }
            let status = "confirmed" //By now all rides will be automatically confirmed
            if numberOfAvailableSeats > 0 && numberOfBookingSeats <= numberOfAvailableSeats {
                self.bookRide(rideID: rideID, numberOfBookingSeats: numberOfBookingSeats, numberOfAvailableSeats: numberOfAvailableSeats, bookingStatus: status)
            }
            else if numberOfAvailableSeats == 0 {
                self.errorAlert(errorMessage: "Sorry, but there are not available seats for this ride! Please, look for another ride.")
            }
            else if numberOfBookingSeats > numberOfAvailableSeats {
                self.errorAlert(errorMessage: "Number of seats that you are trying to book is bigger than number of available seats. Please, reduce number of booking seats or find another ride.")
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { alert -> Void in
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }

    
    //MARK: Book the ride function
    func bookRide(rideID: String, numberOfBookingSeats: Int, numberOfAvailableSeats: Int, bookingStatus: String) {
        if let user = self.user {
            //Create a new ride document in Firestore
            
            var ref: DocumentReference? = nil
            ref = db.collection("bookings").addDocument(data: [
                "bookingID": ref?.documentID ?? "noBookingID",
                "rideID": rideID,
                "passengerID": user.uid,
                "status": bookingStatus, //By now all rides will be automatically confirmed
                "numberOfBookingSeats": numberOfBookingSeats
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err.localizedDescription)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                    // Add rideID as a documentID
                    self.addBookingID(documentID: ref!.documentID)
                    self.updateRideDetails(rideID: rideID, numberOfBookingSeats: numberOfBookingSeats, numberOfAvailableSeats: numberOfAvailableSeats)
                }
            }
        }
        else {
            print("Error! User do not login")
        }
    }
    
    //MARK: Add bookingID to the newly created booking of the ride
    func addBookingID(documentID: String) {
        db.collection("bookings").document(documentID).setData([ "bookingID": documentID ], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err.localizedDescription)")
            } else {
                print("BookingID successfully written!")
            }
        }
    }
    
    //MARK: - Update number of available seats for the ride and ride status
    func updateRideDetails(rideID: String, numberOfBookingSeats: Int, numberOfAvailableSeats: Int) {
        var rideStatus: String = ""
        let newNumberOfAvailableSeats = numberOfAvailableSeats - numberOfBookingSeats
        
        if newNumberOfAvailableSeats == 0 {
            rideStatus = TripStatus.booked.rawValue
        }
        else if newNumberOfAvailableSeats > 0 {
            rideStatus = TripStatus.available.rawValue
        }
        else if newNumberOfAvailableSeats < 0 {
            rideStatus = "error"
            print("Error! NumberOfAvailableSeats < 0. ")
        }
        
        db.collection("rides").document(rideID).setData([
            "numberOfAvailableSeats": newNumberOfAvailableSeats,
            "status": rideStatus
        ], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err.localizedDescription)")
            } else {
                print("Ride for rideID \(rideID) successfully updated!")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    //MARK: - Alerts functions
    func errorAlert(errorMessage: String) {
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Navigation
    @IBAction func backButtonDidTap(_ sender: UIButton) {
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
