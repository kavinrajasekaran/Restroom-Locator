// MapTabView.swift or ContentView.swift

import SwiftUI
import MapKit

struct MapTabView: View {
    @EnvironmentObject var restaurantFetcher: RestaurantFetcher
    @EnvironmentObject var locationManager: LocationManager
    @State private var selectedAnnotation: MKPointAnnotation?
    @State private var showNoteView = false

    var body: some View {
        ZStack {
            MapView(annotations: combinedAnnotations,
                    restaurantFetcher: restaurantFetcher,
                    userLocation: locationManager.lastLocation)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    if let location = locationManager.lastLocation {
                        restaurantFetcher.fetchRestaurants(location: location)
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("AnnotationSelected")), perform: { notification in
                    if let annotation = notification.object as? MKPointAnnotation {
                        selectedAnnotation = annotation
                        showNoteView = true
                    }
                })
                .onChange(of: locationManager.lastLocation) { newLocation in
                    if let location = newLocation {
                        restaurantFetcher.fetchRestaurants(location: location)
                    }
                }

            if showNoteView, let annotation = selectedAnnotation {
                NoteView(annotation: annotation, isPresented: $showNoteView)
                    .onDisappear {
                        // Save user annotations when a note is added
                        restaurantFetcher.saveUserAnnotations()
                    }
            }
        }
        .alert(isPresented: $locationManager.permissionDenied) {
            Alert(
                title: Text("Location Permission Denied"),
                message: Text("Please enable location permissions in Settings to use this feature."),
                primaryButton: .cancel(Text("Cancel")),
                secondaryButton: .default(Text("Open Settings"), action: {
                    // Open app settings
                    if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(appSettings)
                    }
                })
            )
        }
    }

    // Combine fetched and user annotations
    var combinedAnnotations: [MKPointAnnotation] {
        restaurantFetcher.fetchedAnnotations + restaurantFetcher.userAnnotations
    }
}

