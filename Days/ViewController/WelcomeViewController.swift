//
//  ViewController.swift
//  Days
//
//  Created by Rolf Kristian Andreassen on 27/01/2020.
//  Copyright © 2020 Rolf Kristian Andreassen. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import AuthenticationServices
import CryptoKit

class WelcomeViewController: UIViewController, UITextFieldDelegate, GIDSignInDelegate {
    
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
        dismissKeyboard(on: view)
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
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
        let titleText = TitleLabel("Welcome to Days", 32, .center)
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
        
        let googleSignIn = GIDSignInButton()
        googleSignIn.translatesAutoresizingMaskIntoConstraints = false
        
        let appleSignIn = ASAuthorizationAppleIDButton()
        appleSignIn.translatesAutoresizingMaskIntoConstraints = false
        appleSignIn.addTarget(self, action: #selector(didTapAppleButton), for: .touchUpInside)
        
        let customSignInStack = UIStackView(arrangedSubviews: [googleSignIn, appleSignIn])
        customSignInStack.axis = .horizontal
        customSignInStack.distribution = .fillEqually
        customSignInStack.spacing = 20
        customSignInStack.translatesAutoresizingMaskIntoConstraints = false
        
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
        view.addSubview(customSignInStack)
        
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
            
            customSignInStack.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 20),
            customSignInStack.leadingAnchor.constraint(equalTo: textFieldStack.leadingAnchor, constant: 0),
            customSignInStack.trailingAnchor.constraint(equalTo: textFieldStack.trailingAnchor, constant: 0),
            customSignInStack.heightAnchor.constraint(equalToConstant: 44),
            
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
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
        }
        
        guard let authentication = user.authentication else {return}
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
            if let error = error {
                self?.view.showAlert(alertText: error.localizedDescription)
                return
            }
        
            guard let email = user.profile.email,
                let username = user.profile.name,
                let uid = Auth.auth().currentUser?.uid else {return}
            
            
            self?.addUserToDatabase(uid: uid, email: email, username: username)
            self?.goToProjects()
        }
    }
    
    @objc private func didTapAppleButton() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}

extension WelcomeViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
      if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
        guard let nonce = currentNonce else {
          fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }
        guard let appleIDToken = appleIDCredential.identityToken else {
          print("Unable to fetch identity token")
          return
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
          print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
          return
        }
        // Initialize a Firebase credential.
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
        //let credential = OAuthProvider.credential(withProviderID: "apple.com", IDToken: idTokenString, rawNonce: nonce)
        
        // Sign in with Firebase.
        Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
          if let error = error {
            // Error. If error.code == .MissingOrInvalidNonce, make sure
            // you're sending the SHA256-hashed nonce as a hex string with
            // your request to Apple.
            print(error.localizedDescription)
            return
          }
          
            //Perform login
            print("User logged in")
        
            
           
            let username = appleIDCredential.fullName?.givenName ?? "No name"
            let email = appleIDCredential.email ?? "No email"
            
            guard let uid = Auth.auth().currentUser?.uid else {return}
            
            print(username)
            print(email)
            
            
            self?.addUserToDatabase(uid: uid, email: email, username: username)
            self?.goToProjects()
        }
      }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
      // Handle error.
      print("Sign in with Apple errored: \(error)")
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}


