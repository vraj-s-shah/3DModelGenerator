//
//  AppCoordinator.swift
//  3DModelGenerator
//
//  Created by Vraj Shah on 03/01/23.
//

import Foundation
import UIKit

/// The coordinator for the application
class AppCoordinator: Coordinator {
    
    //MARK: -
    //MARK: - Variables
    
    var navController: UINavigationController
    
    
    //MARK: -
    //MARK: - Initialization
    
    init (_ navigationController: UINavigationController) {
        navController = navigationController
    }
    
    //MARK: -
    //MARK: - Start
    
    func start() {
        let mainCoordinator = HomeCoordinator(navController)
        mainCoordinator.start()
    }
    
}//End of class
