//
//  ModelEntity.swift
//  3DModelGenerator
//
//  Created by Vraj Shah on 02/01/23.
//

import Combine
import RealityKit
import UIKit
import QuickLookThumbnailing

/// Class representing a model entity that can be placed in real world by the means of AR
class Model {
    
    //MARK: -
    //MARK: - Variables
    
    let name: String
    let fileUrl: URL
    private var cancellable: AnyCancellable? = nil
    
    //MARK: -
    //MARK: - Initialization
    
    init(name: String, fileUrl: URL) {
        self.name = name
        self.fileUrl = fileUrl
    }
    
    //MARK: -
    //MARK: - Generate entity
    
    func generateEntity(_ completion: @escaping (ModelEntity) -> Void) {
        cancellable = ModelEntity.loadModelAsync(contentsOf: fileUrl)
            .sink(receiveCompletion: { completion in
                print("Cannot create model entity for \(self.name)")
                self.cancellable?.cancel()
            }, receiveValue: { modelEntity in
                completion(modelEntity)
                self.cancellable?.cancel()
            })
    }
    
}//End of class
