//
//  SearchViewController.swift
//  event
//
//  Created by Severn on 11/13/18.
//  Copyright © 2018 Severn. All rights reserved.
//

import UIKit
import SwiftSpinner
import EasyToast
import Alamofire
import McPicker
import SwiftyJSON
import CoreLocation
import SearchTextField


class SearchViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var keyword: SearchTextField!
    
    @IBOutlet weak var mcTextField: McTextField!        // category input
    @IBOutlet weak var radiusInput: UITextField!        // distance input
    @IBOutlet weak var unitInput: UIPickerView!         // unit input
    let units = ["miles", "kms"]
    var selectedUnit: String!
    
    @IBOutlet weak var btn1: UIButton!                  // radio button1 current location
    @IBOutlet weak var btn2: UIButton!                  // radio button2 costum locationn
    @IBOutlet weak var optionalLocation: UITextField!   // optional location input
    
    let locationManager: CLLocationManager = CLLocationManager()
    
    var returnedResult = JSON()
    

    @objc func textFieldDidChange(_ textField: UITextField) {
        
        let text = textField.text
        let requestURL = "https://csci571-hw8-event.appspot.com/suggest?input=" + text!
        Alamofire.request(requestURL).responseJSON { response in
            if let data = response.result.value {
                let json = JSON(data)
                
                let x = json["_embedded"]["attractions"]
                if x != "" {
                    
                    var tempList = [String]()
                    for (_, subJson):(String, JSON) in x {
                        tempList.append(subJson["name"].stringValue)
                    }
                    
                    self.keyword.filterStrings(tempList)
                }
            }
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        keyword.filterStrings([])
        keyword.theme.bgColor = UIColor.white
        keyword.theme.font = UIFont.systemFont(ofSize: 14)
        keyword.theme.separatorColor = UIColor.lightGray
        keyword.theme.cellHeight = 50
        keyword.maxNumberOfResults = 5
        keyword.highlightAttributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14)]
        
        keyword.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        
        let categoryOptions: [[String]] = [["All", "Music", "Sports", "Arts & Theatre", "Film", "Miscellaneous"]]
        let mcInputView = McPicker(data: categoryOptions)
        mcTextField.inputViewMcPicker = mcInputView
        mcTextField?.text = "All"       // default text
        mcTextField.doneHandler = { [weak mcTextField] (selections) in
            mcTextField?.text = selections[0]!
        }
        mcTextField.selectionChangedHandler = { [weak mcTextField] (selections, componentThatChanged) in
            mcTextField?.text = selections[componentThatChanged]!
        }
//        mcTextField.cancelHandler = { [weak mcTextField] in
//            mcTextField?.text = "Cancelled."
//        }
        
        unitInput.delegate = self
        unitInput.dataSource = self
        btn1.isSelected = true  // by default current location is used
        optionalLocation.isEnabled = false
    }
    
    @IBAction func clickBtn1(_ sender: Any) {
        btn1.isSelected = true
        btn2.isSelected = false
        optionalLocation.isEnabled = false
        optionalLocation.text = ""
    }
    
    
    @IBAction func clickBtn2(_ sender: Any) {
        btn1.isSelected = false
        btn2.isSelected = true;
        optionalLocation.isEnabled = true
    }
    
    
    @IBAction func submit(_ sender: UIButton) {
        
        let trimmedKeyword = keyword.text?.replacingOccurrences(of: " ", with: "")
        let trimmedLocation = optionalLocation.text?.replacingOccurrences(of: " ", with: "")
        
        if trimmedKeyword == "" {
            self.view.showToast("Keyword and locations are mandatory fields", position: .bottom, popTime: 5, dismissOnTap: true)
            
        } else if btn2.isSelected == true && trimmedLocation == "" {
            // optional location is mandatory now
            self.view.showToast("Keyword and locations are mandatory fields", position: .bottom, popTime: 5, dismissOnTap: true)
            
        } else {
            
            SwiftSpinner.show("Searching for events...")
          
            let keyword = self.keyword.text
            var category = mcTextField.text
            switch category {
            case "Music":
                category = "music"
            case "Sports":
                category = "sport"
            case "Arts & Theatre":
                category = "arts-theatre"
            case "Film":
                category = "film"
            case "Miscellaneous":
                category = "miscellaneous"
            default:
                category = "all"
            }

            let radius = radiusInput.text == "" ? "10" : radiusInput.text!
            let unit = selectedUnit == "miles" ? "miles" : "km"
            
            
            var lat = 34.022218
            var lng = -118.285020
            if let location = locationManager.location?.coordinate {
                lat = location.latitude
                lng = location.longitude
            }
            
            let oLocation = optionalLocation.text == "" ? "undefined" : optionalLocation.text!

            let parameters: Parameters = [
                "keyword": keyword!,
                "category": category!,
                "radius": radius,
                "unit": unit,
                "lat": String(format: "%.6f", lat),
                "lng": String(format: "%.6f", lng),
                "optionalLocation": oLocation
            ]
            
            let requestURL = "https://csci571-hw8-event.appspot.com/search"
            Alamofire.request(requestURL, parameters: parameters).responseJSON { response in
                if let data = response.result.value {
                    self.returnedResult = JSON(data)
                    self.locationManager.stopUpdatingLocation()
                    SwiftSpinner.hide()
                    self.performSegue(withIdentifier: "ResultToDetail", sender: self)
                }
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let resultVC = segue.destination as? ResultTableViewController else {return}
        // resultVC.eventList = foundEvents
        resultVC.JSONFromSearchVC = returnedResult
        
    }
    
    @IBAction func clearResult(_ sender: UIButton) {
        
        // reset keyword
        keyword.text = ""
        
        // reset category
        mcTextField.text = "All"
        
        // reset radius
        radiusInput.text = ""
        
        // reset unit
        unitInput.selectRow(0, inComponent: 0, animated: true)
        selectedUnit = "miles"
        
        // reset from button
        btn1.isSelected = true
        btn2.isSelected = false
    }
}

extension SearchViewController: UIPickerViewDataSource {
    
    // how many columns
    func numberOfComponents (in pickerView : UIPickerView) -> Int{
        return 1;
    }
    // how many options
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return units.count
    }
    
}

extension SearchViewController: UIPickerViewDelegate {
    
    // define the apperance of the view  shrink the font size
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        label.text = units[row]
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }
    
    // a listenr capturing the change
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedUnit = units[row]
    }
    
}
