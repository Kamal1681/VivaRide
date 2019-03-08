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
