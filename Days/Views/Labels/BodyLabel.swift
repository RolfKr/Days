//
//  BodyLabel.swift
//  Days
//
//  Created by Rolf Kristian Andreassen on 27/01/2020.
//  Copyright © 2020 Rolf Kristian Andreassen. All rights reserved.
//

import UIKit

class BodyLabel: UILabel {
 
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(_ text: String, _ fontSize: CGFloat, _ alignment: NSTextAlignment, _ fontColor: UIColor) {
        super.init(frame: .zero)
        self.text = text
        self.font = UIFont(name: "AvenirNext-DemiBold", size: fontSize)
        self.textAlignment = alignment
        self.translatesAutoresizingMaskIntoConstraints = false
        self.textColor = fontColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
