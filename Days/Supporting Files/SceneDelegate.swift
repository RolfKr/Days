//
//  SceneDelegate.swift
//  Days
//
//  Created by Rolf Kristian Andreassen on 27/01/2020.
//  Copyright © 2020 Rolf Kristian Andreassen. All rights reserved.
//

import UIKit
import Firebase
import LocalAuthentication

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var accessGranted = false


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        var rootView: UIViewController!
        
        handleAuthentication()
        
        if Auth.auth().currentUser != nil && accessGranted {
            rootView = TabBarController()
        } else {
            rootView = WelcomeViewController()
        }
        
        UITabBar.appearance().tintColor = .label
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = rootView
        window?.makeKeyAndVisible()
    }
    
    private func handleAuthentication() {
        let context = LAContext()
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Access required") { (granted, error) in
                if granted {
                    self.accessGranted = true
                } else {
                    print("Access denied!")
                    self.accessGranted = false
                }
            }
        } else {
            print("FaceID not configured")
        }
    }

}

