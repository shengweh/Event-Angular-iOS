//
//  Event.swift
//  event
//
//  Created by Severn on 11/17/18.
//  Copyright © 2018 Severn. All rights reserved.
//

import Foundation
import UIKit

class Event {
    var url: String
    var id: String
    var name: String
    var date: String
    var category: String
    var venue: String
    var bookmarked: Bool
    var players: [String]
    
    init (url: String, id: String, name: String, date: String, category: String,
          venue: String, bookmarked: Bool, players: [String]) {

        self.url = url
        self.id = id
        self.name = name
        self.date = date
        self.category = category
        self.venue = venue
        self.bookmarked = bookmarked
        self.players = players
    }
}
