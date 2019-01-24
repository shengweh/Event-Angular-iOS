//
//  File.swift
//  event
//
//  Created by Severn on 11/25/18.
//  Copyright © 2018 Severn. All rights reserved.
//

import Foundation
import UIKit

class Player {

    var name: String
    
    var followerNum: String?
    var popularity: String?
    var spotifyLink: String?
    var playerImages: [String]
    
    init (name: String, followerNum: String?, popularity: String?, spotifyLink: String?, playerImages: [String]) {
        self.name = name
        self.followerNum = followerNum
        self.popularity = popularity
        self.spotifyLink = spotifyLink
        self.playerImages = playerImages
    }
}
