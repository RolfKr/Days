//
//  PostsViewController.swift
//  Days
//
//  Created by Rolf Kristian Andreassen on 28/01/2020.
//  Copyright © 2020 Rolf Kristian Andreassen. All rights reserved.
//*

import UIKit
import Firebase

class PostsViewController: UIViewController {

    var tableView: UITableView!
    var selectedProject: String!
    
    var project: Project!
    var posts: [Post] = []
    
    var addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "addPost"), for: .normal)
        button.backgroundColor = backgroundColor
        button.addTarget(self, action: #selector(addPostTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(project.name)
        configureViews()
        
        getPosts()
    }
    
    private func getPosts() {
        posts = []
        
        let projectRef = Firestore.firestore().collection("projects").document(project.projectID)
        let postRef = projectRef.collection("posts")
        
        postRef.getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                
                for document in snapshot!.documents {
                    let created = document.data()["created"] as? String ?? "Unkown"
                    let postID = document.data()["postID"] as? String ?? "Unknown"
                    let postBody = document.data()["postBody"] as? String ?? "Unkown"
                    let images = document.data()["images"] as? [String] ?? []
                    
                    let post = Post(created: created, body: postBody, imageURLs: images, postID: postID)
                    self.posts.append(post)
                }
                
                // TODO: Add spinner here?
                self.tableView.reloadData()
            }
        }
    }
    
    private func configureViews() {
        view.backgroundColor = backgroundColor
        createTableView()
        let titleLabel = TitleLabel(project.name, 38, .left)
        let projectDetailLabel = BodyLabel(project.detail, 17, .left, .secondaryLabel)
        projectDetailLabel.minimumScaleFactor = 0.7
        projectDetailLabel.numberOfLines = 3
        projectDetailLabel.adjustsFontSizeToFitWidth = true

        view.addSubview(titleLabel)
        view.addSubview(addButton)
        view.addSubview(projectDetailLabel)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
                   titleLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 50),
                   titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
                   titleLabel.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -20),
                   titleLabel.heightAnchor.constraint(equalToConstant: 44),
                   
                   addButton.topAnchor.constraint(equalTo: titleLabel.topAnchor),
                   addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
                   addButton.heightAnchor.constraint(equalToConstant: 50),
                   addButton.widthAnchor.constraint(equalToConstant: 50),
                   
                   projectDetailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
                   projectDetailLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                   projectDetailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
                   projectDetailLabel.heightAnchor.constraint(equalToConstant: 75),
                   
                   tableView.topAnchor.constraint(equalTo: projectDetailLabel.bottomAnchor, constant: 8),
                   tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
                   tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
                   tableView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20)
        ])
        
    }
    
    private func createTableView() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PostCell.self, forCellReuseIdentifier: "Cell")
        tableView.backgroundColor = backgroundColor
        tableView.allowsSelection = false
    }
    
    @objc private func addPostTapped() {
        let addPostVC = AddPostViewController()
        addPostVC.project = project
        present(addPostVC, animated: true)
    }
}

extension PostsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostCell
        cell.backgroundColor = UIColor(named: "backgroundColor")
        let post = posts[indexPath.row]
        cell.imageURLs = post.imageURLs
        cell.configureCell(post.created, post.body)
        return cell
    }
    
}

