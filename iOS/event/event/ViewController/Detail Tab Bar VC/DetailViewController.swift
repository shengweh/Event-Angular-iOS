//
//  DetailViewController.swift
//  event
//
//  Created by Severn on 11/24/18.
//  Copyright © 2018 Severn. All rights reserved.
//

import UIKit
import EasyToast

class DetailViewController: UITabBarController {
    
    var faved: UIBarButtonItem!
    var notFaved: UIBarButtonItem!
    var twitterButton: UIBarButtonItem!

    
    var selectedEvent: Event?
    
    @objc func twitterClicked() {
        

        let name = selectedEvent?.name
        let venue = selectedEvent?.venue
        let link = selectedEvent?.url
        
        var str = "https://twitter.com/intent/tweet?text=Check out " + name! +
            " located at " + venue! + ". Website: " + link! + " %23CSCI571EventSearch"
        str = str.replacingOccurrences(of: " ", with: "%20")
        let url = URL(string: str)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    
 
    
    @objc func changedToUnfav() {
        
        
        idddddd = (selectedEvent?.id)!
        iddddddbool = false
        
        // remove from the fav list
        
        let savedEvents = UserDefaults.standard.data(forKey: "savedEvents")      // get the list
        var eventList = try! JSONDecoder().decode([SavedEvent].self, from: savedEvents!)  // decode the list
        
        if let index = eventList.index(where: { $0.id == (selectedEvent?.id)! }) {
            eventList.remove(at: index)
        }
        let savedData = try! JSONEncoder().encode(eventList)                    // encode the list
        UserDefaults.standard.set(savedData, forKey: "savedEvents")             //set to the userdefaults
        
        self.navigationItem.rightBarButtonItems  = [notFaved, twitterButton]
        
        self.view.showToast((selectedEvent?.name)!+" was removed from favorites", position: .bottom, popTime: 5, dismissOnTap: true)

    }
    
    @objc func changedToFav() {
        
        idddddd = (selectedEvent?.id)!
        iddddddbool = true
        
        print( (selectedEvent?.id)!)
        
        let saved = SavedEvent(url: (selectedEvent?.url)!,
                               id: (selectedEvent?.id)!,
                               name: (selectedEvent?.name)!,
                               date: (selectedEvent?.date)!,
                               category: (selectedEvent?.category)!,
                               venue: (selectedEvent?.venue)!,
                               bookmarked: true,
                               players: (selectedEvent?.players)!)

        
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
        
        
        
        self.navigationItem.rightBarButtonItems  = [faved, twitterButton]
        // add to the fav list
        
        self.view.showToast((selectedEvent?.name)!+" was added to favorites", position: .bottom, popTime: 5, dismissOnTap: true)

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        var bookmarked = false
        if UserDefaults.standard.data(forKey: "savedEvents") != nil {
            let savedEvents = UserDefaults.standard.data(forKey: "savedEvents")
            let eventList = try! JSONDecoder().decode([SavedEvent].self, from: savedEvents!)
            for e in eventList {
                if e.id == (selectedEvent?.id)! {
                    bookmarked = true
                    break
                }
            }
        } else {
            // if there is no such as list means there must be no data saved
            //therefore everything is not bookmarked yet
        }
        
        faved = UIBarButtonItem(image: UIImage(named: "heart-filled"), style: .plain, target: self, action: #selector(changedToUnfav))
        notFaved = UIBarButtonItem(image: UIImage(named: "heart-outline"), style: .plain, target: self, action: #selector(changedToFav))
        twitterButton = UIBarButtonItem(image: UIImage(named: "twitter"), style: .plain, target: self, action: #selector(twitterClicked))

        if bookmarked == true {
            self.navigationItem.rightBarButtonItems  = [faved, twitterButton]
        } else {
            self.navigationItem.rightBarButtonItems  = [notFaved, twitterButton]
        }
        
        
        
        
        guard let viewControllers = viewControllers else {return}
        
        for viewController in viewControllers {
            
            if let infoViewController = viewController as? InfoViewController {
                infoViewController.id = selectedEvent!.id
            }
            
            if let artistViewController = viewController as? ArtistViewController {
                artistViewController.category = selectedEvent!.category
                artistViewController.players = selectedEvent!.players
                
            }

            if let venueTableViewController = viewController as? VenueTabViewController {
                venueTableViewController.venueName = selectedEvent!.venue
            }
            
            if let upcomingViewController = viewController as? UpcomingViewController {
                upcomingViewController.venueName = selectedEvent!.venue
            }
            
        }
    }
    
    
    
    
}
