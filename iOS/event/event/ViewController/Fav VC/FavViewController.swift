//
//  FavViewController.swift
//  event
//
//  Created by Severn on 11/27/18.
//  Copyright © 2018 Severn. All rights reserved.
//

import UIKit
import EasyToast

class FavViewController: UIViewController {
    
    @IBOutlet weak var table: UITableView!
    
    var events = [SavedEvent]()


    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        var tempList = [SavedEvent]()
        
        if UserDefaults.standard.data(forKey: "savedEvents") != nil {
            
            let savedEvents = UserDefaults.standard.data(forKey: "savedEvents")
            let eventList = try! JSONDecoder().decode([SavedEvent].self, from: savedEvents!)
            for e in eventList {
                tempList.append(e)
            }
        }
        
        events = tempList
       // print(tempList.count)
       // print(events.count)
        table.reloadData()

        for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
            // print("\(key) = \(value) \n")
            if key == "savedEvents" {
                
                let savedEvents = UserDefaults.standard.data(forKey: key)
                let eventList = try! JSONDecoder().decode([SavedEvent].self, from: savedEvents!)
                for e in eventList {
                    print(e.name)
                }
            }
        }

 
    }
}


extension FavViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if events.count == 0 {
            //print("here?.........")
            let label  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            label.text = "No favorites"
            label.textAlignment = .center
            table.backgroundView  = label
            table.separatorStyle  = .none
        }
        
        if events.count != 0 {
            
            tableView.backgroundView = nil
            table.separatorStyle  = .singleLine

        }

        
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "favCell") as? FavTableViewCell
            else {
                fatalError("The dequeued cell is not an instance of ResultTableViewCell.")
        }
        
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
        
        cell.categoryImg.image = categoryIcon
        cell.nameLabel.text = event1.name
        cell.venueLabel.text = event1.venue
        cell.dateLabel.text = event1.date
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        


        if editingStyle == .delete {
            let event1 = events[indexPath.row]
            let thisID = event1.id

            // it must have a list
            let savedEvents = UserDefaults.standard.data(forKey: "savedEvents")      // get the list
            var eventList = try! JSONDecoder().decode([SavedEvent].self, from: savedEvents!)  // decode the list
            
            if let index = eventList.index(where: { $0.id == thisID }) {
                eventList.remove(at: index)
            }
            let savedData = try! JSONEncoder().encode(eventList)                    // encode the list
            UserDefaults.standard.set(savedData, forKey: "savedEvents")             //set to the userdefaults
            
            events.remove(at: indexPath.row)            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            view.showToast(event1.name + " was removed from favorites", position: .bottom, popTime: 3, dismissOnTap: true)

            
        }
    }
 
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let e = events[indexPath.row]

        let selectedEvent = Event(url: e.url, id: e.id, name: e.name, date: e.date, category: e.category, venue: e.venue, bookmarked: false, players: e.players)
        performSegue(withIdentifier: "FavToDetail", sender: selectedEvent)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        
        guard let DetailVC = segue.destination as? DetailViewController else {return}
        DetailVC.selectedEvent = sender as? Event
        
    }
    
}

