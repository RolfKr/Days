//
//  WelcomeViewController.swift
//  Days
//
//  Created by Rolf Kristian Andreassen on 17/02/2020.
//  Copyright © 2020 Rolf Kristian Andreassen. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import AuthenticationServices
import CryptoKit

class WelcomeViewController: UIViewController, GIDSignInDelegate {
    
    var currentNonce: String?
    var googleSignInButton: GIDSignInButton!
    
    var bookImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "bookIcon")
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()

        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
    }
    
    private func configureUI() {
        view.backgroundColor = backgroundColor
        let titleText = TitleLabel("Welcome to Days", 26, .center)
        let bodyText = BodyLabel("Keep track of all the exciting events in your life. \n  \n Share them with the world, \n or keep them private just for yourself.", 18, .center, .secondaryLabel)
        bodyText.numberOfLines = 0
        bodyText.adjustsFontSizeToFitWidth = true
        bodyText.minimumScaleFactor = 0.5
        
        let appleSignIn = ASAuthorizationAppleIDButton()
        appleSignIn.translatesAutoresizingMaskIntoConstraints = false
        appleSignIn.addTarget(self, action: #selector(didTapAppleButton), for: .touchUpInside)
        
        googleSignInButton = GIDSignInButton()
        googleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        googleSignInButton.style = .wide
        

        
        let otherSignIn = EnterButton("Other sign in method", 17, .label)
        otherSignIn.addTarget(self, action: #selector(otherSignInTapped), for: .touchUpInside)
        
        
        view.addSubview(bookImageView)
        view.addSubview(titleText)
        view.addSubview(bodyText)
        view.addSubview(appleSignIn)
        view.addSubview(googleSignInButton)
        view.addSubview(otherSignIn)

        let sidePadding: CGFloat = 50
        
        NSLayoutConstraint.activate([
            bookImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bookImageView.bottomAnchor.constraint(equalTo: titleText.topAnchor, constant: -25),
            bookImageView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.15),
            bookImageView.widthAnchor.constraint(equalTo: bookImageView.heightAnchor),
            
            titleText.bottomAnchor.constraint(equalTo: bodyText.topAnchor, constant: -15),
            titleText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sidePadding),
            titleText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sidePadding),
            titleText.heightAnchor.constraint(equalToConstant: 44),
            
            bodyText.bottomAnchor.constraint(equalTo: appleSignIn.topAnchor, constant: -80),
            bodyText.leadingAnchor.constraint(equalTo: titleText.leadingAnchor),
            bodyText.trailingAnchor.constraint(equalTo: titleText.trailingAnchor),
            bodyText.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.15),
            
            appleSignIn.bottomAnchor.constraint(equalTo: googleSignInButton.topAnchor, constant: -10),
            appleSignIn.leadingAnchor.constraint(equalTo: bodyText.leadingAnchor),
            appleSignIn.trailingAnchor.constraint(equalTo: bodyText.trailingAnchor),
            appleSignIn.heightAnchor.constraint(equalToConstant: 44),
            
            googleSignInButton.bottomAnchor.constraint(equalTo: otherSignIn.topAnchor, constant: -10),
            googleSignInButton.leadingAnchor.constraint(equalTo: bodyText.leadingAnchor),
            googleSignInButton.trailingAnchor.constraint(equalTo: bodyText.trailingAnchor),
            googleSignInButton.heightAnchor.constraint(equalToConstant: 44),
            
            otherSignIn.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -30),
            otherSignIn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sidePadding),
            otherSignIn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sidePadding),
            otherSignIn.heightAnchor.constraint(equalToConstant: 44)
            
        ])
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.userInterfaceStyle == .light {
            googleSignInButton.colorScheme = .light
        } else if traitCollection.userInterfaceStyle == .dark {
            googleSignInButton.colorScheme = .dark
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
    
    @objc private func otherSignInTapped() {
        let registerVC = RegisterViewController()
        present(registerVC, animated: true)
    }
    
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    
    private func addUserToDatabase(uid: String, email: String, username: String) {
        let usersRef = Firestore.firestore().collection("users")
        usersRef.document(uid).setData([
            "username": username,
            "email": email.lowercased(),
            "uid": Auth.auth().currentUser!.uid
        ])
    }
    
    private func goToProjects() {
        let navBar = UINavigationController(rootViewController: TabBarController())
        navBar.navigationBar.isHidden = true
        navBar.modalPresentationStyle = .fullScreen
        present(navBar, animated: true)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            return
        }
        
        guard let user = user else {return}
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
            self?.view.showAlert(alertText: error.localizedDescription)
            return
          }
          
            //Perform login
            let username = appleIDCredential.fullName?.givenName ?? "No name"
            let email = appleIDCredential.email ?? "No email"
            guard let uid = Auth.auth().currentUser?.uid else {return}

            self?.addUserToDatabase(uid: uid, email: email, username: username)
            self?.goToProjects()
        }
      }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        view.showAlert(alertText: error.localizedDescription)
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}
