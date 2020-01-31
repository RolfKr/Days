//
//  AddPostViewController.swift
//  Days
//
//  Created by Rolf Kristian Andreassen on 30/01/2020.
//  Copyright © 2020 Rolf Kristian Andreassen. All rights reserved.
//

import UIKit

class AddPostViewController: UIViewController {
    
    var postText: DetailTextView!
    var collectionView: UICollectionView!
    var images: [UIImage] = []
    var addFromLibrary: EnterButton!
    var addFromCamera: EnterButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }
    
    private func configureViews() {
        view.backgroundColor = backgroundColor
        createCollectionView()
        
        let titleLabel = TitleLabel("Create Post", 38, .left)
        view.addSubview(titleLabel)
        
        postText = DetailTextView("Write here...", .secondaryLabel, 15)
        view.addSubview(postText)
        
        setupButtons()
        
        NSLayoutConstraint.activate([
                   titleLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 50),
                   titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
                   titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
                   titleLabel.heightAnchor.constraint(equalToConstant: 44),
                   
                   postText.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
                   postText.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 0),
                   postText.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 0),
                   postText.heightAnchor.constraint(equalToConstant: view.frame.size.height * 0.4),
                   
                   addFromLibrary.topAnchor.constraint(equalTo: postText.bottomAnchor, constant: 0),
                   addFromLibrary.leadingAnchor.constraint(equalTo: postText.leadingAnchor, constant: 0),
                   addFromLibrary.widthAnchor.constraint(equalTo: postText.widthAnchor, multiplier: 0.5),
                   addFromLibrary.heightAnchor.constraint(equalToConstant: 44),
                   
                   addFromCamera.topAnchor.constraint(equalTo: postText.bottomAnchor, constant: 0),
                   addFromCamera.leadingAnchor.constraint(equalTo: addFromLibrary.trailingAnchor, constant: 0),
                   addFromCamera.widthAnchor.constraint(equalTo: postText.widthAnchor, multiplier: 0.5),
                   addFromCamera.heightAnchor.constraint(equalToConstant: 44),
                   
                   collectionView.topAnchor.constraint(equalTo: addFromLibrary.bottomAnchor, constant: 20),
                   collectionView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 0),
                   collectionView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 0),
                   collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
    }
    
    private func createCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(AddPostImageCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = backgroundColor
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
    
    private func setupButtons() {
        addFromLibrary = EnterButton("Photo Library", 20, .label)
        addFromLibrary.tag = 1
        addFromLibrary.layer.cornerRadius = 0
        addFromLibrary.addTarget(self, action: #selector(presentImagePicker(_:)), for: .touchUpInside)
        
        addFromCamera = EnterButton("Camera", 20, .label)
        addFromCamera.tag = 2
        addFromCamera.layer.cornerRadius = 0
        addFromCamera.addTarget(self, action: #selector(presentImagePicker(_:)), for: .touchUpInside)
        
        view.addSubview(addFromCamera)
        view.addSubview(addFromLibrary)
    }
    
    @objc private func presentImagePicker(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        if sender.tag == 1 {
            imagePicker.sourceType = .photoLibrary
        } else if sender.tag == 2 {
            imagePicker.sourceType = .camera
        }
        
        present(imagePicker, animated: true)
    }
}

extension AddPostViewController: UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! AddPostImageCell
        let image = images[indexPath.item]
        cell.configureCollectionViewCell(image)
        cell.closeButton.tag = indexPath.item
        cell.closeButton.addTarget(self, action: #selector(closeBtnTapped(_:)), for: .touchUpInside)
        return cell
    }
    
    @objc private func closeBtnTapped(_ sender: UIButton) {
        print("Remove image number \(sender.tag)")
        let imageNumber = sender.tag
        images.remove(at: imageNumber)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width / 2) - 5
        return CGSize(width: width, height: 110)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.editedImage] as? UIImage else {return}
        images.append(selectedImage)
        collectionView.reloadData()
        
        dismiss(animated: true, completion: nil)
    }
}

