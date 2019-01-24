//
//  UpcomingViewController.swift
//  event
//
//  Created by Severn on 11/18/18.
//  Copyright © 2018 Severn. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class UpcomingViewController: UIViewController {

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var orderControl: UISegmentedControl!
    
    var id: String?
    var venueName: String?
    var upcomings = [Upcoming]()
    var upcomingsCopy = [Upcoming]()

    var byWhat: String?
    var byOrder: String?
    
    
    
    @IBAction func changeSortBy(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            byWhat = "default"
            self.upcomings = upcomingsCopy
            orderControl.isEnabled = false
        } else {
            orderControl.isEnabled = true
            if sender.selectedSegmentIndex == 1 {
                byWhat = "name"
            } else if sender.selectedSegmentIndex == 2 {
                byWhat = "time"
            } else if sender.selectedSegmentIndex == 3 {
                byWhat = "artist"
            } else {
                byWhat = "type"
            }
            sort()
        }
        self.table.reloadData()
    }
    
    
    @IBAction func changeSortOrder(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            byOrder = "ascending"
        } else {
            byOrder = "descending"
        }
        if byWhat != "default" {
            sort()
        }
        
        self.table.reloadData()
    }
    
    func sort() {
        if byOrder == "descending" {
            switch byWhat {
            case "name" :
                self.upcomings.sort{ $0.eventName > $1.eventName }
            case "time" :
                self.upcomings.sort{ $0.date > $1.date }
            case "artist" :
                self.upcomings.sort{ $0.artist > $1.artist }
            case "type" :
                self.upcomings.sort{ $0.type > $1.type }
            default:
                self.upcomings = upcomingsCopy
            }
        } else {
            switch byWhat {
            case "name" :
                self.upcomings.sort{ $0.eventName < $1.eventName }
            case "time" :
                self.upcomings.sort{ $0.date < $1.date }
            case "artist" :
                self.upcomings.sort{ $0.artist < $1.artist }
            case "type" :
                self.upcomings.sort{ $0.type < $1.type }
            default:
                self.upcomings = upcomingsCopy
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        SwiftSpinner.show("Searching for upcoming events...")
        table.delegate = self
        table.dataSource = self
        loadUpcomings()
        
        byWhat = "default"
        byOrder = "ascending"
        orderControl.isEnabled = false
    }
    

//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        table.reloadData()
//    }

    
    
    
    func loadUpcomings() {
        
        
        var list: [Upcoming] = []
        
        let parameters: Parameters = [ "upcoming": venueName! ]
        let requestURL = "https://csci571-hw8-event.appspot.com/upcoming"
        Alamofire.request(requestURL, parameters: parameters).responseJSON { response in
        
            
            if let data = response.result.value {

                let json = JSON(data)
                
                let x = json["resultsPage"]
                if x == "" {
                    print("no upcoming")
                } else {

                    for (index, subJson):(String, JSON) in x["results"]["event"] {
                        
                        if Int(index)! > 4 {
                            break
                        }

                        let name = subJson["displayName"].stringValue
                        let artistName = subJson["performance"][0]["displayName"].stringValue
                        let date = subJson["start"]["date"].stringValue
                        let time = subJson["start"]["time"].stringValue
                        let type = subJson["type"].stringValue
                        
                        let link = subJson["uri"].stringValue

                        let upcoming1 = Upcoming(eventName: name, artist: artistName, date: date+" "+time,
                                                 type: type, link: link)
                        list.append(upcoming1)
                    }
                    self.upcomings = list
                    self.upcomingsCopy = list
                    self.table.reloadData()
                    SwiftSpinner.hide()

                }
            }


        } // end of Alamofire request
        
    }
    
    
}

extension UpcomingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if upcomings.count == 0 {
            let label  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            label.text = "No results"
            label.textAlignment = .center
            table.backgroundView  = label
            table.separatorStyle  = .none
        }
        
        return upcomings.count

    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingCell") as? UpcomingTableViewCell
            else {
                fatalError("The dequeued cell is not an instance of ResultTableViewCell.")
        }
        
        let u1 = upcomings[indexPath.row]

        cell.eventNameButton.setTitle(u1.eventName, for: .normal)
        cell.artistName.text = u1.artist
        cell.eventDate.text = u1.date
        cell.eventType.text = "Type: "+u1.type
        cell.songkickLink = u1.link
        return cell
    }
}
