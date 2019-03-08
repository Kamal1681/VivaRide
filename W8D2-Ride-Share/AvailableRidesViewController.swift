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
    var startLocation: CLLocationCoordinate2D?
    var endLocation: CLLocationCoordinate2D?
    var tripStartTime: Date?
    var ridesArray = [Ride]()
    var filteredArrayByEndLocation = [Ride]()
    
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
        

        
        // Get all locations within 10 miles of startLocation
        getDocumentNearBy(latitudeStartLocation: Double(startLocation!.latitude), longitudeStartLocation: Double(startLocation!.longitude), latitudeEndLocation: Double(endLocation!.latitude), longitudeEndLocation: Double(endLocation!.longitude), tripStartTime: tripStartTime ?? Date(), distance: 10)
        
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
        return filteredArrayByEndLocation.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath) as! AvailableRidesTableViewCell
        ride = self.filteredArrayByEndLocation[indexPath.row]
        print("IndexPathRow: \(indexPath.row)")
        print(self.filteredArrayByEndLocation[indexPath.row].tripDuration)
        guard let ride = ride else {
            return cell
        }
        cell.configureCell(ride: ride)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    
    //MARK: - Geo Query
    
    func getDocumentNearBy(latitudeStartLocation: Double, longitudeStartLocation: Double, latitudeEndLocation: Double, longitudeEndLocation: Double, tripStartTime: Date, distance: Double) {
        
        let lesserStartLocation = lesserGeoPoint(latitude: latitudeStartLocation, longitude: longitudeStartLocation, distance: distance)
        let greaterStartLocation = greaterGeoPoint(latitude: latitudeStartLocation, longitude: longitudeStartLocation, distance: distance)
        
        let docRef = db.collection("rides")
        let query = docRef
            .whereField("startLocation", isGreaterThan: lesserStartLocation)
            .whereField("startLocation", isLessThan: greaterStartLocation)
//            .whereField("tripStartTime", isEqualTo: tripStartTime)
        
        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in snapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    print(document.get("tripDuration") as! String)
                    
                    let startLocationGeoPoint = document.get("startLocation") as! GeoPoint
                    let endLocationGeoPoint = document.get("endLocation") as! GeoPoint
                    let price = document.get("price") as? Float
                    let tripDuration = document.get("tripDuration") as? String
                    let distance = document.get("distance") as! Double
                    let numberOfSeats = document.get("numberOfSeats") as! Int
                    
                    print(startLocationGeoPoint)
                    print(endLocationGeoPoint)
                    
                    let ride = Ride(startLocation: CLLocationCoordinate2D(latitude: startLocationGeoPoint.latitude, longitude: startLocationGeoPoint.longitude), endLocation: CLLocationCoordinate2D(latitude: endLocationGeoPoint.latitude, longitude: endLocationGeoPoint.longitude), tripStartTime: Date.init(), estimatedArrivalTime: Date.init(), tripDuration: tripDuration ?? "No value", distance: distance)
                    
                    self.ridesArray.append(ride)
                }
                
                //Filtering results for end location from ridesArray
                let lesserEndLocation = self.lesserGeoPoint(latitude: latitudeEndLocation, longitude: longitudeEndLocation, distance: distance)
                let greaterEndLocation = self.greaterGeoPoint(latitude: latitudeEndLocation, longitude: longitudeEndLocation, distance: distance)
                
                self.filteredArrayByEndLocation = self.ridesArray.filter( {Double(($0.endLocation!.latitude)) >= lesserEndLocation.latitude && Double(($0.endLocation!.latitude)) <= greaterEndLocation.latitude}).map({ return $0 })
                print("Filtered array is:\(self.filteredArrayByEndLocation)")
                
                self.tableView.reloadData()
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
    


  
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
