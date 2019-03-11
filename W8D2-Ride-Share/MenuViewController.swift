//
//  MenuViewController.swift
//  W8D2-Ride-Share
//
//  Created by Pavel on 2019-02-28.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit

// [START usermanagement_view_import]
import Firebase
// [END usermanagement_view_import]

class MenuViewController: UIViewController {

    @IBOutlet weak var findARide: UIButton!
    
    @IBOutlet weak var offerARide: UIButton!
    
    @IBOutlet weak var ridesBooked: UIButton!
    
    @IBOutlet weak var ridesOffered: UIButton!
    
    @IBOutlet weak var profileButton: UIButton!
    var viewToAnimate = [UIButton]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureButtons()
        

    }
    override func viewWillAppear(_ animated: Bool) {
        viewToAnimate = [self.findARide, self.offerARide, self.ridesBooked, self.ridesOffered]
        for (i, view) in viewToAnimate.enumerated() {
            view.alpha = 0
            UIButton.animate(withDuration: TimeInterval(0.5 * Double(i)), animations: {
                view.alpha = 1
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {

        //Firebase check for autentification
        if Auth.auth().currentUser != nil {
            print("User auth")
        } else {
            print("user not auth")
            performSegue(withIdentifier: "goLoginVC", sender: nil)
        }
        
    }

    @IBAction func profileVCButton(_ sender: UIButton) {
        sender.pressed()

        performSegue(withIdentifier: "goToProfileVC", sender: nil)
    }
    
    @IBAction func findARide(_ sender: UIButton) {
        sender.pressed()
    }
    
    @IBAction func offerARide(_ sender: UIButton) {
        sender.pressed()
    }
    
    
    @IBAction func ridesBooked(_ sender: UIButton) {
        sender.pressed()
    }
    
    @IBAction func ridesOffered(_ sender: UIButton) {
        sender.pressed()
        
        sendPushNotification()

    }
    
    func sendPushNotification() {
        let webAPI = "AAAAanCx2gY:APA91bGnjSawGhpNZua0NTRAUJYJHM2tnTiSG7wHpeXDrLbHGz9_EfDb9jsSPAb-qzixTKauTZ3P_oQOBINfAZDL7oJhb5QqIrnJc8hUhppzFrHBiXSx35JEBKLDiTuRlM0LSLODcTmn"
        
        let token = Messaging.messaging().fcmToken
        
        let url = URL(string: "https://fcm.googleapis.com/fcm/send")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(webAPI)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        var notData: [String: Any] = [
            "to" : "eKUBk_ra58Q:APA91bGKXmQbkwR73haVgvX0LPILpKoQEuwDxQzebmTGuKkNcWQRWvWtRQaOFm1XMiSNeCqQ4E97yy9D8U6KhujfuGmX-fJqXExwz9EZppBr_DF0s2vPSE7xlhdiw_UGlaDGacbnoC1L",
            "notification": [
                "title" : "Test from app",
                "body"  : "Working!",
                "icon"  : "not icon"
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
    func configureButtons() {
        findARide.configure(button: findARide)
        offerARide.configure(button: offerARide)
        ridesBooked.configure(button: ridesBooked)
        ridesOffered.configure(button: ridesOffered)
    }
    
//    func sendUpstreamPushNotification() {
//        let message = [
//            "to" : "eKUBk_ra58Q:APA91bGKXmQbkwR73haVgvX0LPILpKoQEuwDxQzebmTGuKkNcWQRWvWtRQaOFm1XMiSNeCqQ4E97yy9D8U6KhujfuGmX-fJqXExwz9EZppBr_DF0s2vPSE7xlhdiw_UGlaDGacbnoC1L",
//            "title" : "not title",
//            "body"  : "not body"
//
//            ] as [String : Any]
//        let to = "457157237254@gcm.googleapis.com"
//        let messageId = "\(Int.random(in: 0...99999))\(Int.random(in: 0...99999))\(Int.random(in: 0...99999))"
//        let ttl: Int64 = 6
//
//        Messaging.messaging().sendMessage(message,
//                                          to: to,
//                                          withMessageID: messageId,
//                                          timeToLive: ttl)
//        print("Button pushed")
//
//    }
    
    
    
    /*
     @IBAction func ridesBooked(_ sender: Any) {
     }
     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
