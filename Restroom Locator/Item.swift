//
//  Item.swift
//  Restroom Locator
//
//  Created by Kavin Rajasekaran on 9/28/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
