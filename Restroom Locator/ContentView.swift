//
//  ContentView.swift
//  Restroom Locator
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var session: UserSession

    var body: some View {
        TabView {
            MapTabView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }

            NearestRestroomView()
                .tabItem {
                    Image(systemName: "location")
                    Text("Nearest")
                }

            AccountTabView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Account")
                }
        }
    }
}

struct AccountTabView: View {
    @EnvironmentObject var session: UserSession
    @State private var showLoginSheet = false
    @State private var showSignupSheet = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let user = session.currentUser {
                    Text("Logged in as: \(user.username)")
                        .padding()
                    Button("Log Out") {
                        session.logOut()
                    }
                } else {
                    Text("Not logged in.")
                    Button("Log In") {
                        showLoginSheet = true
                    }
                    Button("Sign Up") {
                        showSignupSheet = true
                    }
                }
            }
            .navigationTitle("Account")
        }
        .sheet(isPresented: $showLoginSheet) {
            LoginView()
                .environmentObject(session)
        }
        .sheet(isPresented: $showSignupSheet) {
            SignUpView()
                .environmentObject(session)
        }
    }
}
