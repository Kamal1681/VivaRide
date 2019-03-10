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
    @IBOutlet weak var additionalInfoTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // START setup for Firestore
        settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        // END setup for Firestore
        
        print("Distance is: \(ride!.distance)")
        print("Name is \(ride!.userInfo?.name)")
        
        //Setting labels and other UI
        getAddressFromLocation(location: ride.startLocation!, complete: { (city) in
            OperationQueue.main.addOperation {
                self.startLocationLabel.text = city
            }
        })
        getAddressFromLocation(location: ride.endLocation!, complete: { (city) in
            OperationQueue.main.addOperation {
                self.endLocationLabel.text = city
            }
        })
        
        //Date and Time labels
        dateLabel.text = stringDateFormat(from: ride.tripStartTime!)
        tripStartTimeLabel.text = stringHoursMinutesFormat(from: ride.tripStartTime!)
        estimatedArrivalTimeLabel.text = stringHoursMinutesFormat(from: ride.estimatedArrivalTime!)
        
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
        
        //Additional info labels
        additionalInfoTextView.text = "Additional information will apperar in that field and distance of the ride is \(ride.distance)."
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
    
    @IBAction func continueButtonDidTap(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goToBookRideConfirmation", sender: self)
    }
    
    // This function is called before the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToBookRideConfirmation", let destinationVC = segue.destination as? BookRideConfirmationViewController {
                destinationVC.ride = self.ride
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
