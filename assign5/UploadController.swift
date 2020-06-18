//
//  Record.swift
//  assign5
//
//  Created by Kevin Nogales on 5/14/20.
//  Copyright © 2020 Kevin Nogales. All rights reserved.
//

import UIKit
import MobileCoreServices
import FirebaseDatabase
import FirebaseStorage

class UploadController: UIViewController {
    var pickedURL: URL?
    
    var root: DatabaseReference!
    var storageRef: StorageReference!


    @IBOutlet var chooseFileLogo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        root = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        self.view.layer.backgroundColor = UIColor(hexString: "4F6367")!.cgColor
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: "7A9E9F")
        
        let singleChooseFileTap = UITapGestureRecognizer(target: self, action: #selector(self.chooseFileAction))
        self.chooseFileLogo.isUserInteractionEnabled = true
        self.chooseFileLogo.addGestureRecognizer(singleChooseFileTap)
    }
    
    
    
    @objc func chooseFileAction() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeMPEG4 as String], in: .import)
        
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    func uploadVideo() {
        
        guard let uploadVideoURL = self.pickedURL
            else {
                print("No upload video picked.")
                return
        }

        print("Uploading video: ")
        print(uploadVideoURL)

        let videoRef = self.storageRef.child("videos/\(uploadVideoURL.lastPathComponent)")
        
        _ = videoRef.putFile(from: uploadVideoURL, metadata: nil, completion: { (metadata, error) in
            if error == nil {
                print("Successfully uploaded file.")
                videoRef.downloadURL(completion: { (url, error) in
                
                    // Upload data into database.
                    let alert = UIAlertController(title: "Upload successful.", message: "Enter name:", preferredStyle: .alert)
                    alert.addTextField(configurationHandler: { (textfield) in
                        textfield.text = String(uploadVideoURL.lastPathComponent.split(separator: ".")[0])
                    })
                    
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in
                        
                        self.dismiss(animated: true, completion: {
                            print("Dismissed and saved!")
                            let urlName = url!.absoluteString
                            let name = alert.textFields![0].text!.replacingOccurrences(of: " ", with: "_")
                            
                            
                            self.root.child("urls").childByAutoId().setValue(["name": name, "url": urlName], withCompletionBlock: { (error, ref) in
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
                            
                            
                            
                        })
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                })
            } else {
                print("Upload failed.")
                print(error?.localizedDescription ?? "Error")
            }
        })
    }
    
    
    func backAction(_ : UIAlertAction) -> Void {
        navigationController?.popViewController(animated: true)
    }
    
    
    
    
   
    
}

extension UploadController: UIDocumentPickerDelegate {
    
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else {
            return
        }
        
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let sandboxFileURL = dir.appendingPathComponent(selectedFileURL.lastPathComponent)
        
        if FileManager.default.fileExists(atPath: sandboxFileURL.path) {
            print("Already exists.")
            do {
                let newURL = try FileManager.default.replaceItemAt(sandboxFileURL, withItemAt: selectedFileURL)
                print("Replaced file!")
                self.pickedURL = newURL
                self.uploadVideo()
            } catch {
                self.pickedURL = nil
                print("Failed to replace file.")
                print("Error \(error)")
            }
        } else {
            
            do {
                try FileManager.default.copyItem(at: selectedFileURL, to: sandboxFileURL)
                print("Copied file!")
                self.pickedURL = sandboxFileURL
                self.uploadVideo()
            } catch {
                self.pickedURL = nil
                print("Failed to copy file.")
                print("Error: \(error)")
            }
        }
    }
}
