//
//  LocationManager.swift
//  Restroom Locator
//

import Foundation
import CoreLocation
import UIKit

class LocationManager: NSObject, ObservableObject {
    private let manager = CLLocationManager()

    @Published var lastLocation: CLLocation?
    @Published var permissionDenied = false

    override init() {
        super.init()
        manager.delegate = self

        // Check authorization status and request permission if needed
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            permissionDenied = true
        }
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
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed: \(error.localizedDescription)")
    }
}
