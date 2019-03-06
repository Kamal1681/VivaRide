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

enum TripStatus {
    case available
    case booked
    case started
    case cancelled
    case finished
}

class Ride {
    
    let startLocation: CLLocationCoordinate2D?
    let endLocation: CLLocationCoordinate2D?
    let tripStartTime: Date?
    let estimatedArrivalTime: Date?
    var tripDuration: String? = ""
    var stopOvers = [StopOver?]()

    var distance: Double = 0.0
    var numberOfSeats: Int = 3
    var tripStatus: TripStatus?
    var price: Float?
    
    init(startLocation: CLLocationCoordinate2D, endLocation: CLLocationCoordinate2D, tripStartTime: Date, estimatedArrivalTime: Date, tripDuration: String) {
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.tripStartTime = tripStartTime
        self.estimatedArrivalTime = estimatedArrivalTime
        self.tripDuration = tripDuration
        //self.stopOvers = stopOvers ?? []
        //self.car = car
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
