//
//  HomeViewController.swift
//  3DModelGenerator
//
//  Created by Vraj Shah on 03/01/23.
//

import UIKit

/// View controller representing the home screen shown when app launches
class HomeViewController: UIViewController, Storyboarded {
    
    //MARK: -
    //MARK: - Outlets
    
    @IBOutlet weak var testModelsButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: -
    //MARK: - Variables
    
    var coordinator: HomeCoordinator?
    
    //MARK: -
    //MARK: - UIViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }

    //MARK: -
    //MARK: - IBActions
    
    @IBAction func takePhotosAction(_ sender: Any) {
        showObjectNameInputDialog()
    }
    
    @IBAction func testModelsAction(_ sender: Any) {
        coordinator?.goToDemonstrateModelViewController()
    }
    
    //MARK: -
    //MARK: - Private functions
    
    private func initView() {
        let longPressGestureRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(deleteAllModels))
        testModelsButton.addGestureRecognizer(longPressGestureRecogniser)
    }
    
    @objc private func deleteAllModels() {
        let modelsDirectoryUrl = fileManagerHelper.documentsDirectory
            .appendingPathComponent("Models")
        guard fileManagerHelper.removeDirectory(url: modelsDirectoryUrl) else { return }
        showAllModelsDeletedDialog()
    }
    
    private func checkAndStartTakePhotosViewController(objectName: String) {
        activityIndicator.isHidden = false
        firebaseHelper.checkIfModelAlreadyGenerated(objectName: objectName) { [weak self] isGenerated in
            guard let self = self else { return }
            self.activityIndicator.isHidden = true
            guard !isGenerated else {
                self.showObjectAlreadyGeneratedDialog()
                return
            }
            self.coordinator?.goToTakePhotosViewController(objectName: objectName)
        }
    }
    
    //MARK: -
    //MARK: - Alert dialog builder functions
    
    private func showAllModelsDeletedDialog() {
        let alert = alertDialogBuilder.getDefaultDialog(title: "Deleted",
                                            message: "All models stored locally have been removed from the device")
        present(alert, animated: true)
    }
    
    private func showObjectAlreadyGeneratedDialog() {
        let alert = alertDialogBuilder.getDefaultDialog(title: "Object already generated",
                                                        message: "Please use different name for the object to create new mmodel")
        present(alert, animated: true)
    }
    
    private func showObjectNameInputDialog() {
        let alert = alertDialogBuilder.getSingleTextFieldDialog(title: "Enter object name",
                                                                message: nil) { textField in
            textField.placeholder = "Object name"
            textField.autocapitalizationType = .words
        } completion: { [weak self] text in
            guard let self = self else { return }
            guard let text = text?.components(separatedBy: .whitespaces).joined() else { return }
            self.checkAndStartTakePhotosViewController(objectName: text)
        }
        present(alert, animated: true)
    }
    
}//End of class
