//
//  TabBarController.swift
//  Days
//
//  Created by Rolf Kristian Andreassen on 31/01/2020.
//  Copyright © 2020 Rolf Kristian Andreassen. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let discoverVC = UINavigationController(rootViewController: DiscoverViewController())
        discoverVC.navigationBar.isHidden = true
        discoverVC.tabBarItem = UITabBarItem(title: "Discover", image: UIImage(systemName: "star"), selectedImage: UIImage(systemName: "star.fill"))
        
        let projectsVC = UINavigationController(rootViewController: ProjectsViewController())
        projectsVC.navigationBar.isHidden = true
        projectsVC.tabBarItem = UITabBarItem(title: "Journals", image: UIImage(systemName: "list.dash"), selectedImage: UIImage(systemName: "list.dash"))
        
        let accountVC = AccountViewController()
        accountVC.tabBarItem = UITabBarItem(title: "Account", image: UIImage(systemName: "person.crop.circle"), selectedImage: UIImage(systemName: "person.crop.circle.fill"))
        
        let tabBarList = [projectsVC, discoverVC, accountVC]
        viewControllers = tabBarList
    }
}
