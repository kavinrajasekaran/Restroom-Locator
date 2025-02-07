//
//  AuthViews.swift
//  Restroom Locator
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var session: UserSession
    @State private var username = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack {
            Text("Login")
                .font(.largeTitle)

            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            Button("Log In") {
                do {
                    try session.logIn(username: username, password: password)
                } catch {
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
            .padding(.top)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Login Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct SignUpView: View {
    @EnvironmentObject var session: UserSession
    @Environment(\.dismiss) var dismiss

    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack {
            Text("Create Account")
                .font(.largeTitle)
            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            Button("Sign Up") {
                guard password == confirmPassword else {
                    alertMessage = "Passwords do not match"
                    showAlert = true
                    return
                }
                do {
                    try session.signUp(username: username, password: password)
                    // Automatically close after successful sign-up
                    dismiss()
                } catch {
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
            .padding(.top)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Sign Up Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
