//
//  PostCell.swift
//  Days
//
//  Created by Rolf Kristian Andreassen on 28/01/2020.
//  Copyright © 2020 Rolf Kristian Andreassen. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {
    
    var collectionView: UICollectionView!
    var imageURLs: [String] = []
    var images: [UIImage] = []
    
    var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = viewBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    func configureCell(_ postedText: String, _ bodyText: String) {
        createCollectionView()
        downloadPostImages(imageURL: imageURLs)
        let postedLabel = BodyLabel(postedText, 15, .left, .tertiaryLabel)
        let bodyLabel = BodyLabel(bodyText, 15, .left, .secondaryLabel)
        bodyLabel.numberOfLines = 0
        
        addSubview(containerView)
        containerView.addSubview(postedLabel)
        containerView.addSubview(bodyLabel)
        containerView.addSubview(collectionView)
        
        let padding: CGFloat = 20
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
            
            postedLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding),
            postedLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            postedLabel.heightAnchor.constraint(equalToConstant: 20),
            
            bodyLabel.topAnchor.constraint(equalTo: postedLabel.bottomAnchor, constant: 10),
            bodyLabel.leadingAnchor.constraint(equalTo: postedLabel.leadingAnchor),
            bodyLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            bodyLabel.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: -20),
            
            collectionView.leadingAnchor.constraint(equalTo: bodyLabel.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: bodyLabel.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            collectionView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func createCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 20
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = viewBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func downloadPostImages(imageURL: [String]) {
        
        for url in imageURL {
            
            let storageRef = Storage.storage().reference(withPath: "posts/\(url)")
            
            storageRef.getData(maxSize: 4 * 1024 * 1024) { (data, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                if let data = data {
                    
                    if let downloadedImage = UIImage(data: data) {
                        print("Got image")
                        self.images.append(downloadedImage)
                        self.collectionView.reloadData()

                    }
                }
            }
        }
        
    }
}


extension PostCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PostCollectionViewCell
        let picture = images[indexPath.item]
        cell.configureCollectionViewCell(picture)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 175, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Tapped item \(indexPath.item + 1)")
    }
}
