//
//  MainCoordinator.swift
//  3DModelGenerator
//
//  Created by Vraj Shah on 03/01/23.
//

import UIKit

/// The coordinator handling home screen of the application
class HomeCoordinator: Coordinator {
    
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
        let mainVC = HomeViewController.instantiate(from: .main)
        mainVC.coordinator = self
        push(mainVC)
    }
    
    //MARK: -
    //MARK: - Navigation functions
    
    func goToTakePhotosViewController(objectName: String) {
        let takePhotosVC = TakePhotosViewController.instantiate(from: .main)
        takePhotosVC.coordinator = self
        takePhotosVC.objectName = objectName
        push(takePhotosVC)
    }
    
    func goToDemonstrateModelViewController() {
        let demonstrateModelVC = DemonstrateModelViewController.instantiate(from: .main)
        demonstrateModelVC.coordinator = self
        push(demonstrateModelVC)
    }
    
}//End of class
