//
//  AddPostCollectionViewCell.swift
//  Days
//
//  Created by Rolf Kristian Andreassen on 31/01/2020.
//  Copyright © 2020 Rolf Kristian Andreassen. All rights reserved.
//

import UIKit

class AddPostImageCell: UICollectionViewCell {
    
    var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "closeBtn"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .red
        return button
    }()
    
    func configureCollectionViewCell(_ image: UIImage) {
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 4
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = image
        
        addSubview(imageView)
        addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            closeButton.heightAnchor.constraint(equalToConstant: 25),
            closeButton.widthAnchor.constraint(equalToConstant: 25)
        ])
    }
}

