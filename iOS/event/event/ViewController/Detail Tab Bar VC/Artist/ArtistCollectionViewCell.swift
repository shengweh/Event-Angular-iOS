//
//  ArtistCollectionViewCell.swift
//  event
//
//  Created by Severn on 11/25/18.
//  Copyright © 2018 Severn. All rights reserved.
//

import UIKit

class ArtistCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    
    var imageName: String! {
        didSet {
            image.image = UIImage(named: imageName)
        }
    }
}
