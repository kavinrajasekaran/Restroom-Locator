//
//  NearestRestroomView.swift
//  Restroom Locator
//

import SwiftUI
import MapKit
import SwiftData

struct NearestRestroomView: View {
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.modelContext) private var context

    @State private var nearestBathroom: Bathroom?

    var body: some View {
        VStack {
            if let nearest = nearestBathroom {
                Text("Nearest Bathroom")
                    .font(.headline)
                Text(nearest.name ?? "Unknown")
                    .font(.title)
                    .padding()

                let code = bestCode(for: nearest)
                Text("Top Code: \(code)")
                    .padding()

                Button("Open in Maps") {
                    openInMaps(nearest)
                }
                .padding()
            } else {
                Text("Calculating nearest bathroom...")
                    .onAppear(perform: calculateNearest)
            }
        }
        .onAppear(perform: calculateNearest)
    }

    func calculateNearest() {
        guard let userLocation = locationManager.lastLocation else { return }

        let descriptor = FetchDescriptor<Bathroom>()
        guard let bathrooms = try? context.fetch(descriptor), !bathrooms.isEmpty else { return }

        var closest: Bathroom?
        var shortest: CLLocationDistance = .greatestFiniteMagnitude

        for bath in bathrooms {
            let dist = userLocation.distance(from: CLLocation(latitude: bath.latitude, longitude: bath.longitude))
            if dist < shortest {
                shortest = dist
                closest = bath
            }
        }
        nearestBathroom = closest
    }

    func bestCode(for bathroom: Bathroom) -> String {
        // Sort by net score desc, then newest
        let sorted = bathroom.codes.sorted {
            if $0.netScore == $1.netScore {
                return $0.timestamp > $1.timestamp
            }
            return $0.netScore > $1.netScore
        }
        return sorted.first?.code ?? "Unknown"
    }

    func openInMaps(_ bathroom: Bathroom) {
        let coordinate = CLLocationCoordinate2D(latitude: bathroom.latitude, longitude: bathroom.longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = bathroom.name
        mapItem.openInMaps()
    }
}
