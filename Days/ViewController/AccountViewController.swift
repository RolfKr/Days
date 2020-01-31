//
//  AccountViewController.swift
//  Days
//
//  Created by Rolf Kristian Andreassen on 31/01/2020.
//  Copyright © 2020 Rolf Kristian Andreassen. All rights reserved.
//

import UIKit
import Firebase

class AccountViewController: UIViewController {
    
    var cells: [UITableViewCell] = []
    var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }
    
    private func configureViews() {
        createStaticCells()
        createTableView()
        
        view.backgroundColor = backgroundColor
        let titleLabel = TitleLabel("Account", 38, .left)
        
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
                   titleLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 50),
                   titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
                   titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
                   titleLabel.heightAnchor.constraint(equalToConstant: 44),
                   
                   tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
                   tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                   tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                   tableView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])
    }
    
    private func createTableView() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = backgroundColor
        view.addSubview(tableView)
    }
    
    func createStaticCells() {
        let signOutCell: UITableViewCell = UITableViewCell()
        signOutCell.backgroundColor = cellBackground
        let height = signOutCell.frame.height
        let width = view.frame.width
        
        let signOutButton = UIButton(frame: CGRect(x: 0, y: 0, width: width, height: height))
        signOutButton.setTitleColor(.label, for: .normal)
        signOutButton.setTitle("Sign Out", for: .normal)
        signOutButton.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        signOutCell.addSubview(signOutButton)
        cells.append(signOutCell)
    }
    
    @objc private func signOut() {
        do {
            print("Signing out")
            try Auth.auth().signOut()
            let welcomeVC = WelcomeViewController()
            welcomeVC.modalPresentationStyle = .fullScreen
            present(welcomeVC, animated: true)
        } catch let error {
            print(error.localizedDescription)
        }
    }

}

extension AccountViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Settings"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath.row]
    }
}
