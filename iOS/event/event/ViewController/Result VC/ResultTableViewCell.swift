//
//  ResultTableViewCell.swift
//  event
//
//  Created by Severn on 11/14/18.
//  Copyright © 2018 Severn. All rights reserved.
//

import UIKit
import EasyToast

protocol ResultCellDelegate {
    func showEastyToast(content: String)
}



class ResultTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryIcon: UIImageView!
    
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventLocation: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var favIcon: UIButton!
    
    var url = String()
    var eventID = String()
    var name = String()
    var date = String()
    var category = String()
    var venue = String()
    
    var players = [String]()
    
    var delegate: ResultCellDelegate?
    
    @IBAction func touchFavIcon(_ sender: UIButton) {
        
        
        // remove from fav
        if favIcon.currentImage == UIImage(named: "heart-filled") {
            
            // it must have a list
            let savedEvents = UserDefaults.standard.data(forKey: "savedEvents")      // get the list
            var eventList = try! JSONDecoder().decode([SavedEvent].self, from: savedEvents!)  // decode the list
            
            if let index = eventList.index(where: { $0.id == eventID }) {
                eventList.remove(at: index)
            }
            let savedData = try! JSONEncoder().encode(eventList)                    // encode the list
            UserDefaults.standard.set(savedData, forKey: "savedEvents")             //set to the userdefaults
            
            favIcon.setImage(UIImage(named: "heart-outline"), for: .normal)
            delegate?.showEastyToast(content: name+" was removed from favorites")
            
            
        } else { //not bookmarked yet so ADDING TO fav
            
            let saved = SavedEvent(url: url, id: eventID, name: name, date: date, category: category, venue: venue, bookmarked: true, players: players)
            
            //never added an event before
            if UserDefaults.standard.data(forKey: "savedEvents") == nil {
                var savedArray: [SavedEvent] = []                          // create a list
                savedArray.append(saved)                                  // append the first element to the list
                let savedData = try! JSONEncoder().encode(savedArray)       // decode the list
                UserDefaults.standard.set(savedData, forKey: "savedEvents")  // set to the userdefaults
            } else {
                
                let savedEvents = UserDefaults.standard.data(forKey: "savedEvents")      // get the list
                var eventList = try! JSONDecoder().decode([SavedEvent].self, from: savedEvents!)  // decode the list
                
                
                eventList.append(saved)                                                 // append the new element to the list
                let savedData = try! JSONEncoder().encode(eventList)                    // encode the list
                UserDefaults.standard.set(savedData, forKey: "savedEvents")             //set to the userdefaults
            }

            favIcon.setImage(UIImage(named: "heart-filled"), for: .normal)
            delegate?.showEastyToast(content: name+" was added to favorites")

        }
        
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
