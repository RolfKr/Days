//
//  AuthenticationViewController.swift
//  Days
//
//  Created by Rolf Kristian Andreassen on 12/02/2020.
//  Copyright © 2020 Rolf Kristian Andreassen. All rights reserved.
//

import UIKit
import LocalAuthentication

class AuthenticationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = backgroundColor
        handleAuthentication()
    }
    
    private func handleAuthentication() {
        let context = LAContext()
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Access required") { (granted, error) in
                if granted {
                    DispatchQueue.main.async {
                        print("Access granted")
                        let tabBar = TabBarController()
                        self.navigationController?.pushViewController(tabBar, animated: true)
                    }
                } else {
                    print("Access denied!")
                    DispatchQueue.main.async {
                        let loginVC = LoginViewController()
                        self.navigationController?.pushViewController(loginVC, animated: true)
                    }
                }
            }
        } else {
            let welcomeVC = WelcomeViewController()
            self.navigationController?.pushViewController(welcomeVC, animated: true)
            view.showAlert(alertText: "Local authentication is not configured. Please check settings on iPhone.")
        }
    }
    
    

}
