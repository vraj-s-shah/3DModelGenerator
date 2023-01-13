//
//  ViewController.swift
//  3DModelGenerator
//
//  Created by Vraj Shah on 01/01/23.
//

import UIKit
import RealityKit
import ARKit

/// View controller responsible for displaying 3d models on real world by the means of AR
class DemonstrateModelViewController: UIViewController, Storyboarded {
    
    //MARK: -
    //MARK: - Variables
    
    var coordinator: HomeCoordinator?
    private var selectedModel: Model?
    private var modelList: [Model] = []
    private let numberOfComponentsInPickerView = 1
    
    //MARK: -
    //MARK: - Outlets
    
    @IBOutlet var arView: ARView!
    @IBOutlet weak var modelPickerView: UIPickerView!
    @IBOutlet weak var modelLoader: UIActivityIndicatorView!
    
    //MARK: -
    //MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupArView()
        initView()
    }
    
    //MARK: -
    //MARK: - IBActions
    
    @IBAction func addModelAction(_ sender: Any) {
        guard let selectedModel = selectedModel else { return }
        addModel(model: selectedModel)
    }
    
    //MARK: -
    //MARK: - Private functions
    
    private func initView() {
        modelLoader.isHidden = false
        modelPickerView.layer.cornerRadius = 5.0
        fetchModels()
    }
    
    private func setupArView() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            configuration.sceneReconstruction = .mesh
        }
        arView.session.run(configuration)
    }
    
    private func fetchModels() {
        firebaseHelper.fetchModelsFromFirebase(completion: { [weak self] models in
            guard let self = self else { return }
            self.onMain {
                self.modelLoader.isHidden = true
                self.modelList = models
                self.selectedModel = models.first
                self.modelPickerView.reloadAllComponents()
            }
        }, onModelsEmpty: { [weak self] in
            guard let self = self else { return }
            self.onMain {
                self.modelLoader.isHidden = true
                self.showNoModelFoundDialog() { [weak self] in
                    guard let self = self else { return }
                    self.coordinator?.pop()
                }
            }
        })
    }
    
    private func addModel(model: Model) {
        model.generateEntity { [weak self] entity in
            guard let self = self else { return }
            let anchorEntity = AnchorEntity(plane: .any)
            anchorEntity.addChild(entity)
            self.arView.scene.addAnchor(anchorEntity)
        }
    }
    
    //MARK: -
    //MARK: - Alerts dialog builder functions
    
    private func showNoModelFoundDialog(completion: @escaping () -> Void) {
        let alert = alertDialogBuilder.getDefaultDialog(title: "No models found",
                                                        message: "Please capture photos of some object and try again after sometime to test model",
                                                        onOkPressed: completion)
        present(alert, animated: true)
    }
    
}//End of class

//MARK: -
//MARK: - UIPickerViewDelegate

extension DemonstrateModelViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        modelList[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedModel = modelList[row]
    }
    
}//End of extension

//MARK: -
//MARK: - UIPickerViewDataSource

extension DemonstrateModelViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        numberOfComponentsInPickerView
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        modelList.count
    }
    
}//End of extension
