// RestaurantFetcher.swift

import Foundation
import MapKit

class RestaurantFetcher: NSObject, ObservableObject {
    @Published var fetchedAnnotations = [MKPointAnnotation]()
    @Published var userAnnotations = [MKPointAnnotation]()

    override init() {
        super.init()
        loadUserAnnotations()
    }

    func fetchRestaurants(location: CLLocation) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Restaurant"
        request.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let items = response?.mapItems {
                var newAnnotations = [MKPointAnnotation]()
                for item in items {
                    let annotation = MKPointAnnotation()
                    annotation.title = item.name
                    annotation.subtitle = item.phoneNumber
                    annotation.coordinate = item.placemark.coordinate
                    newAnnotations.append(annotation)
                }
                DispatchQueue.main.async {
                    self.fetchedAnnotations = newAnnotations
                }
            }
        }
    }

    // Save user annotations to UserDefaults
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

    // Load user annotations from UserDefaults
    func loadUserAnnotations() {
        if let savedData = UserDefaults.standard.array(forKey: "UserAnnotations") as? [[String: Any]] {
            var loadedAnnotations = [MKPointAnnotation]()
            for item in savedData {
                let annotation = MKPointAnnotation()
                annotation.title = item["title"] as? String
                annotation.subtitle = item["subtitle"] as? String
                if let latitude = item["latitude"] as? CLLocationDegrees,
                   let longitude = item["longitude"] as? CLLocationDegrees {
                    annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    loadedAnnotations.append(annotation)
                }
            }
            self.userAnnotations = loadedAnnotations
        }
    }
}
