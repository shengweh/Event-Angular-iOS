//
//  UpcomingTableViewCell.swift
//  event
//
//  Created by Severn on 11/18/18.
//  Copyright © 2018 Severn. All rights reserved.
//

import UIKit

class UpcomingTableViewCell: UITableViewCell {
    
    
    
    @IBOutlet weak var eventNameButton: UIButton!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventType: UILabel!
    
    var songkickLink: String?
    
    @IBAction func goToSongkick(_ sender: Any) {
        
        UIApplication.shared.open(URL(string: songkickLink!)! as URL, options: [:], completionHandler: nil)
        
    }
}
