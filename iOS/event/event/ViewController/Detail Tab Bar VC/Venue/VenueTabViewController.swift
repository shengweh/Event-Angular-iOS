//
//  VenueTabViewController.swift
//  event
//
//  Created by Severn on 11/25/18.
//  Copyright © 2018 Severn. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner
import GoogleMaps

class VenueTabViewController: UIViewController {

    @IBOutlet weak var table: UITableView!
    
    
    var venueName: String?
    
    var venueLat: Double?
    var venueLng: Double?
    
    
    var label = ["Address","City","Phone Number","Open Hours","General Rules","Child Rules","7"]
    var labelContent = ["1","2","3","4","5","6","7"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        venueLat = -33.86
        venueLng = 151.20
        
        loadVenue()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        table.estimatedRowHeight = 100
        table.rowHeight = UITableView.automaticDimension
    }
    
    func loadVenue() {
        
        SwiftSpinner.show("Loading venue...")
        let parameters: Parameters = [ "vname": venueName! ]
        let requestURL = "https://csci571-hw8-event.appspot.com/venue"
        Alamofire.request(requestURL, parameters: parameters).responseJSON { response in
            
            
            if let data = response.result.value {
                
                let json = JSON(data)
                
                let x = json["resultsPage"]
                if x == "" {
                    print("no upcoming")
                } else {
                    
                    var add = json["_embedded"]["venues"][0]["address"]["line1"].stringValue
                    add = add == "" ? "N/A" : add
                    self.labelContent[0] = add

                    var city = json["_embedded"]["venues"][0]["city"]["name"].stringValue
                    city = city == "" ? "N/A" : city
                    var state = json["_embedded"]["venues"][0]["state"]["name"].stringValue
                    if state != "" {state = ", "+state}
                    self.labelContent[1] = city+state
                    
                    var phone = json["_embedded"]["venues"][0]["boxOfficeInfo"]["phoneNumberDetail"].stringValue
                    phone = phone == "" ? "N/A" : phone
                    self.labelContent[2] = phone
                    
                    
                    var oh = json["_embedded"]["venues"][0]["boxOfficeInfo"]["openHoursDetail"].stringValue
                    oh = oh == "" ? "N/A" : oh
                    self.labelContent[3] = oh
                    
                    
                    var gr = json["_embedded"]["venues"][0]["generalInfo"]["generalRule"].stringValue
                    gr = gr == "" ? "N/A" : gr
                    self.labelContent[4] = gr

                    var cr = json["_embedded"]["venues"][0]["generalInfo"]["childRule"].stringValue
                    cr = cr == "" ? "N/A" : cr
                    self.labelContent[5] = cr
                    

                    var lat = json["_embedded"]["venues"][0]["location"]["latitude"].stringValue
                    lat = lat == "" ? "-33.86" : lat
                    var lng = json["_embedded"]["venues"][0]["location"]["longitude"].stringValue
                    lng = lng == "" ? "151.20" : lng
                    
                    self.venueLat = Double(lat)
                    self.venueLng = Double(lng)
                    self.table.reloadData()
                    
                    SwiftSpinner.hide()
                    
                }
            }
            
            
        } // end of Alamofire request
        
    }
    
}


extension VenueTabViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row <= 5 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell") as? LabelCell
                else {
                    fatalError("The dequeued cell is not an instance of ResultTableViewCell.")
            }
            cell.label1.text = label[indexPath.row]
            cell.label2.text = labelContent[indexPath.row]
            return cell
        } else {


            guard let cell = tableView.dequeueReusableCell(withIdentifier: "mapCell") as? MapCell
                else {
                    fatalError("The dequeued cell is not an instance of ResultTableViewCell.")
            }
            
            // Create a GMSCameraPosition that tells the map to display the
            // coordinate -33.86,151.20 at zoom level 6.
            let camera = GMSCameraPosition.camera(withLatitude: venueLat!, longitude: venueLng!, zoom: 15.0)
            let mapView = GMSMapView.map(withFrame: cell.map.frame, camera: camera)
            
            // Creates a marker in the center of the map.
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: venueLat!, longitude: venueLng!)
            marker.map = mapView
            
            cell.map.addSubview(mapView)
            return cell
        }
        
    }
}

