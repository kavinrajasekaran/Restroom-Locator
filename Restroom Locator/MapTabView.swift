//
//  MapTabView.swift
//  Restroom Locator
//

import SwiftUI
import MapKit

struct MapTabView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var bathroomFetcher: BathroomFetcher

    @State private var selectedAnnotation: MKPointAnnotation?
    @State private var showDetailSheet = false

    var body: some View {
        ZStack {
            MapView(annotations: allAnnotations,
                    bathroomFetcher: bathroomFetcher,
                    userLocation: locationManager.lastLocation)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                if let loc = locationManager.lastLocation {
                    bathroomFetcher.fetchBathrooms(around: loc)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("AnnotationSelected"))) { notif in
                if let annotation = notif.object as? MKPointAnnotation {
                    selectedAnnotation = annotation
                    showDetailSheet = true
                }
            }
            .onChange(of: locationManager.lastLocation) { newLoc in
                guard let loc = newLoc else { return }
                bathroomFetcher.fetchBathrooms(around: loc)
            }
        }
        .sheet(isPresented: $showDetailSheet) {
            if let annotation = selectedAnnotation {
                // Show a detail view with codes/comments
                BathroomDetailView(annotation: annotation)
            }
        }
        .alert(isPresented: $locationManager.permissionDenied) {
            Alert(
                title: Text("Location Permission Denied"),
                message: Text("Please enable location permissions in Settings to use this feature."),
                primaryButton: .cancel(Text("Cancel")),
                secondaryButton: .default(Text("Open Settings"), action: {
                    if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(appSettings)
                    }
                })
            )
        }
    }

    private var allAnnotations: [MKPointAnnotation] {
        bathroomFetcher.fetchedAnnotations + bathroomFetcher.userAnnotations
    }
}
