//
//  AvailableRidesViewController.swift
//  W8D2-Ride-Share
//
//  Created by Pavel on 2019-02-28.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase

class AvailableRidesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //Setting Firestore
    var db: Firestore!
    var settings: FirestoreSettings!
    
    //Handler for checking user aithorization
    var user: FirebaseAuth.User?
    var handle: AuthStateDidChangeListenerHandle? = nil
    
    //Other properties

    var ride: Ride?


    var startLocation: CLLocationCoordinate2D!
    var endLocation: CLLocationCoordinate2D!
    var tripStartTime: Date!
    
    //Available rides array

    var ridesArray = [Ride]()
    var filteredArrayByEndLocation = [Ride]()
    var filteredArrayByDate = [Ride]()
    var filteredArrayByStatus = [Ride]()
    
    //TableView
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // START setup for Firestore
        settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        // END setup for Firestore
        
        //Print data from previous VC
        print(startLocation)
        print(endLocation)
        print(tripStartTime)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // START auth_listener
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.user = user
        }
        // END auth_listener
        
        //Make arrays empty when view appear in case user came from ride details VC
        ridesArray = []
        filteredArrayByEndLocation = []
        filteredArrayByDate = []
        filteredArrayByStatus = []
        
        // Get all locations within 10 miles of startLocation
        guard let startLocation = startLocation, let endLocation = endLocation, let tripstartTime = tripStartTime else {
            return
        }
        getDocumentNearBy(latitudeStartLocation: Double(startLocation.latitude), longitudeStartLocation: Double(startLocation.longitude), latitudeEndLocation: Double(endLocation.latitude), longitudeEndLocation: Double(endLocation.longitude), tripStartTime: tripStartTime, distance: 10)
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

       return filteredArrayByStatus.count

    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath) as! AvailableRidesTableViewCell

        ride = self.filteredArrayByStatus[indexPath.row]
        
        guard let ride = ride else {
            return cell
        }
        
        print("IndexPathRow: \(indexPath.row)")
        print(self.filteredArrayByStatus[indexPath.row].tripDuration)

        cell.configureCell(ride: ride)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    
    //MARK: - Geo Query
    
    func getDocumentNearBy(latitudeStartLocation: Double, longitudeStartLocation: Double, latitudeEndLocation: Double, longitudeEndLocation: Double, tripStartTime: Date, distance: Double) {
        
        let lesserStartLocation = lesserGeoPoint(latitude: latitudeStartLocation, longitude: longitudeStartLocation, distance: distance)
        let greaterStartLocation = greaterGeoPoint(latitude: latitudeStartLocation, longitude: longitudeStartLocation, distance: distance)
        
        let docRef = db.collection("rides")
        let query = docRef
            .whereField("startLocation", isGreaterThan: lesserStartLocation)
            .whereField("startLocation", isLessThan: greaterStartLocation)
        
        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in snapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    print(document.get("tripDuration") as! String)
                    
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
                   
                    print(startLocationGeoPoint)
                    print(endLocationGeoPoint)
                    print(userID)
                    print(price as! Float)
                    
                    let ride = Ride(startLocation: CLLocationCoordinate2D(latitude: startLocationGeoPoint.latitude, longitude: startLocationGeoPoint.longitude), endLocation: CLLocationCoordinate2D(latitude: endLocationGeoPoint.latitude, longitude: endLocationGeoPoint.longitude), tripStartTime: tripStartTime.dateValue(), estimatedArrivalTime: estimatedArrivalTime.dateValue(), tripDuration: tripDuration, distance: distance, userID: userID, rideID: rideID, userInfo: nil, price: price, numberOfSeats: numberOfSeats, numberOfAvailableSeats: numberOfAvailableSeats, tripStatus: tripStatus, bookings: nil)
                    
                    self.ridesArray.append(ride)
                }
                
                //Get driver infromation from Firestore user collection
                for index in 0..<self.ridesArray.count {
                    var userInfo: UserInfo?
                    let userID = self.ridesArray[index].userID
                    
                    let driver = self.db.collection("users").whereField("uid", isEqualTo: userID as! String)
                    
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
                            
                            print(snapshot!.documents.first?.get("name") as! String)
                            print(userInfo?.name as! String)
                            self.ridesArray[index].userInfo = userInfo
                        }
                        self.tableView.reloadData()
                    }
                }
                
                //Filtering results for end location from ridesArray
                let lesserEndLocation = self.lesserGeoPoint(latitude: latitudeEndLocation, longitude: longitudeEndLocation, distance: distance)
                let greaterEndLocation = self.greaterGeoPoint(latitude: latitudeEndLocation, longitude: longitudeEndLocation, distance: distance)
                
                self.filteredArrayByEndLocation = self.ridesArray.filter( {Double(($0.endLocation!.latitude)) >= lesserEndLocation.latitude && Double(($0.endLocation!.latitude)) <= greaterEndLocation.latitude}).map({ return $0 })
                print("Filtered array is:\(self.filteredArrayByEndLocation)")
                
                //Filtering results by date
                let lessertripStartTime = self.tripStartTime
                let greatertripStartTime = self.tripStartTime?.addingTimeInterval(86400)
                
                self.filteredArrayByDate = self.filteredArrayByEndLocation.filter( { $0.tripStartTime! >= lessertripStartTime! && $0.tripStartTime! <= greatertripStartTime!}).map({ return $0 })
                print("Filtered array is:\(self.filteredArrayByDate)")
                
                //Filterring results by status
                self.filteredArrayByStatus = self.filteredArrayByDate.filter( { $0.tripStatus == TripStatus.available}).map({ return $0 })
                print("Filtered array is:\(self.filteredArrayByStatus)")
                
                //Reload Table View with results from Firebase
                if self.filteredArrayByStatus.count == 0 {
                    let alert = UIAlertController(title: "No Rides", message: "No rides available for that search request", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(alert: UIAlertAction!) in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                    
                }
                else {
                    self.tableView.reloadData()
                }
                
            }
        }
    }
    
    //MARK: - Calculating lesser and greater GeoPoints
    func lesserGeoPoint(latitude: Double, longitude: Double, distance: Double) -> GeoPoint {
        // ~1 mile of lat and lon in degrees
        let lat = 0.0144927536231884
        let lon = 0.0181818181818182
        
        let lowerLat = latitude - (lat * distance)
        let lowerLon = longitude - (lon * distance)
        
        let lesserGeopoint = GeoPoint(latitude: lowerLat, longitude: lowerLon)
        
        return lesserGeopoint
    }
    
    func greaterGeoPoint(latitude: Double, longitude: Double, distance: Double) -> GeoPoint {
        // ~1 mile of lat and lon in degrees
        let lat = 0.0144927536231884
        let lon = 0.0181818181818182
        
        let greaterLat = latitude + (lat * distance)
        let greaterLon = longitude + (lon * distance)

        let greaterGeopoint = GeoPoint(latitude: greaterLat, longitude: greaterLon)
        
        return greaterGeopoint
    }
    
    // MARK: - Navigation
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Segue to the second view controller
        self.performSegue(withIdentifier: "goToAvailableRideDetails", sender: self)
    }
    
    // This function is called before the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToAvailableRideDetails", let destinationVC = segue.destination as? RideDetailsViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.ride = filteredArrayByStatus[indexPath.row]
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
