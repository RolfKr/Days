//
//  Extensions.swift
//  Days
//
//  Created by Rolf Kristian Andreassen on 31/01/2020.
//  Copyright © 2020 Rolf Kristian Andreassen. All rights reserved.
//

import UIKit

extension UIViewController {
    
    //Dismiss keyboard when tapping on the view.
    func tapGesture() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
    }
    
    func showActivityIndicator(view: UIView) {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.startAnimating()
        indicator.color = .label
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
            indicator.centerXAnchor.constraint(equalToSystemSpacingAfter: view.centerXAnchor, multiplier: 0),
            indicator.heightAnchor.constraint(equalToConstant: 50),
            indicator.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
}
