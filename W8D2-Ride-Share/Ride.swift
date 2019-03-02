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
    
    let startLocation: CLLocation?
    let endLocation: CLLocation?
    let tripStartTime: Date?
    let tripEndTime: Date?
    var stopOvers = [StopOver?]()
    
    init(startLocation: CLLocation, endLocation: CLLocation, tripStartTime: Date, tripEndTime: Date, stopOvers: [ StopOver]) {
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.tripStartTime = tripStartTime
        self.tripEndTime = tripEndTime
        self.stopOvers = stopOvers
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
