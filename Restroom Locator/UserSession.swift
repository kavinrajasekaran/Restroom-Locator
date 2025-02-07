//
//  UserSession.swift
//  Restroom Locator
//

import Foundation
import SwiftData

@MainActor
class UserSession: ObservableObject {
    @Published var currentUser: User?
    private var context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func signUp(username: String, password: String) throws {
        // Check if user exists
        let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.username == username })
        let existing = try context.fetch(descriptor)
        if !existing.isEmpty {
            throw NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "Username already taken"])
        }

        let user = User(username: username, passwordHash: User.hashPassword(password))
        context.insert(user)
        try context.save()
        currentUser = user
    }

    func logIn(username: String, password: String) throws {
        let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.username == username })
        let found = try context.fetch(descriptor)
        guard let foundUser = found.first else {
            throw NSError(domain: "", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid username"])
        }

        if foundUser.verifyPassword(password) {
            currentUser = foundUser
        } else {
            throw NSError(domain: "", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid password"])
        }
    }

    func logOut() {
        currentUser = nil
    }

    // For re-injection if you reassign the context from the App
    func setContext(_ newContext: ModelContext) {
        self.context = newContext
    }
}
