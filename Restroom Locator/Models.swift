//
//  Models.swift
//  Restroom Locator
//
//  Example SwiftData models for a user system + bathrooms, comments, codes, votes.
//

import Foundation
import SwiftData
import CryptoKit

// MARK: - User
@Model
class User {
    @Attribute(.unique) var username: String
    var passwordHash: String

    init(username: String, passwordHash: String) {
        self.username = username
        self.passwordHash = passwordHash
    }

    static func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        let hash = SHA256.hash(data: data)
        return hash.map { String(format: "%02x", $0) }.joined()
    }

    func verifyPassword(_ password: String) -> Bool {
        return User.hashPassword(password) == self.passwordHash
    }
}

// MARK: - Bathroom
@Model
class Bathroom {
    @Attribute(.unique) var placeId: String
    var name: String?
    var latitude: Double
    var longitude: Double
    var address: String?
    var rating: Double?

    // Inverse of Comment.bathroom
    @Relationship(inverse: \Comment.bathroom)
    var comments: [Comment] = []

    // Inverse of BathroomCode.bathroom
    @Relationship(inverse: \BathroomCode.bathroom)
    var codes: [BathroomCode] = []

    init(placeId: String,
         name: String? = nil,
         latitude: Double,
         longitude: Double,
         address: String? = nil,
         rating: Double? = nil)
    {
        self.placeId = placeId
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.rating = rating
    }
}

// MARK: - Comment
@Model
class Comment {
    var username: String
    var content: String
    var timestamp: Date

    // Points back to the bathroom
    @Relationship
    var bathroom: Bathroom

    init(username: String,
         content: String,
         timestamp: Date = Date(),
         bathroom: Bathroom)
    {
        self.username = username
        self.content = content
        self.timestamp = timestamp
        self.bathroom = bathroom
    }
}

// MARK: - BathroomCode
@Model
class BathroomCode {
    var username: String
    var code: String
    var timestamp: Date

    // Points back to the bathroom
    @Relationship
    var bathroom: Bathroom

    // Inverse of BathroomCodeVote.codeRef
    @Relationship(inverse: \BathroomCodeVote.codeRef)
    var votes: [BathroomCodeVote] = []

    init(username: String,
         code: String,
         bathroom: Bathroom,
         timestamp: Date = Date())
    {
        self.username = username
        self.code = code
        self.bathroom = bathroom
        self.timestamp = timestamp
    }

    /// Returns the net score (upvotes - downvotes)
    var netScore: Int {
        let ups = votes.filter { $0.voteType == .upvote }.count
        let downs = votes.filter { $0.voteType == .downvote }.count
        return ups - downs
    }
}

// MARK: - BathroomCodeVote
@Model
class BathroomCodeVote {
    var username: String
    var voteType: VoteType
    var timestamp: Date

    // Relationship
    @Relationship
    var codeRef: BathroomCode

    init(username: String,
         voteType: VoteType,
         codeRef: BathroomCode,
         timestamp: Date = Date())
    {
        self.username = username
        self.voteType = voteType
        self.timestamp = timestamp
        self.codeRef = codeRef
    }
}

// MARK: - VoteType
enum VoteType: String, Codable {
    case upvote
    case downvote
}
