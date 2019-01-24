//
//  ArtistViewController.swift
//  event
//
//  Created by Severn on 11/21/18.
//  Copyright © 2018 Severn. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner
import Kingfisher

class ArtistViewController: UIViewController {

    
    @IBOutlet weak var collectionV: UICollectionView!
    
    var playerList = [Player]()
    var category: String?
    var players: [String]? //passed from lsit view
    
    var isMusic: Bool?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let p2 = Player(name: "Lady gaga", followerNum: "1234", popularity: "99", spotifyLink: "abc", playerImages: ["http://a.espncdn.com/i/teamlogos/ncaa/500/30.png"])
//
//        playerList.append(p2)
        
        isMusic = category == "Music" ? true : false
        
        
        if players?.count == 0 {
            print("nothing in the player list to be searched")
            
            let label  = UILabel(frame: CGRect(x: 0, y: 0, width: collectionV.bounds.size.width, height: collectionV.bounds.size.height))
            label.text = "No results"
            label.textAlignment = .center
            collectionV.backgroundView  = label
        } else {
            loadPlayer()
        }
        
        if let layout = collectionV.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionHeadersPinToVisibleBounds = true
        }

    }
    
    func loadPlayer() {
        
        
        
        SwiftSpinner.show("Loading Artist...")
        
        if isMusic == true {
            
            var counter = 0
            for pName in players! {
                counter = counter + 1
                if counter > 2 {
                    break
                }
                let parameters: Parameters = [ "artist": pName ]
                let requestURL = "https://csci571-hw8-event.appspot.com/spotify"
                Alamofire.request(requestURL, parameters: parameters).responseJSON { response in
                    if let data = response.result.value {
                        let json = JSON(data)
                        let x = json["artists"]["items"]
                        if x == "" {
                            print("no artist")
                        } else {
                            let name = pName
                            var followerNum = "N/A"
                            var popularity = "N/A"
                            var spotifyLink = "N/A"
                            
                            for (_, subJson):(String, JSON) in x {
                                if subJson["name"].stringValue.lowercased() == pName.lowercased() {
                                    let tempFollowerNum =  subJson["followers"]["total"].intValue
                                    let numberFormatter = NumberFormatter()
                                    numberFormatter.numberStyle = NumberFormatter.Style.decimal
                                    followerNum = numberFormatter.string(from: NSNumber(value:tempFollowerNum))!
                                    
                                    popularity = subJson["popularity"].stringValue
                                    spotifyLink =  subJson["external_urls"]["spotify"].stringValue
                                    break
                                }
                            }
                            
                            let p1 = Player(name: name, followerNum: followerNum, popularity: popularity, spotifyLink: spotifyLink, playerImages: ["http://a.espncdn.com/i/teamlogos/ncaa/500/30.png"])
                            
                            let para: Parameters = [ "player": pName ]
                            let requestURL = "https://csci571-hw8-event.appspot.com/img"
                            Alamofire.request(requestURL, parameters: para).responseJSON { response in
                                if let dataa = response.result.value {
                                    let jsonn = JSON(dataa)
                                    let xyz = jsonn["items"]
                                    if xyz == "" {
                                        print("no image")
                                    } else {
                                        var tList = [String]()
                                        for (_, subJsonn):(String, JSON) in xyz {
                                            tList.append(subJsonn["link"].stringValue)
                                        }
                                        p1.playerImages = tList
                                        
                                        self.playerList.append(p1)
                                        self.collectionV.reloadData()
                                        SwiftSpinner.hide()
                                    }

                                }

                            }
                            
//                            self.playerList.append(p1)
//
//                            self.collectionV.reloadData()
//                            SwiftSpinner.hide()
                        }
                        
                    } // if let data = response.result.value  end here
                    
                    
                } // end of Alamofire
                
            }
        } else {
            
            var counting = 0
            for pName in players! {
                counting = counting + 1
                if counting > 2 {
                    break
                }
                
                let p1 = Player(name: pName, followerNum: nil, popularity: nil, spotifyLink: nil, playerImages: ["http://a.espncdn.com/i/teamlogos/ncaa/500/30.png"])
                
                let para: Parameters = [ "player": pName ]
                let requestURL = "https://csci571-hw8-event.appspot.com/img"
                Alamofire.request(requestURL, parameters: para).responseJSON { response in
                    if let dataa = response.result.value {
                        let jsonn = JSON(dataa)
                        let xyz = jsonn["items"]
                        if xyz == "" {
                            print("no image")
                        } else {
                            var tList = [String]()
                            for (_, subJsonn):(String, JSON) in xyz {
                                tList.append(subJsonn["link"].stringValue)
                            }
                            p1.playerImages = tList
                            
                            self.playerList.append(p1)
                            self.collectionV.reloadData()
                            SwiftSpinner.hide()
                        }
                    }
                    
                } // end of Alamofire call
                
            } // end of for loop (up to two calls
            
            
            

            

        }
    
    }


}


extension ArtistViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return playerList.count
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playerList[section].playerImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "artistCell", for: indexPath) as! ArtistCollectionViewCell
    
        let xxx = playerList[indexPath.section]
        let imageNames = xxx.playerImages
        let imageName = imageNames[indexPath.item]
        
        let url = URL(string: imageName)
//        imageView.kf.setImage(with: url)
//
//
//        cell.image.image = UIImage(named: imageName)
        cell.image.kf.setImage(with: url)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "artistHeader", for: indexPath) as! LabelCollectionReusableView
        
        let player = playerList[indexPath.section]
        sectionHeader.title.text = player.name
        sectionHeader.artistName.text = player.name
        sectionHeader.followerNum.text = player.followerNum
        sectionHeader.popularity.text = player.popularity
        sectionHeader.link = player.spotifyLink
        
        return sectionHeader
    }
    

    
    // adjust collection view size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        
        let width = collectionView.frame.width - 60
        let height: CGFloat = 240.0
        return CGSize(width: width, height: height)
    }
    
    
    // adjust section header
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if isMusic == true {
            return CGSize(width: collectionView.bounds.width, height: 240)
        } else {
            return CGSize(width: collectionView.bounds.width, height: 40)
        }
    }
    
    
}

