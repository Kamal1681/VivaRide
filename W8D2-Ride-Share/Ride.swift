//
//  Ride.swift
//  W8D2-Ride-Share
//
//  Created by Kamal Maged on 2019-03-01.
//  Copyright © 2019 Pavel. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

enum TripStatus: String {
    case available = "available"
    case booked = "booked"
    case started = "started"
    case cancelled = "cancelled"
    case finished = "finished"
    

}

class Ride {
    
    var startLocation: CLLocationCoordinate2D?
    var endLocation: CLLocationCoordinate2D?
    
    var tripStartTime: Date?
    var estimatedArrivalTime: Date?
    var tripDuration: String? = ""
    var stopOvers = [StopOver?]()
    var driverName: String?
    var driverPhoneNumber: String?
    var driverCarModel: String?
    var driverCarColor: String?
    var driverPhoto: String?
    var userID: String?
    var rideID: String?
    
    var userInfo: UserInfo?
    
    var distance: String = ""
    var numberOfSeats: Int? = 10
    var numberOfAvailableSeats: Int? = 10
    
    var tripStatus: TripStatus?
    var price: Float?
    
    
    init(startLocation: CLLocationCoordinate2D, endLocation: CLLocationCoordinate2D, tripStartTime: Date, estimatedArrivalTime: Date, tripDuration: String, distance: String, userID: String?, rideID: String?, userInfo: UserInfo?, price:Float?, numberOfSeats: Int?, numberOfAvailableSeats: Int?, tripStatus: TripStatus?) {
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.tripStartTime = tripStartTime
        self.estimatedArrivalTime = estimatedArrivalTime
        self.tripDuration = tripDuration
        self.distance = distance
        self.userID = userID
        self.rideID = rideID
        self.userInfo = userInfo
        self.price = price
        self.numberOfSeats = numberOfSeats
        self.numberOfAvailableSeats = numberOfAvailableSeats
        self.tripStatus = tripStatus
 
        //self.stopOvers = stopOvers ?? []

    }
    
}

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

class StopOver {
    let location: CLLocation?
    let pickUpTime: Date?
    
    init(location: CLLocation, pickUpTime: Date) {
        
        self.location = location
        self.pickUpTime = pickUpTime
    }
}

class Booking {
    var bookingID: String?
    var passengerID: String?
    var rideID: String?
    var numberOfBookingSeats: Int?
    var status: String?
    var rideInfo: Ride?
    var driverInfo: UserInfo?
    
    init(bookingID: String?, passengerID: String?, rideID: String?, rideInfo: Ride?, numberOfBookingSeats: Int?, status: String?, driverInfo: UserInfo?) {
        self.bookingID = bookingID
        self.passengerID = passengerID
        self.rideID = rideID
        self.rideInfo = rideInfo
        self.numberOfBookingSeats = numberOfBookingSeats
        self.status = status
        self.driverInfo = driverInfo
    }
}
