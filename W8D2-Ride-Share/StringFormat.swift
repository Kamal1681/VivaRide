//
//  StringFormat.swift
//  W8D2-Ride-Share
//
//  Created by Pavel on 2019-03-12.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit

class StringFormat {

    static func Date(from date: Date) -> String {
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "E - MMMM dd, yyyy"
        // convert date to string
        let myString = formatter.string(from: date)
        
        return myString
    }
    
    static func HoursMinutes(from date: Date) -> String {
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "hh:mm a"
        // convert date to string
        let myString = formatter.string(from: date)
        
        return myString
    }
    
    static func Seats(for numberOfBookingSeats: Int) -> String {
        var resultString: String = ""
        
        if numberOfBookingSeats == 1 {
            resultString = "1 seat was"
        }
        else if numberOfBookingSeats > 1 {
            resultString = "\(numberOfBookingSeats) seats were"
        }
        
        return resultString
    }
    
    static func numberOfBookedSeats(from numberOfSeats: Int, numberOfAvailableSeats: Int) -> String {
        var stringResult: String = ""
        let numberOfBookedSeats = numberOfSeats - numberOfAvailableSeats
        
        if numberOfBookedSeats == 0 {
            stringResult = "No passengers"
        }
        else if numberOfBookedSeats == 1 {
            stringResult = "\(numberOfBookedSeats) seat booked out of \(numberOfSeats)"
        }
        else if numberOfBookedSeats > 1 {
            stringResult = "\(numberOfBookedSeats) seats booked out of \(numberOfSeats)"
        }
        
        return stringResult
    }
}
