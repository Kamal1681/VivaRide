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


class Ride {
    
    let startLocation: CLLocationCoordinate2D?
    let endLocation: CLLocationCoordinate2D?
    let tripStartTime: Date?
    var estimatedArrivalTime: Date?
    var stopOvers = [StopOver?]()
    let car: Car?
    var distance: Double = 0.0
    
    init(startLocation: CLLocationCoordinate2D, endLocation: CLLocationCoordinate2D, tripStartTime: Date, estimatedArrivalTime: Date, stopOvers: [ StopOver]?, car: Car?) {
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.tripStartTime = tripStartTime
        self.estimatedArrivalTime = estimatedArrivalTime
        self.stopOvers = stopOvers ?? []
        self.car = car
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
