//
//  RoundButton.swift
//  3DModelGenerator
//
//  Created by Vraj Shah on 10/01/23.
//

import UIKit

/// Base class for button with default corner radius
class RoundButton: UIButton {
    
    //MARK: -
    //MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }
    
    //MARK: -
    //MARK: - Private functions
    
    private func initView() {
        self.layer.cornerRadius = 10.0
    }
    
}//End of class
