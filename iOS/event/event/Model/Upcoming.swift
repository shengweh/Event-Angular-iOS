//
//  Upcoming.swift
//  event
//
//  Created by Severn on 11/18/18.
//  Copyright © 2018 Severn. All rights reserved.
//

import Foundation
import UIKit

class Upcoming {
    
    var eventName: String
    var artist: String
    var date: String
    var type: String
    var link: String
    
    init(eventName: String, artist: String, date: String, type: String, link: String) {
        self.eventName = eventName
        self.artist = artist
        self.date = date
        self.type = type
        self.link = link
    }
}
