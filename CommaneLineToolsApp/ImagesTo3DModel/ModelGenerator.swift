//
//  ModelGenerator.swift
//  ImagesTo3DModel
//
//  Created by Vraj Shah on 08/01/23.
//

import Foundation
import RealityKit

/// Class responsible to convertting bunch of images into 3d model
class ModelGenerator {
    
    //MARK: -
    //MARK: - Typealias
    
    private typealias Configuration = PhotogrammetrySession.Configuration
    private typealias Request = PhotogrammetrySession.Request
    
    //MARK: -
    //MARK: - Variables
    
    var inputFolderPath: URL
    var outputFilePath: URL
    var onModelGenerated: (() -> Void)?
    
    //MARK: -
    //MARK: - Initialization
    
    init(_ inputFolderPath: URL, _ outputFilePath: URL) {
        self.inputFolderPath = inputFolderPath
        self.outputFilePath = outputFilePath
    }
    
    //MARK: -
    //MARK: - Generate model
    
    func generateModel() {
        guard let session = checkAndProvideSession() else { return }
        
        let waiter = Task {
            do {
                for try await output in session.outputs {
                    switch output {
                    case .requestComplete(let request, let result):
                        handleRequestComplete(request: request, result: result)
                    case .requestProgress(_, let fractionComplete):
                        handleRequestProgress(progress: fractionComplete)
                    default:
                        print("Output: unhandled message: \(output.localizedDescription)")
                    }
                }
            } catch {
                print("Error getting output: \(error)")
            }
        }
        
        withExtendedLifetime((session, waiter)) {
            do {
                try session.process(requests: [ Request.modelFile(url: outputFilePath, detail: .raw) ])
                
            } catch {
                print("Error creating request: \(error)")
            }
        }
    }
    
    //MARK: -
    //MARK: - Private functions
    
    private func checkAndProvideSession() -> PhotogrammetrySession? {
        guard PhotogrammetrySession.isSupported else {
            print("Device does not support converting images to model")
            return nil
        }
        var session: PhotogrammetrySession? = nil
        do {
            var configuration = Configuration()
            configuration.sampleOrdering = .unordered
            configuration.featureSensitivity = .high
            session = try PhotogrammetrySession(input: inputFolderPath, configuration: configuration)
        } catch {
            print("Error creating session: \(error)")
        }
        guard let requiredSession = session else {
            print("Error creating session")
            return nil
        }
        return requiredSession
    }
    
    private func handleRequestComplete(request: PhotogrammetrySession.Request, result: PhotogrammetrySession.Result) {
        switch result {
        case .modelFile(let url):
            onModelGenerated?()
            print("\tRequest complete: \(String(describing: request))\nModelFile available at url=\(url)")
        default:
            print("\tUnexpected result: \(String(describing: result))")
        }
    }
    
    private func handleRequestProgress(progress: Double) {
        let percentComplete = lround(progress * 100)
        if percentComplete.isMultiple(of: 10) {
            print("Progress = \(percentComplete)%")
        }
    }
    
}//End of class
