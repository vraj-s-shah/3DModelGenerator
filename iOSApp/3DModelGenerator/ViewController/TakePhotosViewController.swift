//
//  TakePhotosViewController.swift
//  3DModelGenerator
//
//  Created by Vraj Shah on 03/01/23.
//

import UIKit
import AVFoundation

/// View controller responsible for taking images for some object and send to the server
class TakePhotosViewController: UIViewController, Storyboarded {

    //MARK: -
    //MARK: - Outlets
    
    @IBOutlet weak var numberOfPhotosLabel: UILabel!
    @IBOutlet weak var waitingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var captureButton: UIButton!
    
    //MARK: -
    //MARK: - Variables
    
    var coordinator: HomeCoordinator?
    var objectName: String = "" {
        didSet {
            self.title = objectName
        }
    }
    private var numberOfPhotos = 0
    private var imagesData: [Image] = []
    private let photoOutput = AVCapturePhotoOutput()
    private let captureSession = AVCaptureSession()
    private let flashView = UIView()
    private var cameraLayer: AVCaptureVideoPreviewLayer?
    
    //MARK: -
    //MARK: - UIViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        checkAndOpenCamera()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        updateOnDeviceRotated()
    }
    
    //MARK: -
    //MARK: - IBActions
    
    @IBAction func capturePhotoAction(_ sender: Any) {
        capturePhoto()
    }
    
    @IBAction func uploadImagesAction(_ sender: Any) {
        uploadImages()
    }
    
    //MARK: -
    //MARK: - Private functions
    
    private func initView() {
        self.navigationController?.navigationBar.barStyle = .default
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        updateOnModelGenerationState(for: .capturingImages)
        numberOfPhotosLabel.layer.masksToBounds = true
        numberOfPhotosLabel.layer.cornerRadius = numberOfPhotosLabel.frame.height / 2
        flashView.frame = self.view.frame
        flashView.alpha = 0
        flashView.backgroundColor = UIColor.black
        self.view.addSubview(flashView)
    }
    
    private func uploadImages() {
        guard numberOfPhotos >= 20 else {
            showMoreImagesRequiredDialog()
            return
        }
        updateOnModelGenerationState(for: .uploadingImages)
        firebaseHelper.uploadAllImages(objectName: objectName, imagesData: imagesData) { [weak self] in
            guard let self = self else { return }
            self.updateOnModelGenerationState(for: .imagesUploadSuccess)
        }
    }
    
    private func updateOnDeviceRotated() {
        let newFrame = CGRect(x: 0, y: 0, width: view.frame.height, height: view.frame.width)
        if let cameraLayer = cameraLayer, let connection = cameraLayer.connection {
            let orientation = UIDevice.current.orientation
            if connection.isVideoOrientationSupported,
               let videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue) {
                cameraLayer.frame = newFrame
                connection.videoOrientation = videoOrientation
            }
        }
        flashView.frame = newFrame
    }
    
    private func updateOnModelGenerationState(for state: ModelGeneratingStates) {
        switch state {
        case .capturingImages, .imagesUploadSuccess:
            waitingIndicator.isHidden = true
            captureButton.isEnabled = true
            if state == .imagesUploadSuccess {
                showImagesUploadSuccessDialog() { [weak self] in
                    guard let self = self else { return }
                    self.coordinator?.pop()
                }
            }
        case .uploadingImages:
            waitingIndicator.isHidden = false
            captureButton.isEnabled = false
        }
    }
    
    //MARK: -
    //MARK: - Camera functions
    
    private func checkAndOpenCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.setupCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let self = self else { return }
                granted ? self.setupCaptureSession() : self.coordinator?.pop()
            }
        case .denied:
            coordinator?.pop()
        case .restricted:
            coordinator?.pop()
        default:
            coordinator?.pop()
        }
    }
    
    private func setupCaptureSession() {
        if let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) {
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }
            } catch let error {
                print("Failed to set input device with error: \(error)")
            }
            
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            
            cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            guard let cameraLayer = cameraLayer else { return }
            cameraLayer.frame = self.view.frame
            cameraLayer.videoGravity = .resizeAspectFill
            self.view.layer.insertSublayer(cameraLayer, at: 0)
            onBackground {
                self.captureSession.startRunning()
            }
        }
    }
    
    private func capturePhoto() {
        let photoSettings = AVCapturePhotoSettings()
        if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                self.flashView.alpha = 1
            }, completion: { isCompleted in
                self.flashView.alpha = 0
            })
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    //MARK: -
    //MARK: - Getter functions
    
    private func getImageName() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .medium
        return "\(formatter.string(from: Date())).jpeg"
    }
    
    //MARK: -
    //MARK: - Alerts dialog builder functions
    
    private func showMoreImagesRequiredDialog() {
        let alert = alertDialogBuilder.getDefaultDialog(title: "More images required",
                                                        message: "Minimum number of images required is 20")
        present(alert, animated: true)
    }
    
    private func showImagesUploadSuccessDialog(completion: @escaping () -> Void) {
        let alert = alertDialogBuilder.getDefaultDialog(title: "Images uploaded successfully",
                                                        message: "Model will be shortly available in test model activity",
                                                        onOkPressed: completion)
        
        present(alert, animated: true)
    }

}//End of class

//MARK: -
//MARK: - AVCapturePhotoCaptureDelegate

extension TakePhotosViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        imagesData.append(Image(data: imageData, name: getImageName()))
        numberOfPhotos += 1
        numberOfPhotosLabel.text = String(numberOfPhotos)
    }
    
}//End of extension

/// Enum representing different states of waiting for user
enum ModelGeneratingStates {
    case capturingImages
    case uploadingImages
    case imagesUploadSuccess
}
