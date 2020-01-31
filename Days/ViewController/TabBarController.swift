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
        
        let projectsVC = UINavigationController(rootViewController: ProjectsViewController())
        projectsVC.navigationBar.isHidden = true
        projectsVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        
        let accountVC = AccountViewController()
        accountVC.tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 1)
        
        let tabBarList = [projectsVC, accountVC]
        viewControllers = tabBarList
    }


}
