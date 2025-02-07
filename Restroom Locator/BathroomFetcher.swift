//
//  BathroomFetcher.swift
//  Restroom Locator
//
//  Demonstrates local searches + SwiftData storage.
//

import Foundation
import SwiftUI
import MapKit
import SwiftData

@MainActor
class BathroomFetcher: ObservableObject {
    @Published var fetchedAnnotations: [MKPointAnnotation] = []
    @Published var userAnnotations: [MKPointAnnotation] = []

    private var context: ModelContext

    init(context: ModelContext) {
        self.context = context
        loadUserAnnotations()
    }

    func fetchBathrooms(around location: CLLocation) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Restaurant" // or "Bathroom"
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 2000,
            longitudinalMeters: 2000
        )

        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self = self else { return }
            guard let response = response else { return }

            var newAnnotations: [MKPointAnnotation] = []

            for item in response.mapItems {
                let annotation = MKPointAnnotation()
                annotation.title = item.name
                annotation.subtitle = item.phoneNumber
                annotation.coordinate = item.placemark.coordinate
                newAnnotations.append(annotation)

                // Create a unique placeId
                let placeId = item.placemark.name ?? "\(annotation.coordinate.latitude),\(annotation.coordinate.longitude)"

                // Check if we already have a Bathroom with this placeId
                let descriptor = FetchDescriptor<Bathroom>(
                    predicate: #Predicate { $0.placeId == placeId }
                )

                if let existing = try? self.context.fetch(descriptor), !existing.isEmpty {
                    // Already stored
                } else {
                    // Insert new
                    let newBath = Bathroom(
                        placeId: placeId,
                        name: item.name,
                        latitude: annotation.coordinate.latitude,
                        longitude: annotation.coordinate.longitude,
                        address: item.placemark.title,
                        rating: nil // Apple doesn't usually provide rating
                    )
                    self.context.insert(newBath)
                    try? self.context.save()
                }
            }

            DispatchQueue.main.async {
                self.fetchedAnnotations = newAnnotations
            }
        }
    }

    // MARK: - User Annotations
    func saveUserAnnotations() {
        let data = userAnnotations.map { annotation -> [String: Any] in
            [
                "title": annotation.title ?? "",
                "subtitle": annotation.subtitle ?? "",
                "latitude": annotation.coordinate.latitude,
                "longitude": annotation.coordinate.longitude
            ]
        }
        UserDefaults.standard.set(data, forKey: "UserAnnotations")
    }

    func loadUserAnnotations() {
        guard let savedData = UserDefaults.standard.array(forKey: "UserAnnotations") as? [[String: Any]] else {
            return
        }

        var loaded: [MKPointAnnotation] = []
        for item in savedData {
            let annotation = MKPointAnnotation()
            annotation.title = item["title"] as? String
            annotation.subtitle = item["subtitle"] as? String
            if let lat = item["latitude"] as? CLLocationDegrees,
               let lng = item["longitude"] as? CLLocationDegrees {
                annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                loaded.append(annotation)
            }
        }
        userAnnotations = loaded
    }

    // For re-injection if you reassign the context from the App
    func setContext(_ newContext: ModelContext) {
        self.context = newContext
    }
}
