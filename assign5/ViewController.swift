//
//  ViewController.swift
//  assign5
//
//  Created by Kevin Nogales on 5/7/20.
//  Copyright © 2020 Kevin Nogales. All rights reserved.
//

import UIKit
import FirebaseDatabase

class MainController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let root = Database.database().reference()
        root.child("urls").childByAutoId().setValue(["name": "Neo romps happily in the snow", "url": "https://sedna.cs.umd.edu/436clips/vids/neo.mp4"])

    }


}

