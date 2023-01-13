//
//  AlertDialogBuilder.swift
//  3DModelGenerator
//
//  Created by Vraj Shah on 05/01/23.
//

import UIKit

let alertDialogBuilder = AlertDialogBuilder.shared

/// Helper class for displaying alert dialog of different types
internal class AlertDialogBuilder {
    
    //MARK: -
    //MARK: - Singleton object provider
    
    private struct Static {
        static let instance = AlertDialogBuilder()
    }
    
    class var shared: AlertDialogBuilder {
        return Static.instance
    }
    
    //MARK: -
    //MARK: - Public functions
    
    func getDefaultDialog(title: String, message: String, onOkPressed: (() -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in
            onOkPressed?()
        })
        return alert
    }
    
    func getSingleTextFieldDialog(title: String,
                                  message: String?,
                                  textFieldConfiguration: ((UITextField) -> Void)? = nil,
                                  completion: @escaping (String?) -> Void) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { textField in
            textFieldConfiguration?(textField)
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            if let textField = alert.textFields?.first {
                guard let text = textField.text else {
                    completion(nil)
                    return
                }
                completion(text.isEmpty ? nil : text)
            }
        }))
        return alert
    }
    
}//End of class
