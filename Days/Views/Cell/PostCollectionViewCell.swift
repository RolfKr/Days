//
//  PostCollectionViewCell.swift
//  Days
//
//  Created by Rolf Kristian Andreassen on 30/01/2020.
//  Copyright © 2020 Rolf Kristian Andreassen. All rights reserved.
//

import UIKit

class PostCollectionViewCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.removeFromSuperview() 
    }
    
    func configureCollectionViewCell(_ image: UIImage) {
        imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 6
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = image
        
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
