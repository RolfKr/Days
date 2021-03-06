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
    func dismissKeyboard(on view: UIView, searchbar: UISearchBar?) {
        let dismissKeyboard = UITapGestureRecognizer(target: view, action: #selector(view.endEditing(_:)))
        if let searchBar = searchbar {
            let dismissSearchBar = UITapGestureRecognizer(target: view, action: #selector(searchBar.endEditing(_:)))
            dismissSearchBar.cancelsTouchesInView = false
            view.addGestureRecognizer(dismissSearchBar)
        }
        
        dismissKeyboard.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissKeyboard)
        
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

extension UIView {
    
    func shakeAnimation() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 5, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 5, y: self.center.y))

        self.layer.add(animation, forKey: "position")
    }
    
    func deleteAnimation() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = .greatestFiniteMagnitude
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 2, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 2, y: self.center.y))

        self.layer.add(animation, forKey: "position")
    }
    
    
    func showAlert(alertText: String) {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        containerView.alpha = 1.0
        addSubview(containerView)
        
        let alertLabel = BodyLabel(alertText, 16, .center, .red)
        alertLabel.adjustsFontSizeToFitWidth = true
        alertLabel.minimumScaleFactor = 0.6
        alertLabel.numberOfLines = 0
        containerView.addSubview(alertLabel)
        
        let top = containerView.topAnchor.constraint(equalTo: topAnchor, constant: -50)
        top.isActive = true
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            containerView.heightAnchor.constraint(equalToConstant: 60),
            
            alertLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            alertLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            alertLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            alertLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        ])
        
        layoutIfNeeded()
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            top.constant = 50
            self.layoutIfNeeded()
        }) { (finished) in
            if finished {
                
                UIView.animate(withDuration: 3.0, delay: 2.5, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.4, options: .curveEaseInOut, animations: {
                    containerView.alpha = 0
                    self.layoutIfNeeded()
                })
            }
        }
    }
    
    func showEmptyListView(titleText: String, subTitleText: String, image: UIImage) -> UIView {
        let container = UIView()
        container.tag = 999
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)
        
        let title = TitleLabel(titleText, 16, .center)
        title.textColor = .secondaryLabel
        title.adjustsFontSizeToFitWidth = true
        title.minimumScaleFactor = 0.6
        let boxImage = UIImageView(image: image)
        boxImage.translatesAutoresizingMaskIntoConstraints = false
        boxImage.contentMode = .scaleAspectFit
        boxImage.alpha = 0.6
        let subTitle = TitleLabel(subTitleText, 16, .center)
        subTitle.textColor = .secondaryLabel
        subTitle.adjustsFontSizeToFitWidth = true
        subTitle.minimumScaleFactor = 0.6
        subTitle.numberOfLines = 2
        
        let stackView = UIStackView(arrangedSubviews: [title, boxImage, subTitle])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        stackView.axis = .vertical
        
        container.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            boxImage.heightAnchor.constraint(equalToConstant: 150),
            boxImage.widthAnchor.constraint(equalToConstant: 150),
            stackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20)
        ])
        
        return container
    }
}
