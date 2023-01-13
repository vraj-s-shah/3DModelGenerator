//
//  ModelResponse.swift
//  3DModelGenerator
//
//  Created by Vraj Shah on 08/01/23.
//

import Foundation

/// Data holder for model response received from firebase
struct ModelResponse: Codable {
    var name: String
    var url: String
}//End of struct
