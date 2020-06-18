//
//  URLController.swift
//  assign5
//
//  Created by Kevin Nogales on 5/8/20.
//  Copyright © 2020 Kevin Nogales. All rights reserved.
//

import UIKit
import FirebaseDatabase

class URLController: UIViewController {
    
    var root: DatabaseReference!
    @IBOutlet var nameTextFieldOutlet: UITextField!
    @IBOutlet var urlTextFieldOutlet: UITextField!
    @IBOutlet var uploadButtonOutlet: UIButton!
    
    @IBAction func uploadAction(_ sender: Any) {
        if nameTextFieldOutlet.text! == "" && urlTextFieldOutlet.text! == "" {
            let alert = UIAlertController(title: "Error!", message: "Please fill in Name and URL.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
        } else if nameTextFieldOutlet.text! == "" {
            let alert = UIAlertController(title: "Error!", message: "Please fill in Name.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
        } else if urlTextFieldOutlet.text! == "" {
            let alert = UIAlertController(title: "Error!", message: "Please fill in URL.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
        } else {
            self.root.child("urls").childByAutoId().setValue(["name": nameTextFieldOutlet.text!, "url": urlTextFieldOutlet.text!], withCompletionBlock: { (error, ref) in
                if error == nil {
                    let alert = UIAlertController(title: "Success!", message: "Uploading data was successful.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: self.backAction(_:)))
                    self.present(alert, animated: true)
                } else {
                    let alert = UIAlertController(title: "Error!", message: "Error uploading data. Please try again later.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: self.backAction(_:)))
                    self.present(alert, animated: true)
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        root = Database.database().reference()
        //root.child("urls").childByAutoId().setValue(["name": "Neo romps happily in the snow", "url": "https://sedna.cs.umd.edu/436clips/vids/neo.mp4"])
        self.view.layer.backgroundColor = UIColor(hexString: "4F6367")!.cgColor
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: "7A9E9F")
        self.uploadButtonOutlet.layer.cornerRadius = 5
    }
    func backAction(_ : UIAlertAction) -> Void {
        navigationController?.popViewController(animated: true)
    }
    

}
