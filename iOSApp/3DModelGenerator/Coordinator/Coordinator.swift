//
//  Coordinator.swift
//  3DModelGenerator
//
//  Created by Vraj Shah on 03/01/23.
//

import UIKit

/// Protocol defining the coordinator pattern to navigate between view controllers
protocol Coordinator {
    
    var navController: UINavigationController { get set }
    func start()
    func push(_ viewController: UIViewController)
    func pop()
    func popToRoot()
    
}//End of protocool

//MARK: -
//MARK: - Coordinator extension

extension Coordinator {
    
    func push(_ viewController: UIViewController) {
        navController.pushViewController(viewController, animated: true)
    }
    
    func pop() {
        navController.popViewController(animated: true)
    }
    
    func popToRoot() {
        navController.popToRootViewController(animated: true)
    }
    
}//End of extension
