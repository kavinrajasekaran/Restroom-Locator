// MapView.swift

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    var annotations: [MKPointAnnotation]
    var restaurantFetcher: RestaurantFetcher
    var userLocation: CLLocation?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        // Show user location
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow

        // Center map on user's location if available
        if let location = userLocation {
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: false)
        }

        // Add Long Press Gesture Recognizer
        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLongPress(gestureRecognizer:)))
        mapView.addGestureRecognizer(longPressGesture)

        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        view.removeAnnotations(view.annotations)
        view.addAnnotations(annotations)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, restaurantFetcher: restaurantFetcher)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        var restaurantFetcher: RestaurantFetcher

        init(_ parent: MapView, restaurantFetcher: RestaurantFetcher) {
            self.parent = parent
            self.restaurantFetcher = restaurantFetcher
        }

        // Handle Long Press Gesture
        @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
            if gestureRecognizer.state == .began {
                let touchPoint = gestureRecognizer.location(in: gestureRecognizer.view)
                if let mapView = gestureRecognizer.view as? MKMapView {
                    let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)

                    // Create a new annotation
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "Custom Location"

                    // Add annotation to the map
                    mapView.addAnnotation(annotation)

                    // Notify to show NoteView
                    NotificationCenter.default.post(name: NSNotification.Name("AnnotationSelected"), object: annotation)

                    // Save the new annotation
                    DispatchQueue.main.async {
                        self.restaurantFetcher.userAnnotations.append(annotation)
                        self.restaurantFetcher.saveUserAnnotations()
                    }
                }
            }
        }

        // Customize annotation views
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }

            let identifier = "AnnotationView"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }

            // Check if a note exists
            let key = "\(annotation.coordinate.latitude),\(annotation.coordinate.longitude)"
            if UserDefaults.standard.string(forKey: key) != nil {
                annotationView?.glyphText = "📝"
            } else {
                // Determine glyph based on annotation source
                if self.restaurantFetcher.userAnnotations.contains(where: {
                    $0.coordinate.latitude == annotation.coordinate.latitude &&
                    $0.coordinate.longitude == annotation.coordinate.longitude
                }) {
                    annotationView?.glyphText = "📍"
                } else {
                    annotationView?.glyphText = "🍽"
                }
            }

            return annotationView
        }

        // Handle annotation tap
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let annotation = view.annotation as? MKPointAnnotation {
                NotificationCenter.default.post(name: NSNotification.Name("AnnotationSelected"), object: annotation)
            }
        }
    }
}

