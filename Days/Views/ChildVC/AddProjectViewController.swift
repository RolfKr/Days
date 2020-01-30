//
//  AddProjectViewController.swift
//  Days
//
//  Created by Rolf Kristian Andreassen on 29/01/2020.
//  Copyright © 2020 Rolf Kristian Andreassen. All rights reserved.
//

import UIKit
import Firebase

protocol  AddProjectDelegate {
    func didFinishAddingProject(_ project: Project)
}

class AddProjectViewController: UIViewController {
    
    var centerYConstant: NSLayoutConstraint!
    var heightConstant: CGFloat!
    var nameInputView: InputView!
    var detailText: DetailTextView!

    var delegate: AddProjectDelegate?
    
    var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4
        return view
    }()
    
    var addImagePhotoLibrary: EnterButton = {
        let button = EnterButton("", 17, .secondaryLabel)
        button.tag = 1
        button.contentHorizontalAlignment = .center
        button.setImage(UIImage(systemName: "photo"), for: .normal)
        button.tintColor = .label
        button.backgroundColor = viewBackground
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(presentImagePicker(_:)), for: .touchUpInside)
        return button
    }()
    
    var addImageCamera: EnterButton = {
        let button = EnterButton("", 17, .secondaryLabel)
        button.tag = 2
        button.contentHorizontalAlignment = .center
        button.setImage(UIImage(systemName: "camera"), for: .normal)
        button.tintColor = .label
        button.backgroundColor = viewBackground
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(presentImagePicker(_:)), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        heightConstant = view.frame.size.height
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        configureViews()
        animateLoadView()
        addSwipeGesture()
        
    }

    private func configureViews() {
        view.addSubview(containerView)
        
        let titleLabel = TitleLabel("Create Project", 32, .left)
        containerView.backgroundColor = backgroundColor
        containerView.addSubview(titleLabel)
        
        nameInputView = InputView("Enter name")
        nameInputView.textField.textAlignment = .center
        nameInputView.becomeFirstResponder()
        containerView.addSubview(nameInputView)
        
        detailText = DetailTextView("Enter details about your project", .secondaryLabel, 15)
        detailText.delegate = self
        containerView.addSubview(detailText)
        
        let buttonImageStackview = UIStackView(arrangedSubviews: [addImagePhotoLibrary, addImageCamera])
        buttonImageStackview.translatesAutoresizingMaskIntoConstraints = false
        buttonImageStackview.distribution = .fillEqually
        buttonImageStackview.spacing = 20
        
        containerView.addSubview(buttonImageStackview)
        
        let enterButton = EnterButton("Enter", 20, .label)
        enterButton.addTarget(self, action: #selector(createProject), for: .touchUpInside)
        let exitButton = EnterButton("Exit", 20, .label)
        exitButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        
        let buttonStack = UIStackView(arrangedSubviews: [enterButton, exitButton])
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 20
        containerView.addSubview(buttonStack)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 325),
            containerView.widthAnchor.constraint(equalToConstant: view.frame.width * 0.8),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.heightAnchor.constraint(equalToConstant: 32),
            
            nameInputView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            nameInputView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            nameInputView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            nameInputView.heightAnchor.constraint(equalToConstant: 40),
            
            detailText.topAnchor.constraint(equalTo: nameInputView.bottomAnchor, constant: 10),
            detailText.leadingAnchor.constraint(equalTo: nameInputView.leadingAnchor),
            detailText.trailingAnchor.constraint(equalTo: nameInputView.trailingAnchor),
            detailText.heightAnchor.constraint(equalToConstant: 75),
            
            buttonImageStackview.topAnchor.constraint(equalTo: detailText.bottomAnchor, constant: 15),
            buttonImageStackview.leadingAnchor.constraint(equalTo: detailText.leadingAnchor, constant: 40),
            buttonImageStackview.trailingAnchor.constraint(equalTo: detailText.trailingAnchor, constant: -40),
            buttonImageStackview.heightAnchor.constraint(equalToConstant: 35),
            
            buttonStack.topAnchor.constraint(equalTo: buttonImageStackview.bottomAnchor, constant: 20),
            buttonStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 50),
            buttonStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -50),
            buttonStack.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        centerYConstant = containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: heightConstant)
        centerYConstant.isActive = true
        view.layoutIfNeeded()
    }
    
    private func animateLoadView() {
        
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: .curveEaseInOut, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.65)
            self.centerYConstant.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
    private func addSwipeGesture() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(dismissVC))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }
    
    @objc private func createProject() {
        guard let name = nameInputView.textField.text else {return} // TODO: ADD A WARNING IF EMPTY
        guard let detailText = detailText.text else {return} // TODO: ADD WARNING HERE AS WELL
        guard let currentUser = Auth.auth().currentUser?.email else {return}
        
        let uuid = UUID().uuidString
        let storageRef = Storage.storage().reference().child("projects").child("\(uuid).jpg")
        guard let imageData = addImagePhotoLibrary.imageView?.image?.jpegData(compressionQuality: 0.75) else {return}
        let uploadMetadata = StorageMetadata.init()
        uploadMetadata.contentType = "image/jpeg"
        
        storageRef.putData(imageData, metadata: uploadMetadata) { (metaData, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
                    
            let randomProjectID = UUID().uuidString
            let projectsDB = Firestore.firestore().collection("projects").document(randomProjectID)
            projectsDB.setData([
                "name" : name,
                "detailText" : detailText,
                "addedBy" : currentUser,
                "created" : self.getTimeNow(),
                "imageID" : "\(uuid).jpg",
                "projectID" : randomProjectID
            ])
            
            let project = Project(name: name, detail: detailText, addedBy: currentUser, created: self.getTimeNow(), imageURL: "\(uuid).jpg", projectID: randomProjectID)
            
            self.delegate?.didFinishAddingProject(project)
            self.dismissVC()
        }
    }
    
    private func getTimeNow() -> String {
        let timeNow = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: timeNow)
    }
    
    @objc private func dismissVC() {
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: .curveEaseInOut, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.centerYConstant.constant = self.heightConstant
            self.view.layoutIfNeeded()
        }) { (finished) in
            if finished {
                let childVC = self
                childVC.willMove(toParent: nil)
                childVC.removeFromParent()
                childVC.view.removeFromSuperview()
            }
        }
    }
    
    @objc private func presentImagePicker(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        
        if sender.tag == 1 {
            imagePicker.sourceType = .photoLibrary
        } else if sender.tag == 2 {
            imagePicker.sourceType = .camera
        }
        
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
}

extension AddProjectViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.editedImage] as! UIImage
        addImagePhotoLibrary.setImage(image, for: .normal)
        addImagePhotoLibrary.backgroundColor = backgroundColor
        picker.dismiss(animated: true, completion: nil)
    }
}

extension AddProjectViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Enter details about your project" {
            textView.text = ""
        }
    }
}
