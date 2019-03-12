//
//  PushNotification.swift
//  W8D2-Ride-Share
//
//  Created by Pavel on 2019-03-11.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit
import Firebase

class PushNotification: NSObject {
    //Setting Firestore
    static var db: Firestore!
    static var settings: FirestoreSettings!
    
    //User authorization property
    static var user: FirebaseAuth.User?
    
    //MARK: Send Notification Fuction
    
    static func sendTo(token: String, title: String, body: String) {
        let webAPI = "AAAAanCx2gY:APA91bGnjSawGhpNZua0NTRAUJYJHM2tnTiSG7wHpeXDrLbHGz9_EfDb9jsSPAb-qzixTKauTZ3P_oQOBINfAZDL7oJhb5QqIrnJc8hUhppzFrHBiXSx35JEBKLDiTuRlM0LSLODcTmn"
        
//        let token = Messaging.messaging().fcmToken
        
        let url = URL(string: "https://fcm.googleapis.com/fcm/send")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(webAPI)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        var notData: [String: Any] = [
            "to" : token,
            "notification": [
                "title" : title,
                "body"  : body //,
//                "icon"  : "not icon"
            ]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: notData, options: [])
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
        }
        task.resume()
    }
 
    
    //MARK: - Update user's token for push notifications in Firestore
    static func updateUserToken() {

        self.setUpFirestore()
        
        //Push notification token property
        guard let pushNotificationToken = Messaging.messaging().fcmToken else {
            print("Error! Can not receive push notofocation token in updateUserToken() func.")
            return
        }
        
        self.user = Auth.auth().currentUser
        
        //Update information in Firebase
        if let user = user {
            db.collection("users").document(user.uid).setData([
                "pushNotificationToken": pushNotificationToken
            ], merge: true) { err in
                if let err = err {
                    print(err.localizedDescription)
                } else {
                    print("Push notification token was successfully written!")
                }
            }
        }
        else {
            print("Error! User do not login")
        }
    }
    
    static func deleteUserToken(completionHandler: @escaping () -> Void){

        self.setUpFirestore()

        //Push notification token property
        let pushNotificationToken = ""
        
        self.user = Auth.auth().currentUser
        
        //Update information in Firebase
        
        if let user = user {
            db.collection("users").document(user.uid).setData([
                "pushNotificationToken": pushNotificationToken
            ], merge: true) { err in
                if let err = err {
                    print("Push notification token was not delleted! \(err.localizedDescription)")
                    completionHandler()
                } else {
                    print("Push notification token was successfully deleted!")
                    completionHandler()
                }
            }
        }
        else {
            print("Error! User do not login. Push notification token was not deleted!")
            completionHandler()
        }
    }


    static func setUpFirestore() {
        // START setup for Firestore
        self.settings = FirestoreSettings()
        Firestore.firestore().settings = self.settings
        self.db = Firestore.firestore()
        // END setup for Firestore
    }

}


