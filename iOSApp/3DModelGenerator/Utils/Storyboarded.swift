//
//  Storyboarded.swift
//  3DModelGenerator
//
//  Created by Vraj Shah on 03/01/23.
//

import UIKit

/// Storyboarded
protocol Storyboarded {
    static func instantiate(from storyboard: Storyboard) -> Self
}

//MARK: -
//MARK: - Storyboarded extension to return view controller

extension Storyboarded where Self: UIViewController {
    
    /// Instantiate
    static func instantiate(from storyboard: Storyboard) -> Self {
        let fullName = NSStringFromClass(self)
        let className = fullName.components(separatedBy: ".")[1]
        let storyboard = UIStoryboard(name: storyboard.rawValue, bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: className) as! Self // swiftlint:disable:this force_cast
    }
    
    /// Run on main thread
    internal func onMain(block: @escaping () -> Void) {
        DispatchQueue.main.async {
            block()
        }
    }
    
    /// Run on background thread
    internal func onBackground(block: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).async {
            block()
        }
    }
    
} // End Of Extension

/// Storyboards
enum Storyboard: String {
    case main = "Main"
}
