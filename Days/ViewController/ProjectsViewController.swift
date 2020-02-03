//
//  ProjectsViewController.swift
//  Days
//
//  Created by Rolf Kristian Andreassen on 27/01/2020.
//  Copyright © 2020 Rolf Kristian Andreassen. All rights reserved.
//

import UIKit
import Firebase

class ProjectsViewController: UIViewController, AddProjectDelegate {
    
    var collectionView: UICollectionView!
    var projects: [Project] = []
    var emptyView: UIView?
    
    var username: String = {
        guard let user = Auth.auth().currentUser?.displayName else {return "Unkown User"}
        return user
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getProjects()
        configureViews()
        
        #warning("Add a background picture if there are no journals")
    }
    
    private func getProjects() {
        projects = []
        guard let currentUserEmail = Auth.auth().currentUser?.email else {return}

        Firestore.firestore().collection("projects").whereField("addedBy", isEqualTo: currentUserEmail).order(by: "created", descending: true).getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                
                for document in snapshot!.documents {
                    let name = document.data()["name"] as? String ?? "Unkown Name"
                    let detailText = document.data()["detailText"] as? String ?? "Unknown"
                    let addedBy = document.data()["addedBy"] as? String ?? "Unkown"
                    let created = document.data()["created"] as? String ?? "Unkown"
                    let imageURL = document.data()["imageID"] as? String ?? "Unknown"
                    let projectID = document.data()["projectID"] as? String ?? "Unknown"
                    
                    let project = Project(name: name, detail: detailText, addedBy: addedBy, created: created, imageURL: imageURL, projectID: projectID)
                    self.projects.append(project)
                }
                
                if self.projects.isEmpty {
                    self.addEmptyListView()
                }
                
                self.collectionView.reloadData()
            }
        }
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
    
    private func configureViews() {
        createCollectionView()
        view.backgroundColor = backgroundColor
        
        let titleLabel = TitleLabel("Days", 38, .left)
        let helloLabel = BodyLabel("Hi there, \(username)", 17, .left, .secondaryLabel)
        let projectsLabel = BodyLabel("My Journals", 22, .left, .label)
        let addProjectButton = EnterButton("Add Journal", 20, .secondaryLabel)
        addProjectButton.addTarget(self, action: #selector(addProjectTapped), for: .touchUpInside)
        
        view.addSubview(titleLabel)
        view.addSubview(helloLabel)
        view.addSubview(projectsLabel)
        view.addSubview(addProjectButton)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 50),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            titleLabel.heightAnchor.constraint(equalToConstant: 44),
            
            helloLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            helloLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 4),
            helloLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            helloLabel.heightAnchor.constraint(equalToConstant: 20),
            
            projectsLabel.topAnchor.constraint(equalTo: helloLabel.bottomAnchor, constant: 30),
            projectsLabel.leadingAnchor.constraint(equalTo: helloLabel.leadingAnchor),
            projectsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            projectsLabel.heightAnchor.constraint(equalToConstant: 22),
            
            collectionView.topAnchor.constraint(equalTo: projectsLabel.bottomAnchor, constant: 25),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            collectionView.bottomAnchor.constraint(equalTo: addProjectButton.topAnchor, constant: -20),
            
            addProjectButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20),
            addProjectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addProjectButton.heightAnchor.constraint(equalToConstant: 50),
            addProjectButton.widthAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    private func addEmptyListView() {
        emptyView = view.showEmptyListView(titleText: "You have no journals", subTitleText: "Press the button below to add", image: UIImage(named: "emptyBox")!)
        emptyView?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyView!)
        
        NSLayoutConstraint.activate([
            emptyView!.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            emptyView!.heightAnchor.constraint(equalTo: collectionView.heightAnchor, multiplier: 0.6),
            emptyView!.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            emptyView!.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
        ])
    }
    
    @objc private func addProjectTapped() {
        let childVC = AddProjectViewController()
        childVC.delegate = self
        addChild(childVC)
        childVC.view.frame = self.view.frame
        view.addSubview(childVC.view)
        childVC.didMove(toParent: self)
    }
    
    func didFinishAddingProject(_ project: Project) {
        let indexPath = IndexPath(item: projects.count, section: 0)
        projects.append(project)
        collectionView.insertItems(at: [indexPath])
        
        if let view = emptyView {
            view.removeFromSuperview()
        }
    }
}

extension ProjectsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
        print("Tapped project")
        let postsVC = PostsViewController()
        postsVC.project = projects[indexPath.item]
        navigationController?.pushViewController(postsVC, animated: true)
    }
    
}
