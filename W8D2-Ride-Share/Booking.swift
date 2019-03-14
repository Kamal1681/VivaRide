//
//  Booking.swift
//  W8D2-Ride-Share
//
//  Created by Pavel on 2019-03-12.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit

enum BookingStatus: String {
    case unconfirmed = "unconfirmed"
    case confirmed = "confirmed"
    case started = "started"
    case cancelled = "cancelled"
    case finished = "finished"
    
}

class Booking {
    var bookingID: String?
    var passengerID: String?
    var rideID: String?
    var numberOfBookingSeats: Int?
    var status: String?
    var rideInfo: Ride?
    var driverInfo: UserInfo?
    var passengerInfo: UserInfo?
    
    init(bookingID: String?, passengerID: String?, rideID: String?, rideInfo: Ride?, numberOfBookingSeats: Int?, status: String?, driverInfo: UserInfo?, passengerInfo: UserInfo?) {
        self.bookingID = bookingID
        self.passengerID = passengerID
        self.rideID = rideID
        self.rideInfo = rideInfo
        self.numberOfBookingSeats = numberOfBookingSeats
        self.status = status
        self.driverInfo = driverInfo
        self.passengerInfo = passengerInfo
    }
}
