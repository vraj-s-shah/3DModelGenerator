//
//  CustomUINavigationController.swift
//  3DModelGenerator
//
//  Created by Vraj Shah on 03/01/23.
//

import UIKit

/// UINavigationController class for handling swipe to pop feature
class CustomUINavigationController: UINavigationController {
    
    //MARK: -
    //MARK: - Variables
    
    private var duringPushAnimation = false
    
    //MARK: -
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        interactivePopGestureRecognizer?.delegate = self
    }
    
    deinit {
        delegate = nil
        interactivePopGestureRecognizer?.delegate = nil
    }
    
    //MARK: -
    //MARK: - Overrides
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        duringPushAnimation = true
        super.pushViewController(viewController, animated: animated)
    }

}//End of class

//MARK: -
//MARK: - UINavigationControllerDelegate

extension CustomUINavigationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let swipeNavigationController = navigationController as? CustomUINavigationController else { return }
        swipeNavigationController.duringPushAnimation = false
    }
    
}//End of extension

//MARK: -
//MARK: - UIGestureRecognizerDelegate

extension CustomUINavigationController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == interactivePopGestureRecognizer else {
            return true
        }
        return viewControllers.count > 1 && duringPushAnimation == false
    }
    
}//End of extension
