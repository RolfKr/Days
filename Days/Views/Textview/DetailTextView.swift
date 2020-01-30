//
//  DetailTextView.swift
//  Days
//
//  Created by Rolf Kristian Andreassen on 30/01/2020.
//  Copyright © 2020 Rolf Kristian Andreassen. All rights reserved.
//

import UIKit

class DetailTextView: UITextView {
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(_ placeholder: String, _ fontColor: UIColor, _ fontSize: CGFloat){
        super.init(frame: .zero, textContainer: .none)
        text = placeholder
        textColor = fontColor
        font = UIFont(name: "AvenirNext-Medium", size: fontSize)
        configure()
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 4
        textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5);
        backgroundColor = viewBackground
    }
}
