//
//  PlayerControllerViewController.swift
//  assign5
//
//  Created by Kevin Nogales on 5/8/20.
//  Copyright © 2020 Kevin Nogales. All rights reserved.
//

import UIKit
import AVKit
import FirebaseDatabase

struct Video: Comparable {
    static func < (lhs: Video, rhs: Video) -> Bool {
        if lhs.seen == true && rhs.seen == true {
            if lhs.likes < rhs.likes {
                return false
            } else {
                return true
            }
        } else if lhs.seen == true && rhs.seen == false {
            return false
        } else if lhs.seen == false && rhs.seen == true {
            return true
        } else if lhs.seen == false && rhs.seen == false {
            if lhs.likes < rhs.likes {
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    var id: String
    var name: String
    var url: String
    var likes: Int
    var seen: Bool
    var liked: Bool
}

struct SeenVideos {
    var seenVideos: [String: String]
}

class PlayerController: UIViewController {
    
    var currentUser: String = "knogales"
    var rootRef: DatabaseReference!
    var videoPlayList: [Video] = []
    var currentSeenVideos: SeenVideos?
    var currentVideo: Video?
    var currentVideoIndex: Int?
    var playerLayer: AVPlayerLayer!
    var likeButton: UIButton?
    var likeCountLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.rootRef = Database.database().reference()
        self.currentSeenVideos = SeenVideos(seenVideos: [:])
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(nextVideo))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(restartVideo))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: "7A9E9F")
        self.view.layer.backgroundColor = UIColor(hexString: "4F6367")!.cgColor
        
        self.playerLayer = AVPlayerLayer()
        self.playerLayer.frame = self.view.frame
        self.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.view.layer.addSublayer(playerLayer)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(self.backButtonAction))
        
        // NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.nextVideo), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        self.rootRef.observe(.value, with: { (snapshot) in
            self.videoPlayList = []
            for child in snapshot.children {
                if let data = child as? DataSnapshot {
                    if data.key == "seen" {
                        if (data.value! as! Dictionary<String, Dictionary<String, String>>).keys.contains(self.currentUser) {
                            self.currentSeenVideos = SeenVideos(seenVideos: (data.value! as! Dictionary<String, Dictionary<String, String>>)[self.currentUser]!)
                        }
                    }
                    if data.key == "urls" {
                        self.videoPlayList = []
                        for currentVideo in data.value! as! Dictionary<String, Any> {
                            let currentVideoKey = currentVideo.key
                            var currentVideoLikeCount = 0
                            var currentVideoName = ""
                            var currentVideoURL = ""
                            var currentVideoSeen = false
                            var currentVideoLiked = false
                            for currentKey in (currentVideo.value as! Dictionary<String, Any>).keys {
                                if currentKey == "name" {
                                    currentVideoName = (currentVideo.value as! Dictionary<String, Any>)[currentKey] as! String
                                } else if currentKey == "url" {
                                    currentVideoURL = (currentVideo.value as! Dictionary<String, Any>)[currentKey] as! String
                                } else if currentKey == "likes" {
                                    currentVideoLikeCount = ((currentVideo.value as! Dictionary<String, Any>)[currentKey] as! Dictionary<String, Any>).count
                                    if ((currentVideo.value as! Dictionary<String, Any>)[currentKey] as! Dictionary<String, Any>).keys.contains(self.currentUser) {
                                        currentVideoLiked = true
                                    }
                                }
                            }
                            if self.currentSeenVideos!.seenVideos.keys.contains(currentVideoKey) {
                                currentVideoSeen = true
                            }
                            let videoToAdd = Video(id: currentVideoKey, name: currentVideoName, url: currentVideoURL, likes: currentVideoLikeCount, seen: currentVideoSeen, liked: currentVideoLiked)
                            self.videoPlayList.append(videoToAdd)
                        }
                    }
                    self.videoPlayList.sort()
                    print(self.videoPlayList)
                    
                    if self.currentVideo == nil {
                        // No current video, add the first vide in videoPlaylist as current video
                        if self.videoPlayList.count > 0 {
                            self.currentVideo = self.videoPlayList.first
                            self.currentVideoIndex = 0
                            self.displayCurrentVideo()
                        }
                    } else {
                        // Remove currentVideo from videoPlaylist and add it to the beginning.
                        self.videoPlayList.removeAll(where: {self.currentVideo!.id == $0.id})
                        self.videoPlayList.insert(self.currentVideo!, at: 0)
                        self.currentVideoIndex = 0
                    }
                }
            }
        })
    }
    
    @objc func likeButtonAction() {
        var str = ""
        if self.currentVideo!.liked {
            self.rootRef.child("urls").child(self.currentVideo!.id).child("likes").child(self.currentUser).removeValue()
            self.currentVideo!.liked = false
            self.currentVideo!.likes -= 1
            str.append("👎")
        } else {
            self.rootRef.child("urls").child(self.currentVideo!.id).child("likes").updateChildValues([self.currentUser: "1"])
            self.currentVideo!.liked = true
            self.currentVideo!.likes += 1
            str.append("👍")
        }
        
        str.append(" " + self.currentVideo!.name)
        let attStr = NSAttributedString(string: str)
        self.likeButton?.setAttributedTitle(attStr, for: UIControl.State.normal)
        self.likeCountLabel!.text = String(currentVideo!.likes)
    }
    
    @objc func nextVideo() {
        if self.currentVideoIndex != nil {
            if self.currentVideoIndex!+1 < self.videoPlayList.count {
                self.currentVideoIndex! += 1
            } else {
                self.currentVideoIndex = 0
            }
            
            self.currentVideo = self.videoPlayList[self.currentVideoIndex!]
            self.displayCurrentVideo()
        }
        
        
    }
    
    @objc func restartVideo() {
        if self.currentVideo != nil {
            self.playerLayer.player!.seek(to: CMTime.zero)
        }
    }
    
    @objc func backButtonAction() {
        if self.playerLayer.player != nil {
            self.playerLayer.player!.pause()
        }
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func displayCurrentVideo() {
        if self.currentVideo != nil {
            
            self.rootRef.child("seen").child(self.currentUser).updateChildValues([self.currentVideo!.id : "1"])
                        
            let player = AVPlayer(url: URL(string: self.currentVideo!.url)!)
            self.playerLayer.player = player
            self.playerLayer.player!.play()
            var str = ""
            if (self.currentVideo!.liked) {
                str.append("👍")
            } else {
                str.append("👎")
            }
            str.append(" " + self.currentVideo!.name)
            if self.likeButton != nil && self.likeCountLabel != nil {
                let attStr = NSAttributedString(string: str)
                self.likeButton!.setAttributedTitle(attStr, for: UIControl.State.normal)
                self.likeCountLabel!.text = String(self.currentVideo!.likes)
            } else {
                let attStr = NSAttributedString(string: str)
                self.likeButton = UIButton()
                self.likeButton!.setAttributedTitle(attStr, for: UIControl.State.normal)
                let likeButtonFrame = CGRect(x: 40, y: self.view.frame.height - 50, width: 250, height: 30)
                self.likeButton!.contentHorizontalAlignment = .left
                self.likeButton!.layer.borderWidth = 0
                self.likeButton!.frame = likeButtonFrame
                self.likeButton!.addTarget(self, action: #selector(likeButtonAction), for: .touchUpInside)
                self.view.addSubview(likeButton!)
                
                self.likeCountLabel = UILabel()
                let likeCountLabelFrame = CGRect(x: self.view.frame.width - 90, y: self.view.frame.height - 50, width: 50, height: 30)
                self.likeCountLabel!.text = String(self.currentVideo!.likes)
                self.likeCountLabel!.textAlignment = .right
                self.likeCountLabel!.textColor = UIColor.white
                self.likeCountLabel!.layer.borderWidth = 0
                self.likeCountLabel!.frame = likeCountLabelFrame
                self.view.addSubview(self.likeCountLabel!)
            }
        }
    }
}


class PlayerView: UIView {
    
    override func layoutSublayers(of layer: CALayer) {
        for currentSublayer in layer.sublayers! {
            if currentSublayer is AVPlayerLayer {
                (currentSublayer as! AVPlayerLayer).frame = self.frame
                (currentSublayer as! AVPlayerLayer).videoGravity = AVLayerVideoGravity.resizeAspectFill
            }
        }
        
        for currentSubview in subviews {
            if currentSubview is UIButton {
                (currentSubview as! UIButton).frame = CGRect(x: 40, y: self.frame.height - 50, width: 250, height: 30)
            } else if currentSubview is UILabel {
                (currentSubview as! UILabel).frame = CGRect(x: self.frame.width - 90, y: self.frame.height - 50, width: 50, height: 30)
            } else if currentSubview is UIImageView {
                (currentSubview as! UIImageView).frame = CGRect(x: self.frame.width/2 - 100, y: self.frame.height/2 - 100, width: 200, height: 200)
            } else {
                print("Subview is unexpected.")
            }
        }
    }
}
