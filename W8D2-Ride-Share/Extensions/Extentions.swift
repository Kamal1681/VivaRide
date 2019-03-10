//
//  Extentions.swift
//  W8D2-Ride-Share
//
//  Created by Pavel on 2019-03-07.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps

extension CLLocationCoordinate2D {
    func toGeoPoint() -> GeoPoint {
        return GeoPoint(latitude: self.latitude, longitude: self.longitude)
    }
}

extension GeoPoint {
    func toCLLocationCoordinate2D() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}

//Extension for Date Round
enum DateRoundingType {
    case round
    case ceil
    case floor
}

extension Date {
    func rounded(minutes: TimeInterval, rounding: DateRoundingType = .round) -> Date {
        return rounded(seconds: minutes * 60, rounding: rounding)
    }
    func rounded(seconds: TimeInterval, rounding: DateRoundingType = .round) -> Date {
        var roundedInterval: TimeInterval = 0
        switch rounding  {
        case .round:
            roundedInterval = (timeIntervalSinceReferenceDate / seconds).rounded() * seconds
        case .ceil:
            roundedInterval = ceil(timeIntervalSinceReferenceDate / seconds) * seconds
        case .floor:
            roundedInterval = floor(timeIntervalSinceReferenceDate / seconds) * seconds
        }
        return Date(timeIntervalSinceReferenceDate: roundedInterval)
    }
}
//
//// Example
//
//let nextFiveMinuteIntervalDate = Date().rounded(minutes: 5, rounding: .ceil)
//print(nextFiveMinuteIntervalDate)
