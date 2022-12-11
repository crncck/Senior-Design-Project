//
//  CustomTextField.swift
//  FinalProject
//
//  Created by Ceren Çiçek on 16.04.2022.
//

import UIKit

class CustomTextField: UITextField {

    init(placeholder: String) {
        super.init(frame: .zero)

        let spacer = UIView()
        spacer.setDimensions(height: 50, width: 12)
        leftView = spacer
        leftViewMode = .always

        layer.cornerRadius = 10

        borderStyle = .none
        textColor = .white
        keyboardAppearance = .dark
        keyboardType = .emailAddress
        backgroundColor = UIColor(white: 1, alpha: 0.1)
        setHeight(50)
        //layer.cornerRadius = 30
        attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: UIColor(white: 1, alpha: 0.7) ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
