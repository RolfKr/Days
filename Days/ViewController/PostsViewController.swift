//
//  PostsViewController.swift
//  Days
//
//  Created by Rolf Kristian Andreassen on 28/01/2020.
//  Copyright © 2020 Rolf Kristian Andreassen. All rights reserved.
//*

import UIKit
import Firebase

class PostsViewController: UIViewController, AddPostDelegate {

    var tableView: UITableView!
    var selectedProject: String!
    var isPublicProject: Bool!
    
    var project: Project!
    var posts: [Post]!
    var emptyView: UIView!
    
    var isFavorited = false
    
    var addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "addPost"), for: .normal)
        button.backgroundColor = backgroundColor
        button.addTarget(self, action: #selector(addPostTapped), for: .touchUpInside)
        return button
    }()
    
    var heartButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "heart"), for: .normal)
        button.backgroundColor = backgroundColor
        button.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfFavorited()
        getPosts()
        createTableView()
        configureViews()
    }
    
    private func checkIfFavorited() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("users").document(currentUserID)
        
        
        
        userRef.getDocument { (snapshot, error) in
            if let error = error {
                self.view.showAlert(alertText: error.localizedDescription)
            } else {
                let favoriteProjects = snapshot?.data()?["favoriteProjects"] as? [String] ?? [""]
                
                if favoriteProjects.contains(self.project.projectID) {
                    self.isFavorited = true
                    self.heartButton.setImage(UIImage(named: "heartFilled"), for: .normal)
                }
            }
        }
    }
    
    private func getPosts() {
        posts = []
        
        let projectRef = Firestore.firestore().collection("projects").document(project.projectID)
        let postRef = projectRef.collection("posts").order(by: "created", descending: true)
        
        postRef.getDocuments { (snapshot, error) in
            if let error = error {
                self.view.showAlert(alertText: error.localizedDescription)
            } else {
                
                for document in snapshot!.documents {
                    let created = document.data()["created"] as? String ?? "Unkown"
                    let postID = document.data()["postID"] as? String ?? "Unknown"
                    let postBody = document.data()["postBody"] as? String ?? "Unkown"
                    let images = document.data()["images"] as? [String] ?? []
                    
                    let post = Post(created: created, body: postBody, imageURLs: images, postID: postID)
                    self.posts.append(post)
                }
                
                if self.posts.isEmpty {
                    self.addEmptyPostView()
                }
                self.tableView.reloadData()
            }
        }
    }
    
    private func configureViews() {
        view.backgroundColor = backgroundColor
        
        let titleLabel = TitleLabel(project.name, 38, .left)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.numberOfLines = 2
        
        let projectDetailLabel = BodyLabel(project.detail, 17, .left, .secondaryLabel)
        projectDetailLabel.minimumScaleFactor = 0.7
        projectDetailLabel.numberOfLines = 3
        projectDetailLabel.adjustsFontSizeToFitWidth = true

        view.addSubview(titleLabel)
        view.addSubview(heartButton)
        view.addSubview(addButton)
        
        if isPublicProject {
            addButton.isHidden = true
        } else {
            heartButton.isHidden = true
        }
        
        view.addSubview(projectDetailLabel)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
                   titleLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20),
                   titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
                   titleLabel.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -20),
                   titleLabel.heightAnchor.constraint(equalToConstant: 40),
                   
                   addButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 30),
                   addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
                   addButton.heightAnchor.constraint(equalToConstant: 50),
                   addButton.widthAnchor.constraint(equalToConstant: 50),
                   
                   heartButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 30),
                   heartButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
                   heartButton.heightAnchor.constraint(equalToConstant: 50),
                   heartButton.widthAnchor.constraint(equalToConstant: 50),
                   
                   projectDetailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
                   projectDetailLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                   projectDetailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
                   projectDetailLabel.heightAnchor.constraint(equalToConstant: 75),
                   
                   tableView.topAnchor.constraint(equalTo: projectDetailLabel.bottomAnchor, constant: 8),
                   tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
                   tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
                   tableView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])
        
    }
    
    private func addEmptyPostView() {
        emptyView = view.showEmptyListView(titleText: "You have no posts", subTitleText: "Press the button in the top right to add", image: UIImage(named: "emptyPost")!)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyView)
        
        NSLayoutConstraint.activate([
            emptyView.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 20),
            emptyView.heightAnchor.constraint(equalTo: tableView.heightAnchor, multiplier: 0.6),
            emptyView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
        ])
    }
    
    private func createTableView() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PostCell.self, forCellReuseIdentifier: "Cell")
        tableView.backgroundColor = backgroundColor
        tableView.allowsSelection = false
    }
    
    @objc private func addPostTapped() {
        let addPostVC = AddPostViewController()
        addPostVC.project = project
        addPostVC.delegate = self
        present(addPostVC, animated: true)
    }
    
    @objc private func favoriteTapped() {
        isFavorited = !isFavorited
        
        if isFavorited {
            heartButton.setImage(UIImage(named: "heartFilled"), for: .normal)
            favoriteProject()
        } else {
            heartButton.setImage(UIImage(named: "heart"), for: .normal)
            favoriteProject()
        }
    }
    
    private func favoriteProject() {
        guard let currentUser = Auth.auth().currentUser?.uid else {return}
        let userRef = Firestore.firestore().collection("users").document(currentUser)
        
        if isFavorited {
            userRef.updateData([
                "favoriteProjects" : FieldValue.arrayUnion([project.projectID])
            ])
        } else {
            userRef.updateData([
                "favoriteProjects" : FieldValue.arrayRemove([project.projectID])
            ])
        }

    }
    
    func didFinishAddingPost() {
        getPosts()
        emptyView?.removeFromSuperview()
    }
}

extension PostsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostCell
        cell.backgroundColor = backgroundColor
        let post = posts[indexPath.row]
        cell.configureCell(post.created, post.body, post.imageURLs)
        return cell
    }
}
