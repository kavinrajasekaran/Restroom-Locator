//
//  MapView.swift
//  Restroom Locator
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    var annotations: [MKPointAnnotation]
    var bathroomFetcher: BathroomFetcher
    var userLocation: CLLocation?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow

        if let location = userLocation {
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: false)
        }

        let longPressGesture = UILongPressGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleLongPress(gestureRecognizer:))
        )
        mapView.addGestureRecognizer(longPressGesture)
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        view.removeAnnotations(view.annotations)
        view.addAnnotations(annotations)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, bathroomFetcher: bathroomFetcher)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        var bathroomFetcher: BathroomFetcher

        init(_ parent: MapView, bathroomFetcher: BathroomFetcher) {
            self.parent = parent
            self.bathroomFetcher = bathroomFetcher
        }

        @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
            if gestureRecognizer.state == .began {
                let touchPoint = gestureRecognizer.location(in: gestureRecognizer.view)
                if let mapView = gestureRecognizer.view as? MKMapView {
                    let coord = mapView.convert(touchPoint, toCoordinateFrom: mapView)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coord
                    annotation.title = "Custom Location"

                    mapView.addAnnotation(annotation)

                    // Notify our SwiftUI that an annotation was selected
                    NotificationCenter.default.post(
                        name: NSNotification.Name("AnnotationSelected"),
                        object: annotation
                    )

                    // Save to user annotations
                    DispatchQueue.main.async {
                        self.bathroomFetcher.userAnnotations.append(annotation)
                        self.bathroomFetcher.saveUserAnnotations()
                    }
                }
            }
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }

            let identifier = "AnnotationView"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }

            // Simple glyph logic
            if let ann = annotation as? MKPointAnnotation, ann.title == "Custom Location" {
                annotationView?.glyphText = "📍"
            } else {
                annotationView?.glyphText = "🍽"
            }
            return annotationView
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let annotation = view.annotation as? MKPointAnnotation {
                NotificationCenter.default.post(
                    name: NSNotification.Name("AnnotationSelected"),
                    object: annotation
                )
            }
        }
    }
}
