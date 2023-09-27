//
//  ConfirmNewArtistVC.swift
//  MusicTrail
//
//  Created by Davy Chuon on 9/25/23.
//

import UIKit

protocol ConfirmNewArtistVCDelegate: AnyObject {
    func saveNewArtist(_ newArtist: MTArtist)
}

class ConfirmNewArtistVC: UIViewController {
    
    var mtArtist: MTArtist? = nil
    weak var delegate: ConfirmNewArtistVCDelegate?
    var onDismiss: (() -> Void)?
    
    let avatarImage = ArtworkImageView(frame: .zero)
    let promptLabel = MTTitleLabel(textAlignment: .center, fontSize: 20, textColor: .white)
    let artistLabel = MTBodyLabel(textAlignment: .center, fontSize: 18, textColor: .systemOrange)

    let containerView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemBackground
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.tertiarySystemBackground.cgColor
        view.layer.cornerRadius = 20
        return view
    }()
    
    
    let followButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(systemName: "person.crop.circle.badge.plus")?.withTintColor(.green, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.backgroundColor = .tertiarySystemBackground
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemGreen.cgColor
        button.addTarget(self, action: #selector(followButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(systemName: "xmark.octagon")?.withTintColor(.red, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.backgroundColor = .tertiarySystemBackground
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemRed.cgColor
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        configureArtist()
    }
    
    @objc func followButtonTapped() {
//        if let mtArtist = mtArtist {
//            delegate?.saveNewArtist(mtArtist)
//        }
        
        // TODO: -
        // Dismiss the ConfirmNewArtistVC
        confirmSaveNewArtist()
        
    }
    
    @objc func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    private func confirmSaveNewArtist() {
        dismiss(animated: true) {
            self.onDismiss?()
        }
        // save artist from delegate closure in previous class
    }
    
    private func configureArtist() {
        avatarImage.downloadArtworkImage(mtArtist?.imageUrl)
        avatarImage.layer.cornerRadius = 10
        promptLabel.text = "Please confirm below"
        artistLabel.text = mtArtist?.name
    }
    
    private func setupUI(){
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        view.addSubview(containerView)
        containerView.addSubview(promptLabel)
        containerView.addSubview(avatarImage)
        containerView.addSubview(artistLabel)
        containerView.addSubview(cancelButton)
        containerView.addSubview(followButton)
        
        NSLayoutConstraint.activate([
            
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.heightAnchor.constraint(equalToConstant: view.bounds.height / 3),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            promptLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            promptLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            promptLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            promptLabel.heightAnchor.constraint(equalToConstant: 30),
            
            avatarImage.topAnchor.constraint(equalTo: promptLabel.bottomAnchor, constant: 10),
            avatarImage.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            avatarImage.widthAnchor.constraint(equalToConstant: 145),
            avatarImage.heightAnchor.constraint(equalToConstant: 145),
            
            artistLabel.topAnchor.constraint(equalTo: avatarImage.bottomAnchor, constant: 10),
            artistLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            artistLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            artistLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15),
            cancelButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25),
            cancelButton.heightAnchor.constraint(equalToConstant: 50),
            cancelButton.widthAnchor.constraint(equalToConstant: 50),
            
            followButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15),
            followButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -25),
            followButton.heightAnchor.constraint(equalToConstant: 50),
            followButton.widthAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    
    
}
