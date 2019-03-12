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
    //Setting Firestore
    var db: Firestore!
    var settings: FirestoreSettings!
    
    //Handler for checking user aithorization
    var user: FirebaseAuth.User?
    var handle: AuthStateDidChangeListenerHandle? = nil
    
    //Passing properties
    var ride: Ride!
    
    //Push Notification properties
    var startLocation: String = "start location"
    var endLocation: String = "end location"
    var rideStartDate: String = "someday"
    
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
   // @IBOutlet weak var additionalInfoTextView: UITextView!
    @IBOutlet weak var numberOfBookingSeatsLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    @IBOutlet weak var bookButton: UIButton!
    
    @IBOutlet weak var contactTheDriverButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // START setup for Firestore
        settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        // END setup for Firestore
        
        print("Distance is: \(ride!.distance)")
        print("Name is \(ride!.userInfo?.name)")
         print(ride.userInfo?.name ?? "Did not pass driver name throuht sefue")
        //Setting labels and other UI
        getAddressFromLocation(location: ride.startLocation!, complete: { (city) in
            OperationQueue.main.addOperation {
                self.startLocation = city
                self.startLocationLabel.text = city
            }
        })
        getAddressFromLocation(location: ride.endLocation!, complete: { (city) in
            OperationQueue.main.addOperation {
                self.endLocation = city
                self.endLocationLabel.text = city
            }
            
        })
       
        
        if ride.numberOfAvailableSeats! > 0 {
            numberOfBookingSeatsLabel.text = "1"
            totalPriceLabel.text = "Price: CAD \(ride.price as! Float)"
        }
        else {
            numberOfBookingSeatsLabel.text = "0"
            totalPriceLabel.text = "Price: CAD 0.0"
        }
        
        //Date and Time labels
        dateLabel.text = stringDateFormat(from: ride.tripStartTime!)
        tripStartTimeLabel.text = stringHoursMinutesFormat(from: ride.tripStartTime!)
        estimatedArrivalTimeLabel.text = stringHoursMinutesFormat(from: ride.estimatedArrivalTime!)
        rideStartDate = stringDateFormat(from: ride.tripStartTime!)
        
        //Driver name label
        driverNameLabel.text = ride.userInfo?.name
        
        //Number of seats label
        numberOfAvailableSeats.numberOfLines = 0
        numberOfAvailableSeats.text = "Available seats: \(ride.numberOfAvailableSeats as! Int) out of \(ride.numberOfSeats as! Int)"
        
        //Price label
        let priceFormated = String(format:"%.2f", ride.price ?? 999.99)
        price.text = "CAD \(priceFormated)"
        
        //Car info labels
        carModelLabel.text = ride.userInfo?.carModel
        carColorLabel.text = ride.userInfo?.carColor
        bookButton.configure(button: bookButton)
        contactTheDriverButton.configure(button: contactTheDriverButton)
        //Additional info labels
        //additionalInfoTextView.text = "Additional information will apperar in that field and distance of the ride is \(ride.distance)."
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // START auth_listener
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.user = user
        }
        // END auth_listener
        
        getNumberOfSeatsFromFirestore()
        
    }
    
    //MARK: - Firestore
    
    func getNumberOfSeatsFromFirestore() {
        guard let rideID = ride.rideID else {
            print("Error! Can not run rideID = ride.rideID")
            return
        }
        let rideDocument = self.db.collection("rides").whereField("rideID", isEqualTo: rideID)
        
        rideDocument.getDocuments { snapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                let numberOfSeats = snapshot!.documents.first?.get("numberOfSeats") as! Int
                let numberOfAvailableSeats = snapshot!.documents.first?.get("numberOfAvailableSeats") as! Int

                self.ride.numberOfSeats = numberOfSeats
                self.ride.numberOfAvailableSeats = numberOfAvailableSeats
                
                //Number of seats label
                self.numberOfAvailableSeats.text = "Available seats: \(numberOfAvailableSeats) out of \(numberOfSeats)"
            }
        }
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

    // MARK: - Navigation
    
//    @IBAction func continueButtonDidTap(_ sender: UIButton) {
//        self.performSegue(withIdentifier: "goToBookRideConfirmation", sender: self)
//    }
//
//    // This function is called before the segue
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        if segue.identifier == "goToBookRideConfirmation", let destinationVC = segue.destination as? BookRideConfirmationViewController {
//                destinationVC.ride = self.ride
//        }
//    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
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
        sender.pressed()
        let alert = UIAlertController(title: "Confirm", message: "Confirm Booking", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { alert -> Void in
            guard
                let rideID = self.ride.rideID,
                let numberOfBookingSeats = Int(self.numberOfBookingSeatsLabel.text!),
                //            let numberOfSeats = ride.numberOfSeats,
                let numberOfAvailableSeats = self.ride.numberOfAvailableSeats,
                let driverToken = self.ride.userInfo?.pushNotificationToken
                else {
                    print("Error in book button did tap method! Can not assign rideID and numberOfBookingSeats to the variables.")
                    return
            }
            let status = "confirmed" //By now all rides will be automatically confirmed
            if numberOfAvailableSeats > 0 && numberOfBookingSeats <= numberOfAvailableSeats {
                self.bookRide(rideID: rideID, numberOfBookingSeats: numberOfBookingSeats, numberOfAvailableSeats: numberOfAvailableSeats, bookingStatus: status, driverToken: driverToken)
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
    
    @IBAction func contactDriverButtonTapped(_ sender: UIButton) {
        sender.pressed()
        
        if let phoneNumber = ride.userInfo?.phoneNumber {
            makePhoneCall(to: phoneNumber)
        }
    }
    //MARK: Book the ride function
    func bookRide(rideID: String, numberOfBookingSeats: Int, numberOfAvailableSeats: Int, bookingStatus: String, driverToken: String) {
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
                    self.updateRideDetails(rideID: rideID, numberOfBookingSeats: numberOfBookingSeats, numberOfAvailableSeats: numberOfAvailableSeats, driverToken: driverToken)
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
    func updateRideDetails(rideID: String, numberOfBookingSeats: Int, numberOfAvailableSeats: Int, driverToken: String) {
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
                
                //Send push notification for the driver
                PushNotification.sendTo(token: driverToken, title: "New booking", body: "\(self.correctString(for: numberOfBookingSeats)) booked for the ride from \(self.startLocation) to \(self.endLocation) on \(self.rideStartDate)")
                
                self.infoAlert(title: "Confirmation", message: "Your ride was successfully booked!", dismissVC: true)
            }
        }
    }
    
    //MARK: - Alerts functions
    func errorAlert(errorMessage: String) {
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func infoAlert(title: String, message: String, dismissVC: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(alert: UIAlertAction!) in
            if dismissVC {
                self.dismiss(animated: true, completion: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func correctString(for numberOfBookingSeats: Int) -> String {
        var resultString: String = ""
        
        if numberOfBookingSeats == 1 {
            resultString = "1 seat was"
        }
        else if numberOfBookingSeats > 1 {
            resultString = "\(numberOfBookingSeats) seats were"
        }
        
        return resultString
    }
    
    func makePhoneCall(to phoneNumber: String) {
        if let phoneURL = NSURL(string: ("tel://" + phoneNumber)) {
            let alert = UIAlertController(title: ("Do you want to call the driver?"), message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Call", style: .default, handler: { (action) in
                UIApplication.shared.open(phoneURL as URL, options: [:], completionHandler: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
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
