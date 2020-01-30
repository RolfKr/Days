//
//  DaysTxtField.swift
//  Days
//
//  Created by Rolf Kristian Andreassen on 27/01/2020.
//  Copyright © 2020 Rolf Kristian Andreassen. All rights reserved.
//

import UIKit

class InputView: UIView {
    
    var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = viewBackground
        return view
    }()
    
    var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont(name: "AvenirNextCondensed-Medium", size: 17)
        textField.textColor = .label
        return textField
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }
    
    init(_ placeHolder: String) {
        super.init(frame: .zero)
        textField.placeholder = placeHolder
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        containerView.addSubview(textField)
        
        let padding: CGFloat = 8
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            textField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding),
            textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding + 8),
            textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding + 8),
            textField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding)
        ])
    }
}
