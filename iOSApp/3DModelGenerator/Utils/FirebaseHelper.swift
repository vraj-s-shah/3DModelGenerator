//
//  TakePhotosViewModel.swift
//  3DModelGenerator
//
//  Created by Vraj Shah on 04/01/23.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

let firebaseHelper = FirebaseHelper.shared

/// Helper class for firebase functionalitites
internal class FirebaseHelper {
    
    //MARK: -
    //MARK: - Variables
    
    private let databaseReference = Database.database().reference()
    private let storageReference = Storage.storage().reference()
    private let objectsKey = "Objects"
    private let modelsKey = "Models"
    
    //MARK: -
    //MARK: - Singleton object provider
    
    private struct Static {
        static let instance = FirebaseHelper()
    }
    
    class var shared: FirebaseHelper {
        return Static.instance
    }
    
    //MARK: -
    //MARK: - Public functions
    
    func uploadAllImages(objectName: String, imagesData: [Image], completion: @escaping () -> Void) {
        imagesData.enumerated().forEach { index, image in
            uploadImage(objectName: objectName, image: image) {
                if index == imagesData.count - 1 {
                    completion()
                }
            }
        }
    }
    
    func uploadImage(objectName: String, image: Image, completion: @escaping () -> Void) {
        let storage = storageReference
            .child(objectsKey)
            .child(objectName)
            .child(image.name)
        storage.putData(image.data, metadata: nil) { metadata, error in
            guard metadata != nil else { return }
            storage.downloadURL { [weak self] url, error in
                guard let self = self else { return }
                guard let downloadURL = url else { return }
                self.databaseReference
                    .child(self.objectsKey)
                    .child(objectName)
                    .childByAutoId()
                    .child("url")
                    .setValue(downloadURL.absoluteString)
                completion()
            }
        }
    }
    
    func checkIfModelAlreadyGenerated(objectName: String, onGenerated: @escaping (Bool) -> Void) {
        databaseReference.child(modelsKey).observeSingleEvent(of: .value) { dataSnapshot in
            dataSnapshot.children.forEach { modelSnapshot in
                guard let modelSnapshot = modelSnapshot as? DataSnapshot else { return }
                guard let model: ModelResponse = modelSnapshot.getData() else { return }
                if model.name == objectName {
                    onGenerated(true)
                    return
                }
            }
            onGenerated(false)
        }
    }
    
    func fetchModelsFromFirebase(completion: @escaping ([Model]) -> Void, onModelsEmpty: @escaping () -> Void) {
        databaseReference.child(modelsKey).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            guard Int(snapshot.childrenCount) >= 1 else {
                onModelsEmpty()
                return
            }
            self.processModelResponses(snapshot, completion)
        }
    }
    
    //MARK: -
    //MARK: - Private functions
    
    private func processModelResponses(_ snapshot: DataSnapshot, _ completion: @escaping ([Model]) -> Void) {
        var models: [Model] = []
        var modelsFetched = 0
        snapshot.children.forEach { modelSnapshot in
            guard let modelJson = modelSnapshot as? DataSnapshot else { return }
            guard let modelResponse: ModelResponse = modelJson.getData() else { return }
            modelsFetched += 1
            if fileManagerHelper.fileExists(url: getModelDirectory(modelResponse.name)) {
                models.append(Model(name: modelResponse.name, fileUrl: getModelFileUrl(modelResponse.name)))
                if modelsFetched == Int(snapshot.childrenCount) {
                    completion(models)
                }
            } else {
                downloadModelFile(modelResponse) { model in
                    models.append(model)
                    if modelsFetched == Int(snapshot.childrenCount) {
                        completion(models)
                    }
                }
            }
        }
    }
    
    private func downloadModelFile(_ modelResponse: ModelResponse, _ completion: @escaping (Model) -> Void) {
        guard let url = URL(string: modelResponse.url) else { return }
        URLSession.shared.dataTask(with: URLRequest(url: url)) { [weak self] data, response, error in
            guard error == nil else { return }
            guard let data = data else { return }
            guard let self = self else { return }
            let fileUrl = self.getModelFileUrl(modelResponse.name)
            guard fileManagerHelper.createDirectory(url: self.getModelDirectory(modelResponse.name)) else { return }
            guard fileManagerHelper.writeDataToFile(data: data, url: fileUrl) else { return }
            completion(Model(name: modelResponse.name, fileUrl: fileUrl))
        }.resume()
    }
    
    //MARK: -
    //MARK: - Getter functions
    
    private func getModelDirectory(_ name: String) -> URL {
        fileManagerHelper.documentsDirectory
            .appendingPathComponent("Models")
            .appendingPathComponent(name)
    }
    
    private func getModelFileUrl(_ name: String) -> URL {
        getModelDirectory(name)
            .appendingPathComponent(name)
            .appendingPathExtension("usdz")
    }
    
}//End of class

//MARK: -
//MARK: - DataSnapshot extension

extension DataSnapshot {
    
    func getData<T: Codable>() -> T? {
        guard let json = self.value else { return nil }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json,
                                                          options: .prettyPrinted) else { return nil }
        guard let data = try? JSONDecoder().decode(T.self, from: jsonData) else { return nil }
        return data
    }
    
}//End of extension
