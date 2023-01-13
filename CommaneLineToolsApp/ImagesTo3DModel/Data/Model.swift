//
//  ModelResponse.swift
//  ImagesTo3DModel
//
//  Created by Vraj Shah on 08/01/23.
//

import Foundation

/// Data holder struct for saving and fetching model data from firebase
struct Model: Codable {
    var name: String
    var url: String
    
    var toDictionary: [String: String] {
        return [
            "name": name,
            "url": url
        ]
    }
}//End of struct
