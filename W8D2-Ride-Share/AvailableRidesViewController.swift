//
//  AvailableRidesViewController.swift
//  W8D2-Ride-Share
//
//  Created by Pavel on 2019-02-28.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit
import GoogleMaps

class AvailableRidesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    

    var startPoint: CLLocationCoordinate2D?
    var endPoint: CLLocationCoordinate2D?
    var tripStartTime: Date?
    var ridesArray = [Ride]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let ride1 = Ride(startLocation: CLLocationCoordinate2D(latitude: 43.653226, longitude: -79.3831843), endLocation: CLLocationCoordinate2D(latitude: 49.2827291, longitude: -123.1207375), tripStartTime: Date.init(), estimatedArrivalTime: Date.init(), tripDuration: "1 days, 16 hours, 32 minutes", distance: 20)
        
        ridesArray.append(ride1)
        
        ridesArray[0].driverName = "Bod"
        ridesArray[0].driverPhoneNumber = "+12223334455"
        let ride2 = Ride(startLocation: CLLocationCoordinate2D(latitude: 43.653226, longitude: -79.3831843), endLocation: CLLocationCoordinate2D(latitude: 49.2827291, longitude: -123.1207375), tripStartTime: Date.init(), estimatedArrivalTime: Date.init(), tripDuration: "1 days, 16 hours, 32 minutes", distance: 1000)
        
        ridesArray.append(ride2)
        ridesArray[1].driverName = "Ted"
        ridesArray[1].driverPhoneNumber = "+12223334455"
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath) as! AvailableRidesTableViewCell
        let ride = self.ridesArray[indexPath.row]
        
        cell.configureCell(ride: ride)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
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
