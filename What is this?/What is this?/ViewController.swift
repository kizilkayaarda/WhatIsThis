//
//  ViewController.swift
//  What is this?
//
//  Created by Cemal Arda KIZILKAYA on 12.11.2018.
//  Copyright © 2018 Cemal Arda KIZILKAYA. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setting up the imagePicker
        imagePicker.delegate = self
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // getting the photo taken by the user and pass it to the model
        if let pickedImage = info[.editedImage] as? UIImage {
            imageView.image = pickedImage
            
            guard let ciimage = CIImage(image: pickedImage) else {
                fatalError("Could not convert UIImage to CIImage")
            }
            
            detectIn(image: ciimage)
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }

    // a function to perform image classification requests
    func detectIn(image : CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Could not initialize model")
        }
        
        // getting the results of the image classification request and updating the UI with the most confident result
        let request = VNCoreMLRequest(model: model) { (request, error) in
            
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Could not process image")
            }
            
            if let result = results.first {
                self.navigationItem.title = result.identifier
            }
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        // handling the image classification request
        do {
            try handler.perform([request])
        } catch {
            print("Error performing request")
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
        
    }
    
}

