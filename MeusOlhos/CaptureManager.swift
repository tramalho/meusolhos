//
//  CaptureManager.swift
//  MeusOlhos
//
//  Created by Thiago Antonio Ramalho on 26/01/21.
//  Copyright © 2021 Eric Brito. All rights reserved.
//

import Foundation
import AVKit

class CaptureManager {
    
    private static var CAMERA_QUEUE = "CAMERA_QUEUE"
    
    private lazy var captureSession: AVCaptureSession = {
       let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        return captureSession
    }()
    
    weak var videoBufferDelegate: AVCaptureVideoDataOutputSampleBufferDelegate?
    
    init() {
        
    }
    
    func startCameraCapture() -> AVCaptureVideoPreviewLayer? {
        
        var previewLayer: AVCaptureVideoPreviewLayer? = nil
        
        if hasPermission(), let captureDevice = AVCaptureDevice.default(for: .video) {
            do {
                
                let input = try AVCaptureDeviceInput(device: captureDevice)
                captureSession.addInput(input)
                captureSession.startRunning()
                
                let videoDataOutput = AVCaptureVideoDataOutput()
                videoDataOutput.setSampleBufferDelegate(videoBufferDelegate, queue: DispatchQueue(label: CaptureManager.CAMERA_QUEUE))
                
                captureSession.addOutput(videoDataOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return previewLayer
    }
    
    private func hasPermission() -> Bool {
        var hasPermission = false
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            hasPermission = true
        case .denied:
            hasPermission = false
        case .restricted:
            hasPermission = false
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (result) in
                hasPermission = result
            }
        }
        
        return hasPermission
    }
    
}
