//
//  Car.swift
//  W8D2-Ride-Share
//
//  Created by Kamal Maged on 2019-03-02.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit

class Car {
    
    let carMake: String?
    let carDescription: String?
    let carYear: String?
    let plateNumber: String?
    let numberOfSeats: Int?
    
    init(carMake: String, carDescription: String, carYear: String, plateNumber: String, numberOfSeats: Int) {
        self.carMake = carMake
        self.carDescription = carDescription
        self.carYear = carYear
        self.plateNumber = plateNumber
        self.numberOfSeats = numberOfSeats
        
    }
    

}
