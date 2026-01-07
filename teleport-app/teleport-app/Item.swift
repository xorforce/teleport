//
//  Item.swift
//  teleport-app
//
//  Created by Bhagat Singh on 07/01/26.
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
