//
//  LabelCollectionReusableView.swift
//  event
//
//  Created by Severn on 11/25/18.
//  Copyright © 2018 Severn. All rights reserved.
//

import UIKit

class LabelCollectionReusableView: UICollectionReusableView {
    
    
    @IBOutlet weak var stack: UIStackView!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var artistName: UILabel!
    
    @IBOutlet weak var followerNum: UILabel!
    @IBOutlet weak var popularity: UILabel!
    
    var link: String!
    @IBAction func openSpotifyLink(_ sender: Any) {
        
        UIApplication.shared.open(URL(string: link)! as URL, options: [:], completionHandler: nil)
    }
    
}
