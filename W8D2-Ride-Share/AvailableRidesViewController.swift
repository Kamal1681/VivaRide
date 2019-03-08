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
    var startLocation: CLLocationCoordinate2D?
    var endLocation: CLLocationCoordinate2D?
    var tripStartTime: Date?
    var ridesArray = [Ride]()
    
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
        
        let ride1 = Ride(startLocation: CLLocationCoordinate2D(latitude: 43.653226, longitude: -79.3831843), endLocation: CLLocationCoordinate2D(latitude: 49.2827291, longitude: -123.1207375), tripStartTime: Date.init(), estimatedArrivalTime: Date.init(), tripDuration: "1 days, 16 hours, 32 minutes", distance: 20)
        
        ridesArray.append(ride1)
        ridesArray.append(ride1)
        ridesArray.append(ride1)
        ridesArray.append(ride1)
        ridesArray.append(ride1)
        ridesArray.append(ride1)
        ridesArray.append(ride1)
        ridesArray.append(ride1)
        ridesArray.append(ride1)
        
        ridesArray[0].driverName = "Bod"
        ridesArray[0].driverPhoneNumber = "+12223334455"
        
        // Get all locations within 10 miles of startLocation
        getDocumentNearBy(latitude: Double(startLocation!.latitude), longitude: Double(startLocation!.longitude), distance: 10)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // START auth_listener
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.user = user
        }
        // END auth_listener
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return ridesArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

//        let ride2 = Ride(startLocation: CLLocationCoordinate2D(latitude: 43.653226, longitude: -79.3831843), endLocation: CLLocationCoordinate2D(latitude: 49.2827291, longitude: -123.1207375), tripStartTime: Date.init(), estimatedArrivalTime: Date.init(), tripDuration: "1 days, 16 hours, 32 minutes", distance: 1000)
//
//        ridesArray.append(ride2)
//        ridesArray[1].driverName = "Ted"
//        ridesArray[1].driverPhoneNumber = "+12223334455"
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath) as! AvailableRidesTableViewCell
        let ride = self.ridesArray[indexPath.row]
        
        cell.configureCell(ride: ride)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    
    //MARK: - Geo Query
    
    func getDocumentNearBy(latitude: Double, longitude: Double, distance: Double) {
        
        //        var geoPoinLocation =  rideArray[0].startLocation?.toGeopoint()
        
        // ~1 mile of lat and lon in degrees
        let lat = 0.0144927536231884
        let lon = 0.0181818181818182
        
        let lowerLat = latitude - (lat * distance)
        let lowerLon = longitude - (lon * distance)
        
        let greaterLat = latitude + (lat * distance)
        let greaterLon = longitude + (lon * distance)
        
        let lesserGeopoint = GeoPoint(latitude: lowerLat, longitude: lowerLon)
        let greaterGeopoint = GeoPoint(latitude: greaterLat, longitude: greaterLon)
        
        let docRef = db.collection("rides")
        let query = docRef.whereField("startLocation", isGreaterThan: lesserGeopoint).whereField("startLocation", isLessThan: greaterGeopoint)
        
        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                var i = 0
                for document in snapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    print(document.get("tripDuration") as! String)
                    
                    let startLocationGeoPoint = document.get("startLocation") as! GeoPoint
                    let endLocationGeoPoint = document.get("endLocation") as! GeoPoint
                    print(startLocationGeoPoint)
                    print(endLocationGeoPoint)
                    
                    self.ridesArray[i].startLocation = CLLocationCoordinate2D(latitude: startLocationGeoPoint.latitude, longitude: startLocationGeoPoint.longitude)
                    self.ridesArray[i].endLocation = CLLocationCoordinate2D(latitude: endLocationGeoPoint.latitude, longitude: endLocationGeoPoint.longitude)
                    
//                    self.ridesArray[0].tripStartTime = document.get("tripStartTime") as! Date
//                    self.ridesArray[0].estimatedArrivalTime = document.get("estimatedArrivalTime") as! Date

                    self.ridesArray[i].price = document.get("price") as? Float
                    self.ridesArray[i].tripDuration = document.get("tripDuration") as? String
                    self.ridesArray[i].distance = document.get("distance") as! Double
                    print(self.ridesArray[i].distance)
                    
                    
//                    self.ridesArray[0].tripStatus = document.get("tripStatus") as! TripStatus
                    self.ridesArray[i].numberOfSeats = document.get("numberOfSeats") as! Int
                    i = i + 1
                    print(i)
                    
                    
                }
                self.tableView.reloadData()
            }
        }
    }
    
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        <#code#>
//    }

  
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
