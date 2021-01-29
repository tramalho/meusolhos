//
//  ObjectsViewController.swift
//  MeusOlhos
//
//  Created by Eric Brito
//  Copyright © 2017 Eric Brito. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ObjectsViewController: UIViewController {
    
    @IBOutlet weak var viCamera: UIView!
    @IBOutlet weak var lbIdentifier: UILabel!
    @IBOutlet weak var lbConfidence: UILabel!
    
    private lazy var captureManager: CaptureManager = {
       let captureManager = CaptureManager()
       captureManager.videoBufferDelegate = self
        
        return captureManager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbIdentifier.text = ""
        self.lbConfidence.text = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let previewLayer = captureManager.startCameraCapture() else { return }
        previewLayer.frame = viCamera.bounds
        viCamera.layer.addSublayer(previewLayer)
    }
    
    @IBAction func analyse(_ sender: UIButton) {
    }
}

extension ObjectsViewController : AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let cvPixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        guard let model = try? VNCoreMLModel(for: VGG16().model) else { return }
        
        let request = VNCoreMLRequest(model: model, completionHandler: { (success, error) in
           
            guard let results = success.results as? [VNClassificationObservation] else { return }
            
            guard let firstObservation = results.first else { return }
            
            DispatchQueue.main.async {
                self.lbIdentifier.text = firstObservation.identifier
                let confidence = round(firstObservation.confidence * 1000) / 10
                self.lbConfidence.text = "\(confidence)%"
            }
        })
        
        let imageHandler = VNImageRequestHandler(cvPixelBuffer: cvPixelBuffer, options: [:])
        
        try? imageHandler.perform([request])
    }
}
