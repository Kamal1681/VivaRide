//
//  FindRideViewController.swift
//  W8D2-Ride-Share
//
//  Created by Pavel on 2019-02-28.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class FindRideViewController: UIViewController, UISearchBarDelegate, LocateOnTheMap {

    var searchResultController: SearchResultsController!
    var resultsArray = [String]() //autocomplete results
    var startPointEndPointFlag: Bool = false
    var tripStartTime: Date!
    var startPoint: CLLocationCoordinate2D?
    var endPoint: CLLocationCoordinate2D?

    
    @IBOutlet weak var tripDate: UIDatePicker!
    @IBOutlet weak var startAddress: UINavigationItem!
    @IBOutlet weak var destinationAddress: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tripDate.minimumDate = Date().rounded(minutes: 15, rounding: .ceil)
        tripDate.date = Date().rounded(minutes: 15, rounding: .floor)
        
        if tripDate.date != nil {
            tripStartTime = tripDate.date.rounded(minutes: 15).rounded(seconds: 60)
        }
        else {
            tripStartTime = Date()
        }
        // Do any additional setup after loading the view.
    }
   override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    
        searchResultController = SearchResultsController()
        searchResultController.delegate = self
   
    }
    
    func locateWithLongitude(lon:Double, andLatitude lat:Double, andTitle title: String) {
        
        DispatchQueue.main.async {
            let position = CLLocationCoordinate2DMake(lat, lon)
            if(!self.startPointEndPointFlag) {
                
                self.startAddress.title = title
                self.startPoint = position
            }
            else {
                self.destinationAddress.title = title
                self.endPoint = position
            }
           
        }
        
    }
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "search" {
        let availableRidesViewController: AvailableRidesViewController = segue.destination as! AvailableRidesViewController
        availableRidesViewController.startLocation = startPoint
        availableRidesViewController.endLocation = endPoint
        availableRidesViewController.tripStartTime = tripStartTime
        print(tripStartTime)
        }
    }
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func setStartTime(_ sender: Any) {
        if tripDate.date != nil {
            tripStartTime = tripDate.date.rounded(minutes: 15).rounded(seconds: 60)
        }
        else {
            tripStartTime = Date()
        }
        

    }
    

    @IBAction func searchForPickUpLocation(_ sender: Any) {
        startPointEndPointFlag = false
        showSearchController(self)
    
    }
    
    @IBAction func searchForDropOffLocation(_ sender: Any) {
        startPointEndPointFlag = true
        showSearchController(self)
    }
    func showSearchController(_ sender: AnyObject) {
        let searchController = UISearchController(searchResultsController: searchResultController)
        searchController.searchBar.delegate = self
        self.present(searchController, animated: true, completion: nil)
        
    }
    
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
    /*
    // MARK: - Navigation
     @IBAction func backButton(_ sender: Any) {
     }
     @IBAction func searchForDropOffLocation(_ sender: Any) {
     }
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
