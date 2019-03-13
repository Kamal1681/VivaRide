//
//  User.swift
//  W8D2-Ride-Share
//
//  Created by Kamal Maged on 2019-03-01.
//  Copyright © 2019 Pavel. All rights reserved.
//

import Foundation
import UIKit

class UserInfo {
    var userID: String?
    var name: String?
    var phoneNumber: String?
    var carModel: String?
    var carColor: String?
    var photo: String?
    var pushNotificationToken: String?
    
    
    init(userID: String, name: String, phoneNumber: String, carModel: String?, carColor: String?, photo: String?, pushNotificationToken: String?) {
        self.userID = userID
        self.name = name
        self.phoneNumber = phoneNumber
        self.carModel = carModel
        self.carColor = carColor
        self.photo = photo
        self.pushNotificationToken = pushNotificationToken
    }
    
}

//struct Car {
//
//    let carMake: String?
//    let carDescription: String?
//    let carYear: String?
//    let plateNumber: String?
//    let numberOfSeats: Int?
//
//}
//
//class User {
//
//    let uID: String?
//    let eMail: String?
//    let password: String?
//    let photo: UIImage?
//    let phone: String?
//    let car: Car?
//
//    init(uID: String, eMail: String, password: String, photo: UIImage, phone: String, car: Car) {
//        self.uID = uID
//        self.eMail = eMail
//        self.password = password
//        self.photo = photo
//        self.phone = phone
//        self.car = car
//    }
//    func addUserToDatabase() {
//
//    }
//
//    func bookARide() {
//
//    }
//    func offerARide() {
//
//    }
//}
