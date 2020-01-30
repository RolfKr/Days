//
//  enterButton.swift
//  Days
//
//  Created by Rolf Kristian Andreassen on 27/01/2020.
//  Copyright © 2020 Rolf Kristian Andreassen. All rights reserved.
//

import UIKit

class EnterButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }
    
    init(_ buttonText: String, _ fontSize: CGFloat, _ fontColor: UIColor) {
        super.init(frame: .zero)
        setTitle(buttonText, for: .normal)
        titleLabel?.font = UIFont(name: "AvenirNextCondensed-Medium", size: fontSize)
        setTitleColor(fontColor, for: .normal)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func configureViews() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = viewBackground
        layer.cornerRadius = 4
        layer.borderColor = UIColor.tertiaryLabel.cgColor
        layer.borderWidth = 1
        
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: topAnchor),
            leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
