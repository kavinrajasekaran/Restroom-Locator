//
//  LocationManager.swift
//  Restroom Locator
//
//  Created by Kavin Rajasekaran on 9/28/24.
//

// LocationManager.swift

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject {
    private let manager = CLLocationManager()

    @Published var lastLocation: CLLocation?
    @Published var permissionDenied = false

    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            permissionDenied = false
            manager.startUpdatingLocation()
        case .denied, .restricted:
            permissionDenied = true
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.first
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed: \(error.localizedDescription)")
    }
}
