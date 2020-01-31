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
        
        let projectsVC = ProjectsViewController()
        projectsVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)

        let tabBarList = [projectsVC]
        viewControllers = tabBarList
    }


}
