//
//  OfferRideViewController.swift
//  W8D2-Ride-Share
//
//  Created by Pavel on 2019-02-28.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class OfferRideViewController: UIViewController, UISearchBarDelegate, LocateOnTheMap {
    
    @IBOutlet weak var tripDate: UIDatePicker!
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var startPointText: UINavigationItem!
    @IBOutlet weak var endPointText: UINavigationItem!
    var searchResultController:SearchResultsController!
    var resultsArray = [String]()
    var googleMapsView: GMSMapView!
    var startPoint: CLLocationCoordinate2D?
    var endPoint: CLLocationCoordinate2D?
    var startPointEndPointFlag: Bool = false
    var tripStartTime: Date?
    var estimtedArrivalTime: Date?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.googleMapsView = GMSMapView(frame: self.mapView.frame)

        self.view.addSubview(self.googleMapsView)
        searchResultController = SearchResultsController()
        searchResultController.delegate = self
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showSearchController(_ sender: AnyObject) {
        let searchController = UISearchController(searchResultsController: searchResultController)
        searchController.searchBar.delegate = self
        self.present(searchController, animated: true, completion: nil)
 
    }

    @IBAction func searchForPickUpLocation(_ sender: Any) {
        startPointEndPointFlag = false
        showSearchController(self)
        
    }
    
    @IBAction func searchForDropOffLocation(_ sender: Any) {
        startPointEndPointFlag = true
        showSearchController(self)
        
    }
    
    func locateWithLongitude(lon: Double, andLatitude lat: Double, andTitle title: String) {
        
        DispatchQueue.main.async { () -> Void in
            let position = CLLocationCoordinate2DMake(lat, lon)
            let marker = GMSMarker(position: position)
            
            let camera  = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 15)
            self.googleMapsView.camera = camera
            
            marker.title = title
            marker.map = self.googleMapsView

            self.createPath(position: position, title: title)
        }
        
    }
    
    func createPath(position: CLLocationCoordinate2D, title: String) {
 
        
        if(!startPointEndPointFlag) {
            startPoint = position
            let marker1 = GMSMarker(position: startPoint!)
            self.startPointText.title = title
            marker1.map = googleMapsView
        }
        else {
            endPoint = position
            let marker2 = GMSMarker(position: endPoint!)
            self.endPointText.title = title
            marker2.map = googleMapsView
        }
        
        guard let startPoint = startPoint, let endPoint = endPoint else {
            return
        }
        
        if ((startPoint != nil) && (endPoint != nil)) {
            
            let path = GMSMutablePath()
            path.add(CLLocationCoordinate2D(latitude: (startPoint.latitude), longitude: (startPoint.longitude)))
            path.add(CLLocationCoordinate2D(latitude: (endPoint.latitude), longitude: (endPoint.longitude)))
            
            let rectangle = GMSPolyline(path: path)
            rectangle.strokeWidth = 2
            rectangle.map = googleMapsView
            self.mapView = googleMapsView
            

            
            let url = NSURL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(String(describing: startPoint.latitude)),\(String(describing: startPoint.longitude))&destination=\(String(describing: endPoint.latitude)),\(String(describing: endPoint.longitude))&key=\(Constants.googleApiKey)")
        
            let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
                
                do {
                    if data != nil {
                        let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as!  [String:AnyObject]
                        
                        let status = dict["status"] as! String
                        var routesArray:String!
                        if status == "OK" {
                            routesArray = ((((dict["routes"]!as! [Any])[0] as! [String:Any])["overview_polyline"] as! [String:Any])["points"] as! String)
                            print("routesArray: \(String(describing: routesArray))")
                        }
                        guard let linesArray = routesArray else {
                            print("Not Found")
                            return
                        }
                         DispatchQueue.main.async {
                            let path = GMSPath.init(fromEncodedPath: linesArray)
                            let singleLine = GMSPolyline.init(path: path)
                            singleLine.strokeWidth = 3.0
                            singleLine.strokeColor = .red
                            singleLine.map = self.googleMapsView
                            let cameraBounds = GMSCoordinateBounds.init(coordinate: startPoint, coordinate: endPoint)
                           let camera = GMSCameraUpdate.fit(cameraBounds)
                            GMSCameraUpdate.fit(cameraBounds)
                            self.googleMapsView.animate(with: camera)
                           
                        }
                        
                    }
                } catch {
                    print("Error")
            }
        }
        
            task.resume()
            calculateDistance()
            calculateEstimatedTime()
        }
        
    }
    
//    @objc func rideOptions(_ sender: UITapGestureRecognizer) {
//
//        let confirmationViewController = storyboard?.instantiateViewController(withIdentifier: "confirm ride") as! OfferRideConfirmationViewController
//        self.addChild(confirmationViewController)
//        self.view.addSubview(confirmationViewController.view)
//        confirmationViewController.didMove(toParent: self)
//    }
    
    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String){
        
        let placesClient = GMSPlacesClient()
        
        placesClient.autocompleteQuery(searchText, bounds: nil, filter: nil) { (results, error:Error?) -> Void in
            self.resultsArray.removeAll()
            if results == nil {
                return
            }
            for result in results!{
                if let result = result as? GMSAutocompletePrediction{
                    self.resultsArray.append(result.attributedFullText.string)
                }
            }
            self.searchResultController.reloadDataWithArray(array: self.resultsArray)
        }

    }
    
    func calculateDistance() {
        
        guard let startPoint = startPoint, let endPoint = endPoint else {
                return
        }
        
        let startLocation = CLLocation(latitude: startPoint.latitude, longitude: startPoint.longitude)
        let endLocation = CLLocation(latitude: endPoint.latitude, longitude: endPoint.longitude)
        let distance = (startLocation.distance(from: endLocation) / 1000.0)
        print("\(distance) km")

    }
    func calculateEstimatedTime() {
        
        guard let startPoint = startPoint, let endPoint = endPoint else {
            return
        }
        
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(startPoint.latitude),\(startPoint.longitude)&destination=\(endPoint.latitude),\(endPoint.longitude)&key=\(Constants.googleApiKey)")
        let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
            
            do {
                if data != nil {
                    let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as!  [String:AnyObject]
                    
                    let routes = dict["routes"] as! NSArray
                    let legs = routes.value(forKey: "legs") as! NSArray
                    //let city = results[0].address_components value(forKey: "address_components")
                    let duration = legs.value(forKey: "duration") as! NSArray
                    let timeInSeconds = (duration.object(at: 0) as! NSArray).value(forKey: "value")
                    print(timeInSeconds)
                    //self.calculateEndTime(timeInSeconds: timeInSeconds as! Int)
                }
            }
            catch {
                print("Error")
            }
            
        }
        task.resume()
        
    }
    
    func calculateEndTime(timeInSeconds: Int) {
        
        guard let tripStartTime = tripStartTime else {
            return
        }
        estimtedArrivalTime = Calendar.current.date(byAdding: .second, value: timeInSeconds, to: tripStartTime)
        print(tripStartTime)
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
