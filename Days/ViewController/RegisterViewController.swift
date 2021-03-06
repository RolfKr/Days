//
//  ViewController.swift
//  Days
//
//  Created by Rolf Kristian Andreassen on 27/01/2020.
//  Copyright © 2020 Rolf Kristian Andreassen. All rights reserved.
//

import UIKit
import Firebase
import AuthenticationServices
import CryptoKit

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    var usernameView: InputView!
    var emailView: InputView!
    var passwordView: InputView!
    var secondPasswordView: InputView!
    var currentNonce: String?
    
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

    
    private func createUser(username: String, password: String, email: String) {
        if usernameView.textField.text == "" {
            view.showAlert(alertText: "You need to enter a username")
            usernameView.shakeAnimation()
            return
        } else if secondPasswordView.textField.text != passwordView.textField.text {
            view.showAlert(alertText: "Both passwords need to be the same")
            passwordView.shakeAnimation()
            secondPasswordView.shakeAnimation()
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                self.view.showAlert(alertText: error.localizedDescription)
            }
            
            if let result = result {
                self.showActivityIndicator(view: self.view)
                let changeRequest = result.user.createProfileChangeRequest()
                changeRequest.displayName = username
                changeRequest.commitChanges { (error) in
                    
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    
                    guard let uid = Auth.auth().currentUser?.uid else {return}
                    
                    self.addUserToDatabase(uid: uid, email: email, username: username)
                    self.goToProjects()
                }
                
            }
        }
    }
    
    private func addUserToDatabase(uid: String, email: String, username: String) {
        let usersRef = Firestore.firestore().collection("users")
        usersRef.document(uid).setData([
            "username": username,
            "email": email.lowercased(),
            "uid": Auth.auth().currentUser!.uid
        ])
    }
    
    private func configureUI() {
        view.backgroundColor = backgroundColor
        let titleText = TitleLabel("Register", 26, .left)
        usernameView = InputView("Enter name")
        usernameView.textField.delegate = self
        
        emailView = InputView("Enter email")
        emailView.textField.delegate = self
        emailView.textField.keyboardType = .emailAddress
        
        passwordView = InputView("Enter password")
        passwordView.textField.delegate = self
        passwordView.textField.isSecureTextEntry = true
        
        secondPasswordView = InputView("Enter password again")
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
        
        view.addSubview(titleText)
        view.addSubview(textFieldStack)
        view.addSubview(registerButton)
        view.addSubview(loginButton)
        
        let screenHeight = view.frame.height
        let sidePadding: CGFloat = 50
        
        NSLayoutConstraint.activate([
            titleText.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 25),
            titleText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sidePadding),
            titleText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sidePadding),
            titleText.heightAnchor.constraint(equalToConstant: 44),
            
            textFieldStack.topAnchor.constraint(equalTo: titleText.bottomAnchor, constant: 10),
            textFieldStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sidePadding),
            textFieldStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sidePadding),
            textFieldStack.heightAnchor.constraint(equalToConstant: screenHeight * 0.35),
            
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




