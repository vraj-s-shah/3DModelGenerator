//
//  main.swift
//  ImagesTo3DModel
//
//  Created by Vraj Shah on 01/01/23.
//

import Foundation
import RealityKit
import FirebaseCore
import FirebaseDatabase

private var numberOfImagesSaved: Int = 0

if #available(macOS 12.0, *) {
    FirebaseApp.configure()
    startObservingData()
    RunLoop.main.run()
} else {
    print("Requires minimum macOS 12.0!")
    Foundation.exit(0)
}

//MARK: -
//MARK: - Private functions

private func startObservingData() {
    firebaseHelper.observeObjectDataChanges { snapshot in
        for objectSnapshot in snapshot.children {
            guard let objectSnapshot = objectSnapshot as? DataSnapshot else { return }
            let objectName = objectSnapshot.key
            let totalImages = Int(objectSnapshot.childrenCount)
            numberOfImagesSaved = 0
            firebaseHelper.checkIfModelAlreadyGenerated(objectName: objectName) { isGenerated in
                guard !isGenerated else { return }
                var imageCount = 1
                for imageSnapshot in objectSnapshot.children {
                    guard let imageSnapshot = imageSnapshot as? DataSnapshot else { return }
                    guard let image: ImageResponse = imageSnapshot.getData() else { return }
                    downloadImage(ImageAttributes(url: image.url, name: objectName, number: imageCount), totalImages) {
                        generateModel(objectName)
                    }
                    imageCount += 1
                }
            }
        }
    }
}

private func downloadImage(_ imageAttributes: ImageAttributes, _ totalImages: Int, _ onAllImagesSaved: @escaping () -> Void) {
    guard let url = URL(string: imageAttributes.url) else { return }
    URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
        guard error == nil else { return }
        guard let data = data else { return }
        guard fileManagerHelper.createDirectory(url: getObjectDirectory(imageAttributes.name)) else { return }
        guard fileManagerHelper.writeDataToFile(data: data,
                                                url: getImageFileUrl(imageAttributes.name, imageAttributes.number)) else {
            return
        }
        numberOfImagesSaved += 1
        if numberOfImagesSaved == totalImages {
            onAllImagesSaved()
        }
    }.resume()
}

private func generateModel(_ name: String) {
    let modelGenerator = ModelGenerator(getObjectDirectory(name), getOutputFileUrl(name))
    modelGenerator.generateModel()
    modelGenerator.onModelGenerated = {
        if let data = try? Data(contentsOf: getOutputFileUrl(name)) {
            firebaseHelper.uploadModelFile(objectName: name, data: data) {
                print("Model(\(name)) can now be used in mobile application")
            }
        }
    }
}

//MARK: -
//MARK: - Getter functions

private func getObjectDirectory(_ name: String) -> URL {
    fileManagerHelper.documentsDirectory
        .appendingPathComponent("Models")
        .appendingPathComponent(name)
}

private func getImageFileUrl(_ name: String, _ imageCount: Int) -> URL {
    getObjectDirectory(name)
        .appendingPathComponent("\(name)\(imageCount)")
        .appendingPathExtension("HEIC")
}

private func getOutputFileUrl(_ name: String) -> URL {
    getObjectDirectory(name)
        .appendingPathComponent(name)
        .appendingPathExtension("usdz")
}
