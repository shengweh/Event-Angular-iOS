//
//  InfoViewController.swift
//  event
//
//  Created by Severn on 11/19/18.
//  Copyright © 2018 Severn. All rights reserved.
//

import UIKit
import SwiftSpinner
import Alamofire
import SwiftyJSON

class InfoViewController: UIViewController {
    
    
    var id: String?


    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var venueName: UILabel!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var eventCategory: UILabel!
    @IBOutlet weak var priceRange: UILabel!
    @IBOutlet weak var ticketStatus: UILabel!

    

    
    var artistString: String?
    var venueString: String?
    var timeString: String?
    var categoryString: String?
    var priceString: String?
    var statusString: String?
    var buyString: String?
    var mapString: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadInfo()
    }

    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//    }

    @IBAction func openTM(_ sender: Any) {
        
        if buyString != "" {
            UIApplication.shared.open(URL(string: buyString!)! as URL, options: [:], completionHandler: nil)
        }
    }
    
    
    @IBAction func openSeatMap(_ sender: Any) {
        
        // not open if map link is not nil
        if mapString != "" {
            UIApplication.shared.open(URL(string: mapString!)! as URL, options: [:], completionHandler: nil)
            
        }
    }
    
    
    func loadInfo() {
        
        SwiftSpinner.show("Searching for upcoming events...")

        let parameters: Parameters = ["eventID": id!]

        let requestURL = "https://csci571-hw8-event.appspot.com/event"
        Alamofire.request(requestURL, parameters: parameters).responseJSON { response in
            if let data = response.result.value {
                let json = JSON(data)
                
                var artist = ""
                for (index, subJson):(String, JSON) in json["_embedded"]["attractions"] {
                    
                    if Int(index)! > 0 { artist += " | "}
                    artist += subJson["name"].stringValue
                }
                if artist == "" {
                    artist = "N/A"
                }
                
                let venue = json["_embedded"]["venues"][0]["name"].stringValue
                


                
                var localDate = json["dates"]["start"]["localDate"].stringValue
                
                if localDate != ""{
                    let dateFormatterGet = DateFormatter()
                    dateFormatterGet.dateFormat = "yyyy-MM-dd"
                    let dateFormatterPrint = DateFormatter()
                    dateFormatterPrint.dateFormat = "MMM dd, yyyy"
                    let date: Date? = dateFormatterGet.date(from: localDate)
                    localDate = dateFormatterPrint.string(from: date!)
                }
          
                let localTime = json["dates"]["start"]["localTime"].stringValue

                var segment = json["classifications"][0]["segment"]["name"].stringValue
                if segment == "" {segment = "N/A"}
                var genre = json["classifications"][0]["genre"]["name"].stringValue
                if genre == "" {genre = "N/A"}
                let category = segment+" | "+genre
                
                var priceRange = "N/A"
                var min = json["priceRanges"][0]["min"].stringValue
                

                
                
                var max = json["priceRanges"][0]["max"].stringValue
                if (min == "" && max == "") {
                    // no price range
                } else {
                    min = min == "" ? "N/A" : min
                    max = max == "" ? "N/A" : max
                    priceRange = min+"-"+max+" (USD)"
                }
                
                let status = json["dates"]["status"]["code"].stringValue
                let buy = json["url"].stringValue
                let seatmap = json["seatmap"]["staticUrl"].stringValue
            
                
                self.buyString = buy
                self.mapString = seatmap
                
                self.artist.text = artist
                self.venueName.text = venue
                self.eventTime.text = (localDate == "" && localTime == "") ? "N/A" : localDate+" "+localTime
                self.eventCategory.text = category
                self.priceRange.text = priceRange
                self.ticketStatus.text = status

                SwiftSpinner.hide()

            }
        }
        
    }
}
