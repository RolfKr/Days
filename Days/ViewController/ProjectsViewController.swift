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
    var longPressGesture: UILongPressGestureRecognizer!
    var ownJournals = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getProjects()
        configureViews()
        addTapGesture()
    }
    
    var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["My Journals", "Favorited Journals"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        control.tintColor = backgroundColor
        control.addTarget(self, action: #selector(handleSegmentedControl(_:)), for: .valueChanged)
        return control
    }()
    
    private func getProjects() {
        projects = []
        guard let currentUID = Auth.auth().currentUser?.uid else {return}
        
        Firestore.firestore().collection("projects").whereField("addedBy", isEqualTo: currentUID).order(by: "created", descending: true).getDocuments { (snapshot, error) in
            if let error = error {
                self.view.showAlert(alertText: error.localizedDescription)
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
                
                self.collectionView.addGestureRecognizer(self.longPressGesture)
                self.collectionView.reloadData()
            }
        }
    }
    
    private func getFavorites() {
        projects = []
        
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("users").document(currentUserID)
        
        var favoritedProjects = [String]()
        
        userRef.getDocument { (snapshot, error) in
            if let error = error {
                self.view.showAlert(alertText: error.localizedDescription)
            } else {
                favoritedProjects = snapshot?.data()?["favoriteProjects"] as? [String] ?? [""]
                
                
                for project in favoritedProjects {                    
                    Firestore.firestore().collection("projects").whereField("projectID", isEqualTo: project).getDocuments { (snapshot, error) in
                        if let error = error {
                            self.view.showAlert(alertText: error.localizedDescription)
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
                            
                            self.collectionView.removeGestureRecognizer(self.longPressGesture)
                            self.collectionView.reloadData()
                        }
                    }
                }
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
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
    }
    
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        let cells = collectionView.visibleCells as! Array<ProjectCell>
        
        for cell in cells {
            cell.layer.removeAllAnimations()
            cell.deleteButton.isHidden = true
        }
        
        guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {return}
        let cell = collectionView.cellForItem(at: selectedIndexPath) as! ProjectCell
        cell.deleteButton.isHidden = false
        cell.deleteButton.tag = selectedIndexPath.item
        cell.deleteButton.addTarget(self, action: #selector(deleteProject(_:)), for: .touchUpInside)
        cell.deleteAnimation()
    }
    
    
    @objc private func handleSegmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            ownJournals = true
            getProjects()
        case 1:
            ownJournals = false
            getFavorites()
            emptyView?.isHidden = true
        default:
            break
        }
    }
    
    
    @objc private func deleteProject(_ sender: UIButton) {
        let project = projects[sender.tag]
        let projectsDB = Firestore.firestore().collection("projects")
        
        projectsDB.document(project.projectID).delete() { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Document successfully removed!")
                self.projects.remove(at: sender.tag)
                self.collectionView.reloadData()
            }
        }
    }
    
    private func configureViews() {
        createCollectionView()
        view.backgroundColor = backgroundColor
        
        let titleLabel = TitleLabel("Days", 38, .left)
        let addProjectButton = EnterButton("Add Journal", 20, .secondaryLabel)
        addProjectButton.addTarget(self, action: #selector(addProjectTapped), for: .touchUpInside)
        
        view.addSubview(titleLabel)
        view.addSubview(addProjectButton)
        view.addSubview(collectionView)
        view.addSubview(segmentedControl)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            titleLabel.heightAnchor.constraint(equalToConstant: 44),
            
            segmentedControl.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            segmentedControl.heightAnchor.constraint(equalToConstant: 35),
            
            collectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 15),
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
            emptyView!.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: 20),
            emptyView!.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            emptyView!.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: -20)
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
    
    private func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(removeDeleteAnimation))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func removeDeleteAnimation() {
        let cells = collectionView.visibleCells as! Array<ProjectCell>
        
        for cell in cells {
            cell.layer.removeAllAnimations()
            cell.deleteButton.isHidden = true
        }
    }
}

extension ProjectsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return projects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ProjectCell
        
        for view in cell.contentView.subviews {
           view.removeFromSuperview()
        }
        
        let project = projects[indexPath.item]
        cell.configureCell(title: project.name, imageURL: project.imageURL)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = projects.remove(at: sourceIndexPath.item)
        projects.insert(item, at: destinationIndexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = collectionView.frame.size.width
        return CGSize(width: screenWidth, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let postsVC = PostsViewController()
        postsVC.project = projects[indexPath.item]
        
        if ownJournals {
            postsVC.isPublicProject = false
        } else {
            postsVC.isPublicProject = true
        }
        
        
        navigationController?.pushViewController(postsVC, animated: true)
    }
    
}
