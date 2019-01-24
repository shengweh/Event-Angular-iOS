//
//  SavedEvent.swift
//  event
//
//  Created by Severn on 11/28/18.
//  Copyright © 2018 Severn. All rights reserved.
//

import Foundation
import UIKit

struct SavedEvent: Codable {
    
    var url: String
    var id: String
    var name: String
    var date: String
    var category: String
    var venue: String
    var bookmarked: Bool
    var players: [String]
}
