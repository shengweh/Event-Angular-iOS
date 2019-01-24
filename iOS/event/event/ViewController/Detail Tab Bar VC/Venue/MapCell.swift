//
//  MapCell.swift
//  event
//
//  Created by Severn on 11/25/18.
//  Copyright © 2018 Severn. All rights reserved.
//

import UIKit
import GoogleMaps

class MapCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var map: GMSMapView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
