//
//  ProjectCell.swift
//  Days
//
//  Created by Rolf Kristian Andreassen on 27/01/2020.
//  Copyright © 2020 Rolf Kristian Andreassen. All rights reserved.
//

import UIKit
import Firebase

class ProjectCell: UICollectionViewCell {
    
    var titleLabel: TitleLabel!
    
    var projectImage: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor(named: "backgroundColor")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    var darkenView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.isHidden = true
        view.alpha = 0.35
        return view
    }()
    
    var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.style = .large
        view.color = .label
        view.startAnimating()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    func configureCell(title: String, imageURL: String) {
        backgroundColor = .systemBackground
        layer.cornerRadius = 6
        clipsToBounds = true
        downloadProjectImage(imageURL: imageURL)
        titleLabel = TitleLabel(title, 30, .left)
        titleLabel.textColor = .white
        titleLabel.isHidden = true
        
        addSubview(projectImage)
        projectImage.addSubview(activityIndicator)
        addSubview(darkenView)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            projectImage.topAnchor.constraint(equalTo: topAnchor),
            projectImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            projectImage.trailingAnchor.constraint(equalTo: trailingAnchor),
            projectImage.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            activityIndicator.topAnchor.constraint(equalTo: projectImage.topAnchor),
            activityIndicator.leadingAnchor.constraint(equalTo: projectImage.leadingAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: projectImage.trailingAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: projectImage.bottomAnchor),

            darkenView.topAnchor.constraint(equalTo: projectImage.topAnchor),
            darkenView.leadingAnchor.constraint(equalTo: projectImage.leadingAnchor),
            darkenView.trailingAnchor.constraint(equalTo: projectImage.trailingAnchor),
            darkenView.bottomAnchor.constraint(equalTo: projectImage.bottomAnchor),

            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 16),
            titleLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func downloadProjectImage(imageURL: String) {
        let storageRef = Storage.storage().reference(withPath: "projects/\(imageURL)")
        activityIndicator.isHidden = false

        storageRef.getData(maxSize: 4 * 1024 * 1024) { (data, error) in
            if let error = error {
                print(error.localizedDescription)
                
                return
            }
            
            if let data = data {
                
                
                if let downloadedImage = UIImage(data: data) {
                    self.projectImage.image = downloadedImage
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.darkenView.isHidden = false
                    self.titleLabel.isHidden = false

                }
            }
        }
    }
}
