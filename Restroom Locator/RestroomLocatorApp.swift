//
//  RestroomLocatorApp.swift
//  Restroom Locator
//

import SwiftUI
import SwiftData

@main
struct RestroomLocatorApp: App {
    // Create SwiftData container
    var modelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            Bathroom.self,
            Comment.self,
            BathroomCode.self,
            BathroomCodeVote.self
        ])
        do {
            return try ModelContainer(for: schema)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    @StateObject var locationManager = LocationManager()
    @StateObject var session: UserSession
    @StateObject var bathroomFetcher: BathroomFetcher

    init() {
        // Temporary container for initialization
        let tempContainer = try! ModelContainer(for: Schema([
            User.self,
            Bathroom.self,
            Comment.self,
            BathroomCode.self,
            BathroomCodeVote.self
        ]))
        _session = StateObject(wrappedValue: UserSession(context: tempContainer.mainContext))
        _bathroomFetcher = StateObject(wrappedValue: BathroomFetcher(context: tempContainer.mainContext))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
                .environmentObject(session)
                .environmentObject(bathroomFetcher)
                .modelContainer(modelContainer)
                .onAppear {
                    // Reassign the real container’s context
                    session.setContext(modelContainer.mainContext)
                    bathroomFetcher.setContext(modelContainer.mainContext)
                }
        }
    }
}

