//
//  SignupVC+Location.swift
//  Commun
//
//  Created by Chung Tran on 7/25/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CoreLocation
import CyberSwift

extension SignUpVC: CLLocationManagerDelegate {
    func updateLocation() {
        // For use in foreground
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard shouldDefineLocation, locations.count > 0 else {return}
        let location = locations[0]
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            guard let placemarks = placemarks, placemarks.count > 0 else {return}
            let placemark = placemarks[0]
            guard let countryCode = placemark.isoCountryCode,
                let country = PhoneCode.getCountries().first(where: {$0.shortCode == countryCode})
            else {return}
            
            self.viewModel.selectedCountry.accept(country)
        }
    }
}