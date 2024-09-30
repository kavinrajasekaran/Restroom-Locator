// NearestRestroomView.swift

import SwiftUI
import MapKit

struct NearestRestroomView: View {
    @EnvironmentObject var restaurantFetcher: RestaurantFetcher
    @EnvironmentObject var locationManager: LocationManager
    @State private var nearestAnnotation: MKPointAnnotation?
    @State private var note: String?

    var body: some View {
        VStack {
            if let nearestAnnotation = nearestAnnotation {
                Text("Nearest Restroom:")
                    .font(.headline)
                    .padding()

                Text(nearestAnnotation.title ?? "Unknown")
                    .font(.title)
                    .padding()

                if let note = note {
                    Text("Note: \(note)")
                        .padding()
                } else {
                    Text("No note available.")
                        .padding()
                }

                Button(action: {
                    openInMaps(annotation: nearestAnnotation)
                }) {
                    Text("Open in Maps")
                }
                .padding()

            } else {
                Text("Calculating nearest restroom...")
                    .onAppear {
                        calculateNearestRestroom()
                    }
            }
        }
        .onAppear {
            calculateNearestRestroom()
        }
        .onChange(of: restaurantFetcher.userAnnotations) { _ in
            calculateNearestRestroom()
        }
        .onChange(of: locationManager.lastLocation) { _ in
            calculateNearestRestroom()
        }
    }

    func calculateNearestRestroom() {
        guard let userLocation = locationManager.lastLocation else {
            return
        }
        let annotations = restaurantFetcher.fetchedAnnotations + restaurantFetcher.userAnnotations

        guard !annotations.isEmpty else {
            return
        }

        var closestAnnotation: MKPointAnnotation?
        var shortestDistance: CLLocationDistance = CLLocationDistanceMax

        for annotation in annotations {
            let annotationLocation = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            let distance = userLocation.distance(from: annotationLocation)
            if distance < shortestDistance {
                shortestDistance = distance
                closestAnnotation = annotation
            }
        }

        if let closest = closestAnnotation {
            nearestAnnotation = closest
            let key = "\(closest.coordinate.latitude),\(closest.coordinate.longitude)"
            note = UserDefaults.standard.string(forKey: key)
        }
    }

    func openInMaps(annotation: MKPointAnnotation) {
        let coordinate = annotation.coordinate
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = annotation.title
        mapItem.openInMaps(launchOptions: nil)
    }
}

