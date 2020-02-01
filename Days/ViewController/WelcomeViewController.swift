//
//  ViewController.swift
//  Days
//
//  Created by Rolf Kristian Andreassen on 27/01/2020.
//  Copyright © 2020 Rolf Kristian Andreassen. All rights reserved.
//

import UIKit
import Firebase

class WelcomeViewController: UIViewController, UITextFieldDelegate {
    
    var usernameView: InputView!
    var emailView: InputView!
    var passwordView: InputView!
    
    var bookImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "bookIcon")
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        tapGesture()
    }

    
    private func createUser(username: String, password: String, email: String) {
        showActivityIndicator(view: view)
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let _ = error {
                self.usernameView.shakeAnimation()
                self.view.showAlert(alertText: "Something went wrong")
            }
            
            if let result = result {
                let changeRequest = result.user.createProfileChangeRequest()
                changeRequest.displayName = username
                changeRequest.commitChanges { (error) in
                    
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    
                    self.addUserToDatabase(email: email, username: username)
                    self.goToProjects()
                }
                
            }
        }
    }
    
    private func addUserToDatabase(email: String, username: String) {
        let usersRef = Firestore.firestore().collection("users")
        usersRef.document(email).setData([
            "username": username,
            "email": email,
            "uid": Auth.auth().currentUser!.uid
        ])
    }
    
    private func configureUI() {
        view.backgroundColor = backgroundColor
        let titleText = TitleLabel("Welcome to Days", 32, .center)
        usernameView = InputView("Enter name")
        usernameView.textField.delegate = self
        emailView = InputView("Enter email")
        emailView.textField.delegate = self
        emailView.textField.keyboardType = .emailAddress
        passwordView = InputView("Enter password")
        passwordView.textField.delegate = self
        passwordView.textField.isSecureTextEntry = true
        let secondPasswordView = InputView("Enter password again")
        secondPasswordView.textField.delegate = self
        secondPasswordView.textField.isSecureTextEntry = true
        let registerButton = EnterButton(("Register"), 17, .label)
        let loginButton = EnterButton("Already have an account?", 12, .label)
        registerButton.addTarget(self, action: #selector(register), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(goToLogin), for: .touchUpInside)
        
        
        let textFieldStack = UIStackView(arrangedSubviews: [usernameView, emailView, passwordView, secondPasswordView])
        textFieldStack.translatesAutoresizingMaskIntoConstraints = false
        textFieldStack.axis = .vertical
        textFieldStack.spacing = 15
        textFieldStack.distribution = .fillEqually
        
        view.addSubview(bookImageView)
        view.addSubview(titleText)
        view.addSubview(textFieldStack)
        view.addSubview(registerButton)
        view.addSubview(loginButton)
        
        let screenHeight = view.frame.height
        let sidePadding: CGFloat = 50
        
        NSLayoutConstraint.activate([
            bookImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bookImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            bookImageView.heightAnchor.constraint(equalToConstant: 100),
            bookImageView.widthAnchor.constraint(equalToConstant: 100),
            
            titleText.topAnchor.constraint(equalTo: bookImageView.bottomAnchor, constant: 40),
            titleText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sidePadding),
            titleText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sidePadding),
            
            textFieldStack.topAnchor.constraint(equalTo: titleText.bottomAnchor, constant: 20),
            textFieldStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sidePadding),
            textFieldStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sidePadding),
            textFieldStack.heightAnchor.constraint(equalToConstant: screenHeight * 0.3),
            
            registerButton.topAnchor.constraint(equalTo: textFieldStack.bottomAnchor, constant: 20),
            registerButton.centerXAnchor.constraint(equalTo: textFieldStack.centerXAnchor),
            registerButton.heightAnchor.constraint(equalToConstant: 44),
            registerButton.widthAnchor.constraint(equalToConstant: 200),
            
            loginButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -8),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            loginButton.heightAnchor.constraint(equalToConstant: 30),
            loginButton.widthAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    @objc private func goToLogin() {
        present(LoginViewController(), animated: true)
    }
    
    @objc private func register() {
        guard let username = usernameView.textField.text,
            let email = emailView.textField.text,
            let password = passwordView.textField.text else {return}
        
        createUser(username: username, password: password, email: email)
    }
    
    private func goToProjects() {
        let navBar = UINavigationController(rootViewController: TabBarController())
        navBar.navigationBar.isHidden = true
        navBar.modalPresentationStyle = .fullScreen
        present(navBar, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}



