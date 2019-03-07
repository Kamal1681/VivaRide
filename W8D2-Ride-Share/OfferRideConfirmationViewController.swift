//
//  OfferRideConfirmationViewController.swift
//  W8D2-Ride-Share
//
//  Created by Pavel on 2019-02-28.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit
import Firebase
import Geofirestore

class OfferRideConfirmationViewController: UIViewController {
    //Setting Firestore
    var db: Firestore!
    
    //Handler for checking user aithorization
    var user: FirebaseAuth.User?
    var handle: AuthStateDidChangeListenerHandle? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // START setup for Firestore
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        // END setup for Firestore
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // START auth_listener
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.user = user
        }
        // END auth_listener
    }
    
    @IBAction func offerRideButtonDidTap(_ sender: UIButton) {
        createRide()
    }
    
    //MARK: Create new ride
    func createRide() {
        if let user = self.user {
            //Create a new ride document in Firestore
               
            var ref: DocumentReference? = nil
            ref = db.collection("rides").addDocument(data: [
                "rideID": ref?.documentID ?? "noRideID",
                "userID": user.uid,
                "status": 1,
                "startPoint": GeoPoint(latitude: 37.7853889, longitude: -122.4056973),
                "endPoint": GeoPoint(latitude: 41.7853889, longitude: -100.4056973),
                "startTimeDate": NSDate.init()
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err.localizedDescription)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                    // Add rideID as a documentID
                    self.addRideID(documentID: ref!.documentID)
                }
            }
        }
        else {
            print("Error! User do not login")
        }
    }
    
    //MARK: Add rideID to the newly created ride
    func addRideID(documentID: String) {
        db.collection("rides").document(documentID).setData([ "rideID": documentID ], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err.localizedDescription)")
            } else {
                print("RideID successfully written!")
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
