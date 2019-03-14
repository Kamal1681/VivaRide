//
//  RidesOfferedViewController.swift
//  W8D2-Ride-Share
//
//  Created by Pavel on 2019-02-28.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps

class RidesOfferedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
//    //Setting Firestore
//    var db: Firestore!
//    var settings: FirestoreSettings!
    
    //Handler for checking user aithorization
    var user: FirebaseAuth.User?
    var handle: AuthStateDidChangeListenerHandle? = nil
    
//    //Other properties
//    var rides: Ride?
    
    //Booked rides array
    var ridesArray = [Ride]()
    
    //UI elements
    @IBOutlet weak var ridesOfferedTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ridesOfferedTableView.delegate = self
        ridesOfferedTableView.dataSource = self
        ridesOfferedTableView.rowHeight = 140
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // START auth_listener
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.user = user
            
            //User as a driver will see all rides that he was offered
            if let user = user {
                //Make arrays empty when view appear in case user came from ride details VC
//                self.ridesArray = []
                
                //Get rides infromation from Firestore
                VRFirestoreQuery.getRidesWithPassengerInfo(for: user.uid, completion: {rideArrayResult in
                    self.ridesArray = rideArrayResult
                    self.ridesOfferedTableView.reloadData()
                })
            }
        }
        // END auth_listener
        
    }
    
    //MARK: - Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ridesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RideOfferedCell", for: indexPath) as! RidesOfferedTableViewCell
        let ride = self.ridesArray[indexPath.row]
        
        if ride != nil {
            cell.configureCell(ride: ride)
        }
        else {
            return cell
        }
        
        return cell
    }

    //MARK: - Navigation
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Segue to the second view controller
        self.performSegue(withIdentifier: "goToOfferedRideDetailsVC", sender: self)
    }
    
    // This function is called before the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToOfferedRideDetailsVC", let destinationVC = segue.destination as? OfferedRideDetailsViewController {
            if let indexPath = ridesOfferedTableView.indexPathForSelectedRow {
                if ridesArray != nil {
                    destinationVC.ride = ridesArray[indexPath.row]
                }
                else {
                    return
                }
            }
            
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
