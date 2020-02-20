//
//  LoginViewController.swift
//  Days
//
//  Created by Rolf Kristian Andreassen on 27/01/2020.
//  Copyright © 2020 Rolf Kristian Andreassen. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var emailView: InputView!
    var passwordView: InputView!
    var forgotPasswordButton: EnterButton!

    var bookImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "bookIcon")
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        dismissKeyboard(on: view, searchbar: nil)
    }
    
    private func configureUI() {
        view.backgroundColor = backgroundColor
        
        let titleText = TitleLabel("Login to Days", 26, .center)
        emailView = InputView("Enter email")
        emailView.textField.delegate = self
        passwordView = InputView("Enter password")
        passwordView.textField.isSecureTextEntry = true
        passwordView.textField.delegate = self
        let loginButton = EnterButton(("Login"), 17, .label)
        loginButton.addTarget(self, action: #selector(goToProjects), for: .touchUpInside)
        forgotPasswordButton = EnterButton("Forgot password", 17, .label)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPassTapped), for: .touchUpInside)
        
        let textfieldStack = UIStackView(arrangedSubviews: [emailView, passwordView])
        textfieldStack.translatesAutoresizingMaskIntoConstraints = false
        textfieldStack.axis = .vertical
        textfieldStack.spacing = 15
        textfieldStack.distribution = .fillEqually
        
        view.addSubview(bookImageView)
        view.addSubview(titleText)
        view.addSubview(textfieldStack)
        view.addSubview(loginButton)
        view.addSubview(forgotPasswordButton)
        
        let sidePadding: CGFloat = 50
        
        NSLayoutConstraint.activate([
            bookImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bookImageView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 30),
            bookImageView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.15),
            bookImageView.widthAnchor.constraint(equalTo: bookImageView.heightAnchor),
            
            titleText.topAnchor.constraint(equalTo: bookImageView.bottomAnchor, constant: 25),
            titleText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sidePadding),
            titleText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sidePadding),
            
            textfieldStack.topAnchor.constraint(equalTo: titleText.bottomAnchor, constant: 20),
            textfieldStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sidePadding),
            textfieldStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sidePadding),
            textfieldStack.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.15, constant: 0),
            
            loginButton.topAnchor.constraint(equalTo: textfieldStack.bottomAnchor, constant: 20),
            loginButton.centerXAnchor.constraint(equalTo: textfieldStack.centerXAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 44),
            loginButton.widthAnchor.constraint(equalToConstant: 200),
            
            forgotPasswordButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 10),
            forgotPasswordButton.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor),
            forgotPasswordButton.heightAnchor.constraint(equalToConstant: 44),
            forgotPasswordButton.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    @objc private func goToProjects() {
        guard let email = emailView.textField.text,
            let password = passwordView.textField.text else {return}
        
        loginUser(email: email, password: password)
    }
    
    @objc private func forgotPassTapped() {
        print("Tapped forgot password")
        
        guard let email = emailView.textField.text else {
            emailView.shakeAnimation()
            view.showAlert(alertText: "You need to enter an email")
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] (error) in
            if let error = error {
                self?.view.showAlert(alertText: error.localizedDescription)
            } else {
                self?.view.showAlert(alertText: "Please check your email for a link to reset your password.")
                self?.forgotPasswordButton.isHidden = true
            }
        }
    }
    
    private func loginUser(email: String, password: String) {
        if emailView.textField.text == "" {
            emailView.shakeAnimation()
            view.showAlert(alertText: "You need to enter an email")
        } else if passwordView.textField.text == "" {
            passwordView.shakeAnimation()
            view.showAlert(alertText: "You need to enter a password")
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                self.view.showAlert(alertText: error.localizedDescription)
            }
            
            if let _ = result {
                self.showActivityIndicator(view: self.view)
                let navBar = UINavigationController(rootViewController: TabBarController())
                navBar.navigationBar.isHidden = true
                navBar.modalPresentationStyle = .fullScreen
                self.present(navBar, animated: true)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
