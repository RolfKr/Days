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
    var selectedImage: UIImage!
    var delegate: AddProjectDelegate?
    var enterButton: EnterButton!
    
    var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4
        return view
    }()
    
    var backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        return view
    }()
    
    var addImagebutton: EnterButton = {
        let button = EnterButton("", 17, .secondaryLabel)
        button.tag = 1
        button.contentHorizontalAlignment = .center
        button.setTitle("Add photo", for: .normal)
        button.tintColor = .label
        button.backgroundColor = viewBackground
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(chooseImage), for: .touchUpInside)
        return button
    }()
    
    
    var isSharedBtn: UISwitch {
        let switchBtn = UISwitch()
        switchBtn.translatesAutoresizingMaskIntoConstraints = false
        switchBtn.addTarget(self, action: #selector(sharedTapped), for: .touchUpInside)
        return switchBtn
    }
    
    @objc private func sharedTapped() {
        print("Shared tapped")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        heightConstant = view.frame.size.height
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        
        configureViews()
        animateLoadView()
        addSwipeGesture()
        dismissKeyboard(on: view)
    }


    private func configureViews() {
        view.addSubview(backgroundView)
        view.addSubview(containerView)
        dismissView(on: backgroundView)
        
        let titleLabel = TitleLabel("Create Journal", 32, .left)
        containerView.backgroundColor = backgroundColor
        containerView.addSubview(titleLabel)
        
        nameInputView = InputView("Enter name")
        nameInputView.textField.textAlignment = .center
        nameInputView.becomeFirstResponder()
        containerView.addSubview(nameInputView)
        
        detailText = DetailTextView("Enter details about your project", .secondaryLabel, 15)
        detailText.delegate = self
        containerView.addSubview(detailText)
        
        let buttonStack2 = UIStackView(arrangedSubviews: [addImagebutton, isSharedBtn])
        buttonStack2.translatesAutoresizingMaskIntoConstraints = false
        buttonStack2.distribution = .fillEqually
        buttonStack2.alignment = .center
        buttonStack2.spacing = 20
        
        containerView.addSubview(buttonStack2)
        
        enterButton = EnterButton("Enter", 20, .label)
        enterButton.addTarget(self, action: #selector(createProject), for: .touchUpInside)
        let exitButton = EnterButton("Exit", 20, .label)
        exitButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        
        let buttonStack = UIStackView(arrangedSubviews: [enterButton, exitButton])
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 20
        containerView.addSubview(buttonStack)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
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
            
            buttonStack2.topAnchor.constraint(equalTo: detailText.bottomAnchor, constant: 15),
            buttonStack2.leadingAnchor.constraint(equalTo: detailText.leadingAnchor, constant: 50),
            buttonStack2.trailingAnchor.constraint(equalTo: detailText.trailingAnchor, constant: -50),
            buttonStack2.heightAnchor.constraint(equalToConstant: 45),

            
            buttonStack.topAnchor.constraint(equalTo: addImagebutton.bottomAnchor, constant: 20),
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
    
    private func dismissView(on view: UIView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
        view.addGestureRecognizer(tap)
    }

    private func addSwipeGesture() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(dismissVC))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }
    
    @objc private func createProject() {
        let uuid = UUID().uuidString
        enterButton.isUserInteractionEnabled = false
        showActivityIndicator(view: view)
        uploadImage(uuid: uuid)
    }
    
    private func uploadImage(uuid: String) {
        let storageRef = Storage.storage().reference().child("projects").child("\(uuid).jpg")
        var imageData: Data!
        
        if let selectedImage = selectedImage {
            imageData = selectedImage.jpegData(compressionQuality: 0.75)
        } else {
            imageData = UIImage(named: "sampleJournal")?.jpegData(compressionQuality: 0.75)
        }
        
        let uploadMetadata = StorageMetadata.init()
        uploadMetadata.contentType = "image/jpeg"
        
        storageRef.putData(imageData, metadata: uploadMetadata) { (metaData, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let _ = metaData {
                self.addToDatabase(uuid: uuid)
            }
        }
    }
    
    private func addToDatabase(uuid: String) {
        
        guard let name = nameInputView.textField.text else {return} // TODO: ADD A WARNING IF EMPTY
        guard let detailText = detailText.text else {return} // TODO: ADD WARNING HERE AS WELL
        guard let currentUser = Auth.auth().currentUser?.email else {return}
        
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
    
    @objc private func chooseImage() {
        let alertController = UIAlertController(title: "From what source?", message: "", preferredStyle: .actionSheet)
        let library = UIAlertAction(title: "Photo Library", style: .default) { (_) in
            self.presentImagePicker("Library")
        }
        let camera = UIAlertAction(title: "Camera", style: .default) { (_) in
            self.presentImagePicker("Camera")
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { (_) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(library)
        alertController.addAction(camera)
        alertController.addAction(cancel)
        
        present(alertController, animated: true)
    }
    
    private func presentImagePicker(_ chosenSource: String) {
        let imagePicker = UIImagePickerController()
        
        if chosenSource == "Library" {
            imagePicker.sourceType = .photoLibrary
        } else if chosenSource == "Camera" {
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
        
        selectedImage = image
        addImagebutton.setImage(image, for: .normal)
        addImagebutton.layer.borderWidth = 0
        addImagebutton.backgroundColor = backgroundColor
        
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
