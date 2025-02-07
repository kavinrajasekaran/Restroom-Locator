//
//  BathroomDetailView.swift
//  Restroom Locator
//

import SwiftUI
import MapKit
import SwiftData

struct BathroomDetailView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject var session: UserSession

    let annotation: MKPointAnnotation

    @State private var showComments = true
    @State private var newCommentText = ""
    @State private var newCodeText = ""

    // New: Sheet toggles for login
    @State private var showLoginSheetForComments = false
    @State private var showLoginSheetForCodes = false

    var body: some View {
        NavigationView {
            VStack {
                if let bath = bathroom {
                    Text(bath.name ?? "Unknown Place")
                        .font(.headline)
                        .padding()

                    if let address = bath.address {
                        Text(address)
                            .foregroundColor(.secondary)
                    }
                    if let rating = bath.rating {
                        Text("Rating: \(rating, specifier: "%.1f")")
                    }

                    Picker("", selection: $showComments.animation()) {
                        Text("Comments").tag(true)
                        Text("Codes").tag(false)
                    }
                    .pickerStyle(.segmented)
                    .padding()

                    if showComments {
                        commentSection(for: bath)
                    } else {
                        codeSection(for: bath)
                    }

                } else {
                    Text("No local record found for this place.")
                }
            }
            .navigationTitle("Bathroom Details")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        // Dismiss sheet if needed
                    }
                }
            }
        }
        // Present login if user taps "Log in..." button
        .sheet(isPresented: $showLoginSheetForComments) {
            LoginView()
                .environmentObject(session)
        }
        .sheet(isPresented: $showLoginSheetForCodes) {
            LoginView()
                .environmentObject(session)
        }
    }

    /// Attempt to find the `Bathroom` in SwiftData that corresponds to this annotation
    private var bathroom: Bathroom? {
        let placeId = annotation.title ?? "\(annotation.coordinate.latitude),\(annotation.coordinate.longitude)"
        let descriptor = FetchDescriptor<Bathroom>(predicate: #Predicate { $0.placeId == placeId })
        let result = try? context.fetch(descriptor)
        return result?.first
    }

    // MARK: - Comments
    func commentSection(for bath: Bathroom) -> some View {
        VStack {
            List {
                // Sort descending by timestamp
                ForEach(bath.comments.sorted(by: { $0.timestamp > $1.timestamp })) { comment in
                    VStack(alignment: .leading) {
                        Text(comment.content)
                        Text("by \(comment.username) at \(comment.timestamp.formatted())")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }

            if session.currentUser != nil {
                // Logged in: show comment field
                HStack {
                    TextField("New comment...", text: $newCommentText)
                        .textFieldStyle(.roundedBorder)
                    Button("Send") {
                        addComment(to: bath)
                    }
                }
                .padding()
            } else {
                // Not logged in: show login button
                Button("Log in to add comments") {
                    showLoginSheetForComments = true
                }
                .padding()
                .foregroundColor(.blue)
            }
        }
    }

    func addComment(to bathroom: Bathroom) {
        guard let user = session.currentUser else { return }
        let newC = Comment(username: user.username, content: newCommentText, bathroom: bathroom)
        context.insert(newC)
        try? context.save()
        newCommentText = ""
    }

    // MARK: - Codes
    func codeSection(for bath: Bathroom) -> some View {
        VStack {
            List {
                let sortedCodes = bath.codes.sorted {
                    // Sort by netScore desc, then by newest
                    if $0.netScore == $1.netScore {
                        return $0.timestamp > $1.timestamp
                    }
                    return $0.netScore > $1.netScore
                }
                ForEach(sortedCodes) { code in
                    VStack(alignment: .leading) {
                        Text("Code: \(code.code)")
                            .bold()
                        Text("Score: \(code.netScore)  (up/down votes)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("by \(code.username) at \(code.timestamp.formatted())")
                            .font(.caption)

                        if session.currentUser != nil {
                            // Logged in: can up/downvote
                            HStack {
                                Button("Upvote") {
                                    voteOnCode(code, as: .upvote)
                                }
                                Button("Downvote") {
                                    voteOnCode(code, as: .downvote)
                                }
                            }
                        }
                    }
                }
            }

            if session.currentUser != nil {
                // Logged in: can add code
                HStack {
                    TextField("Add code...", text: $newCodeText)
                        .textFieldStyle(.roundedBorder)
                    Button("Add") {
                        addBathroomCode(to: bath)
                    }
                }
                .padding()
            } else {
                // Not logged in
                Button("Log in to add codes or vote.") {
                    showLoginSheetForCodes = true
                }
                .padding()
                .foregroundColor(.blue)
            }
        }
    }

    func addBathroomCode(to bath: Bathroom) {
        guard let user = session.currentUser else { return }
        let bc = BathroomCode(username: user.username, code: newCodeText, bathroom: bath)
        context.insert(bc)
        try? context.save()
        newCodeText = ""
    }

    func voteOnCode(_ code: BathroomCode, as type: VoteType) {
        guard let user = session.currentUser else { return }

        // Check if user has voted on this code
        if let existingVote = code.votes.first(where: { $0.username == user.username }) {
            // If same vote, remove
            if existingVote.voteType == type {
                context.delete(existingVote)
            } else {
                // Change the vote type
                existingVote.voteType = type
                existingVote.timestamp = Date()
            }
        } else {
            // Create new vote
            let vote = BathroomCodeVote(username: user.username, voteType: type, codeRef: code)
            context.insert(vote)
        }
        try? context.save()
    }
}
