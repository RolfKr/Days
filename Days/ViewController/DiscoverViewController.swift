//
//  DiscoverViewController.swift
//  Days
//
//  Created by Rolf Kristian Andreassen on 11/02/2020.
//  Copyright © 2020 Rolf Kristian Andreassen. All rights reserved.
//

import UIKit
import Firebase

class DiscoverViewController: UIViewController {
    
    var collectionView: UICollectionView!
    var projects: [Project] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        getProjects()
    }
    
    private func getProjects() {
        projects = []

        let projectsRef = Firestore.firestore().collection("projects")
        let publicProjects = projectsRef.whereField("public", isEqualTo: true).order(by: "created", descending: true)
        
        publicProjects.getDocuments { [weak self] (snapshot, error) in
            if let error = error {
                self?.view.showAlert(alertText: error.localizedDescription)
            } else {
                for document in snapshot!.documents {
                    let name = document.data()["name"] as? String ?? "Unkown Name"
                    let detailText = document.data()["detailText"] as? String ?? "Unknown"
                    let addedBy = document.data()["addedBy"] as? String ?? "Unkown"
                    let created = document.data()["created"] as? String ?? "Unkown"
                    let imageURL = document.data()["imageID"] as? String ?? "Unknown"
                    let projectID = document.data()["projectID"] as? String ?? "Unknown"
                    
                    if addedBy == Auth.auth().currentUser?.uid {
                        continue
                    }
                    
                    let project = Project(name: name, detail: detailText, addedBy: addedBy, created: created, imageURL: imageURL, projectID: projectID)
                    self?.projects.append(project)
                }
                self?.collectionView.reloadData()
            }
        }
    }
    
    private func configureViews() {
        view.backgroundColor = backgroundColor
        
        createCollectionView()
        
        let titleLabel = TitleLabel("Discover", 38, .left)
        let subTitle = BodyLabel("Find Journals created by others", 17, .left, .secondaryLabel)
        subTitle.minimumScaleFactor = 0.6
        subTitle.adjustsFontSizeToFitWidth = true
        
        view.addSubview(titleLabel)
        view.addSubview(subTitle)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            titleLabel.heightAnchor.constraint(equalToConstant: 44),
            
            subTitle.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subTitle.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 4),
            subTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            subTitle.heightAnchor.constraint(equalToConstant: 20),
            
            collectionView.topAnchor.constraint(equalTo: subTitle.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            collectionView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: 0)
            
        ])
    }
    
    private func createCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 20
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(ProjectCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = backgroundColor
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension DiscoverViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return projects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ProjectCell
        let project = projects[indexPath.item]
        cell.configureCell(title: project.name, imageURL: project.imageURL)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = collectionView.frame.size.width
        return CGSize(width: screenWidth, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let postsVC = PostsViewController()
        postsVC.project = projects[indexPath.item]
        postsVC.isPublicProject = true
        navigationController?.pushViewController(postsVC, animated: true)
    }
}
