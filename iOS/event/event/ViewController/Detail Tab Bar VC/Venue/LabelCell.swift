//
//  LabelCell.swift
//  event
//
//  Created by Severn on 11/25/18.
//  Copyright © 2018 Severn. All rights reserved.
//

import UIKit

class LabelCell: UITableViewCell {


    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
