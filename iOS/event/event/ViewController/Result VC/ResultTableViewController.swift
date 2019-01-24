//
//  ResultTableViewController.swift
//  event
//
//  Created by Severn on 11/14/18.
//  Copyright © 2018 Severn. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftSpinner

var idddddd = "123456"
var iddddddbool = false

class ResultTableViewController: UITableViewController {
    
    
    var events = [Event]()
    var JSONFromSearchVC = JSON()       // JSON data received from Search VC
    
    var selectedEvent = Event(url: "0", id: "1", name: "2", date: "3", category: "4", venue: "5", bookmarked: false, players: ["1"] )
    

    private func loadResultList() -> [Event]{
        
        var tempList: [Event] = []

        
        for (_, subJson):(String, JSON) in JSONFromSearchVC["_embedded"]["events"] {
            
            
            let url = subJson["url"].stringValue
            let eventID = subJson["id"].stringValue

            var bookmarked = false

            if UserDefaults.standard.data(forKey: "savedEvents") != nil {
                let savedEvents = UserDefaults.standard.data(forKey: "savedEvents")
                let eventList = try! JSONDecoder().decode([SavedEvent].self, from: savedEvents!)
                for e in eventList {
                    if e.id == eventID {
                        bookmarked = true
                        break
                    }
                }
            } else {
                // if there is no such as list means there must be no data saved
                //therefore everything is not bookmarked yet
            }
            
            var name = subJson["name"].stringValue
            if (name.count > 60) {
                let index = name.index(name.startIndex, offsetBy: 60)
                name = String(name[..<index])
                name += "..."
            }
            
            let date = subJson["dates"]["start"]["localDate"].stringValue
            let optionalTime = subJson["dates"]["start"]["localTime"].stringValue
            let venueName = subJson["_embedded"]["venues"][0]["name"].stringValue
            let category = subJson["classifications"][0]["segment"]["name"].stringValue

            var playerList: [String] = []
            for (_, subsubJson):(String, JSON) in subJson["_embedded"]["attractions"] {
                playerList.append(subsubJson["name"].stringValue)
            }
            

            tempList.append( Event(url: url,
                                id: eventID,
                                name: name,
                                date: date+" "+optionalTime,
                                category: category,
                                venue: venueName,
                                bookmarked: bookmarked,
                                players: playerList)
                             )
        }
        return tempList

        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Search Results"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        events = loadResultList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        for event in events {
            
            if event.id == idddddd {
                event.bookmarked = iddddddbool
            }
        }
        self.tableView.reloadData()

//        print(idddddd)
//        print(iddddddbool)
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if events.count != 0 {
            return events.count
        } else {
            // count is 0
            
            
            
            let label  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            label.text = "No results"
            label.textAlignment = .center
            self.tableView.backgroundView  = label
            self.tableView.separatorStyle  = .none
            
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ResultTableViewCell", for: indexPath) as? ResultTableViewCell
            else {
                fatalError("The dequeued cell is not an instance of ResultTableViewCell.")
        }
        // Configure the cell...
        
        let event1 = events[indexPath.row]
        
        var categoryIcon = UIImage(named: "sport")
        let category = event1.category
        switch category {
        case "Music":
            categoryIcon = UIImage(named: "speaker")
        case "Sports":
            categoryIcon = UIImage(named: "sport")
        case "Arts & Theatre":
            categoryIcon = UIImage(named: "paint-palette")
        case "Film":
            categoryIcon = UIImage(named: "clapperboard")
        case "Miscellaneous":
            categoryIcon = UIImage(named: "miscellaneous")
        default:
            categoryIcon = UIImage(named: "sport")
        }
        
        
        cell.categoryIcon.image = categoryIcon
        cell.eventName.text = event1.name
        cell.eventDate.text = event1.date
        cell.eventLocation.text = event1.venue
        

        let favIcon = event1.bookmarked == true ? UIImage(named: "heart-filled") : UIImage(named: "heart-outline")
        cell.favIcon.setImage(favIcon, for: .normal)

        
        cell.category = event1.category
        cell.name = event1.name
        cell.venue = event1.venue
        cell.date = event1.date
        cell.eventID = event1.id
        cell.url = event1.url
        cell.players = event1.players
        
        cell.delegate = self
        return cell
    }
 

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedEvent = events[indexPath.row]
        performSegue(withIdentifier: "ListToDetail", sender: selectedEvent)

    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard let DetailTabBarVC = segue.destination as? DetailTabBarViewController else {return}
//
//        DetailTabBarVC.id = selectedEvent.id
//        DetailTabBarVC.venueName = selectedEvent.venue
        
        guard let DetailVC = segue.destination as? DetailViewController else {return}
        DetailVC.selectedEvent = sender as? Event

    }
    

}


extension ResultTableViewController: ResultCellDelegate {

    func showEastyToast(content: String) {
        view.showToast(content, position: .bottom, popTime: 3, dismissOnTap: true)
    }

}
