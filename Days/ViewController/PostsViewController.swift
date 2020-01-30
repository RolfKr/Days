//
//  PostsViewController.swift
//  Days
//
//  Created by Rolf Kristian Andreassen on 28/01/2020.
//  Copyright © 2020 Rolf Kristian Andreassen. All rights reserved.
//*

import UIKit

class PostsViewController: UIViewController {

    var tableView: UITableView!
    var selectedProject: String!
    
    var project: Project!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(project.name)
        configureViews()
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
        view.addSubview(projectDetailLabel)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
                   titleLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 50),
                   titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
                   titleLabel.heightAnchor.constraint(equalToConstant: 44),
                   
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
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PostCell.self, forCellReuseIdentifier: "Cell")
        tableView.backgroundColor = backgroundColor
        tableView.allowsSelection = false
        
    }
}

extension PostsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostCell
        cell.backgroundColor = UIColor(named: "backgroundColor")
        cell.configureCell("Posted on 23.06.2019 at 17:49", "Ludum mutavit. Verbum est ex. Et ... sunt occidat. Videtur quod est super omne oppidum. Quis transfretavit tu iratus es  contudit cranium cum dolor apparatus. Qui curis! Modo nobis certamen est, qui non credunt at. ")
        return cell
    }
    
}
