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
        
        //let root = Database.database().reference()
        //root.child("urls").childByAutoId().setValue(["name": "Neo romps happily in the snow", "url": "https://sedna.cs.umd.edu/436clips/vids/neo.mp4"])
        //(displayP3Red: 122, green: 158, blue: 159, alpha: 1)
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: "7A9E9F")
        //(displayP3Red: 79, green: 99, blue: 103, alpha: 1).cgColor
        self.view.layer.backgroundColor = UIColor(hexString: "4F6367")!.cgColor
    }


}

extension UIColor {
    convenience init?(hexString: String) {
        var chars = Array(hexString.hasPrefix("#") ? hexString.dropFirst() : hexString[...])
        switch chars.count {
        case 3: chars = chars.flatMap { [$0, $0] }; fallthrough
        case 6: chars = ["F","F"] + chars
        case 8: break
        default: return nil
        }
        self.init(red: .init(strtoul(String(chars[2...3]), nil, 16)) / 255,
                green: .init(strtoul(String(chars[4...5]), nil, 16)) / 255,
                 blue: .init(strtoul(String(chars[6...7]), nil, 16)) / 255,
                alpha: .init(strtoul(String(chars[0...1]), nil, 16)) / 255)
    }
}
