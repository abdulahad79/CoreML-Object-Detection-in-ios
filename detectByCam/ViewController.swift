//
//  ViewController.swift
//  detectByCam
//
//  Created by abdul ahad on 02/04/2019.
//  Copyright © 2019 abdul ahad. All rights reserved.
//

import UIKit
import AVKit
import Vision
class ViewController: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
     
        //Camera activation
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
     
        captureSession.addInput(input)
        
        captureSession.startRunning()
    
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame

        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoQueue"))
        captureSession.addOutput(dataOutput)
        

    }
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
     //   print("camera was able to",Date())
        
      
        guard let pixelbuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        guard let model = try? VNCoreMLModel(for: Resnet50 ().model) else { return }
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
         //   print(finishedReq.results)
          
            guard let result = finishedReq.results as? [VNClassificationObservation] else { return }
            
            guard let firstObserve = result.first else { return }
            print(firstObserve.identifier,firstObserve.confidence)
            
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelbuffer, options: [:]).perform([request])
    
    }

}

