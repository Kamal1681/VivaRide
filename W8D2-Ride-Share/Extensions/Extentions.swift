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

extension UIButton {
    func pressed() {
        let press = CASpringAnimation(keyPath: "transform.scale")
        press.duration = 0.5
        press.fromValue = 0.9
        press.toValue = 1
        press.repeatCount = 1
        press.initialVelocity = 0.3
        press.autoreverses = true
        press.damping = 1
        layer.add(press, forKey: nil)
    }
    func configure(button: UIButton) {
        let cGColorBlack = UIColor.black
        let cGColorGray = UIColor.gray
        let buttonColor = UIColor(red: 0.5333, green: 0.6431, blue: 0.7255, alpha: 1)
        button.backgroundColor = buttonColor
        button.tintColor = UIColor.white
        button.layer.cornerRadius = 7
        //button.layer.borderWidth = 3
        //button.layer.borderColor = cGColorBlack.cgColor
        
        button.layer.shadowColor = cGColorBlack.cgColor
        button.layer.shadowOffset = CGSize(width: 5, height: 5)
        button.layer.shadowOpacity = 0.8
        
    }
}
//
//// Example
//
//let nextFiveMinuteIntervalDate = Date().rounded(minutes: 5, rounding: .ceil)
//print(nextFiveMinuteIntervalDate)
