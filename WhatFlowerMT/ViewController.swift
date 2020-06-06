//
//  ViewController.swift
//  WhatFlowerMT
//
//  Created by Michael Tang on 2020-06-06.
//  Copyright © 2020 Michael Tang. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    let wikipediaURL = "https://en.wikipedia.org/w/api.php"

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Conversion to CIImage failed")
            }
            detect(image: ciimage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
    guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else {
        fatalError("Loading CoreMLModel Failed")
    }
    let request = VNCoreMLRequest(model: model) { (request, error) in
        guard let results = request.results as? [VNClassificationObservation] else {
            fatalError("Results could not be processed")
        }
        
        if let firstResult = results.first {
            
            self.navigationItem.title = firstResult.identifier.capitalized
            self.requestInfo(flowerName: firstResult.identifier)
        }
        
    }
    
    let handler = VNImageRequestHandler(ciImage: image)
    do {
        try handler.perform([request])
    } catch {
        print(error)
    }
    }
    
    func requestInfo(flowerName: String) {
        
        let parameters : [String:String] = [
        "format" : "json",
        "action" : "query",
        "prop" : "extracts",
        "exintro" : "",
        "explaintext" : "",
        "titles" : flowerName,
        "indexpageids" : "",
        "redirects" : "1",
        ]
        
        Alamofire.request(wikipediaURL, method: .get, parameters: parameters).responseJSON(completionHandler: { (response) in
            if response.result.isSuccess {
                print("Got the wikipedia info")
                print(response)
            }
        })
    }
}

