//
//  GeoPlace.swift
//  W8D2-Ride-Share
//
//  Created by Pavel on 2019-03-12.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class GeoPlace {

    static func getAddressFromLocation (location: CLLocationCoordinate2D, complete: @escaping (String) -> Void) {
        
        var city: String? = ""
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(String(describing: location.latitude)),\(String(describing: location.longitude))&location_type=APPROXIMATE&result_type=locality&language=en&key=\(Constants.googleApiKey)")
        
        let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
            
            do {
                if data != nil{
                    let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as!  NSDictionary
                    let results = dict["results"] as! NSArray
                    let addressComponents = results.value(forKey: "address_components") as! NSArray
                    let components = (addressComponents[0] as! NSArray)[0] as! NSDictionary
                    city = (components.value(forKey: "long_name") as! String)
                    
                    complete(city ?? "")
                }
            }catch {
                print("Error request")
            }
        }
        task.resume()
    }
}
