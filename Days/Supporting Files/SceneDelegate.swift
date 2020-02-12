//
//  SceneDelegate.swift
//  Days
//
//  Created by Rolf Kristian Andreassen on 27/01/2020.
//  Copyright © 2020 Rolf Kristian Andreassen. All rights reserved.
//

import UIKit
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var needLocalAuthentication: Bool!
    var defaults = UserDefaults.standard

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        var rootView: UIViewController!
        
        needLocalAuthentication = defaults.bool(forKey: "useFaceID")
        
        if Auth.auth().currentUser != nil {
            if needLocalAuthentication {
                rootView = AuthenticationViewController()
            } else {
                rootView = TabBarController()
            }
        } else {
            rootView = WelcomeViewController()
        }
        
        let navController = UINavigationController(rootViewController: rootView)
        navController.navigationBar.isHidden = true
        
        UITabBar.appearance().tintColor = .label
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
    }
}

