//
//  FirebaseHelper.swift
//  ImagesTo3DModel
//
//  Created by Vraj Shah on 06/01/23.
//

import Foundation
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
    
    func observeObjectDataChanges(configuration: @escaping (DataSnapshot) -> Void) {
        databaseReference.child(objectsKey).observe(.value) { object in
            configuration(object)
        }
    }
    
    func checkIfModelAlreadyGenerated(objectName: String, onGenerated: @escaping (Bool) -> Void) {
        databaseReference.child(modelsKey).observeSingleEvent(of: .value) { dataSnapshot in
            dataSnapshot.children.forEach { modelSnapshot in
                guard let modelSnapshot = modelSnapshot as? DataSnapshot else { return }
                guard let model: Model = modelSnapshot.getData() else { return }
                if model.name == objectName {
                    onGenerated(true)
                    return
                }
            }
            onGenerated(false)
        }
    }
    
    func uploadModelFile(objectName: String, data: Data, completion: @escaping () -> Void) {
        let storage = storageReference
            .child(modelsKey)
            .child(objectName.toUsdzExtension())
        storage.putData(data, metadata: nil) { metadata, error in
            guard metadata != nil else { return }
            storage.downloadURL { [weak self] url, error in
                guard error == nil else { return }
                guard let url = url else { return }
                guard let self = self else { return }
                self.databaseReference
                    .child(self.modelsKey)
                    .childByAutoId()
                    .setValue(Model(name: objectName, url: url.absoluteString).toDictionary)
                self.removeObjectData(name: objectName)
                completion()
            }
        }
    }
    
    func removeObjectData(name: String) {
        storageReference
            .child(objectsKey)
            .child(name)
            .listAll { result, error in
                guard error == nil else { return }
                result?.items.forEach { reference in
                    reference.delete { [weak self] error in
                        guard error != nil else { return }
                        guard let self = self else { return }
                        self.databaseReference
                            .child(self.objectsKey)
                            .child(name)
                            .removeValue()
                    }
                }
            }
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

//MARK: -
//MARK: - String extension

extension String {
    
    func toUsdzExtension() -> String {
        "\(self).usdz"
    }
    
}//End of extension
