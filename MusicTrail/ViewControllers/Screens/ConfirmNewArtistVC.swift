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
    
    let avatarImage = ArtworkImageView(frame: .zero)
    let promptLabel = MTTitleLabel(textAlignment: .center, fontSize: 20, textColor: .white)
    let artistLabel = MTBodyLabel(textAlignment: .center, fontSize: 18, textColor: .systemOrange)
    
    let containerView: UIView = {
       let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.99)
        containerView.layer.borderWidth = 1.0
        containerView.layer.borderColor = UIColor.tertiarySystemBackground.cgColor
        containerView.layer.cornerRadius = 20
        return containerView
    }()
    
    
    let followButton: UIButton = {
        let followButton = UIButton()
        followButton.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(systemName: "person.crop.circle.badge.plus")?.withTintColor(.green, renderingMode: .alwaysOriginal)
        followButton.setImage(image, for: .normal)
        followButton.backgroundColor = .tertiarySystemBackground
        followButton.layer.cornerRadius = 25
        followButton.layer.borderWidth = 2
        followButton.layer.borderColor = UIColor.systemGreen.cgColor
        followButton.addTarget(self, action: #selector(followButtonTapped), for: .touchUpInside)
        return followButton
    }()
    
    let cancelButton: UIButton = {
        let cancelButton = UIButton()
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(systemName: "xmark.octagon")?.withTintColor(.red, renderingMode: .alwaysOriginal)
        cancelButton.setImage(image, for: .normal)
        cancelButton.backgroundColor = .tertiarySystemBackground
        cancelButton.layer.cornerRadius = 25
        cancelButton.layer.borderWidth = 2
        cancelButton.layer.borderColor = UIColor.systemRed.cgColor
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return cancelButton
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        configureArtist()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController!.setViewControllers([self], animated: false)
    }
    
    @objc func followButtonTapped() {
//        if let mtArtist = mtArtist {
//            delegate?.saveNewArtist(mtArtist)
//        }
        
        // TODO: -
        // Dismiss the ConfirmNewArtistVC
        
    }
    
    @objc func cancelButtonTapped() {
        if let navigationController = self.navigationController {
            navigationController.dismiss(animated: true)
        }
    }
    
    
    private func configureArtist() {
        avatarImage.downloadArtworkImage(mtArtist?.imageUrl)
        avatarImage.layer.cornerRadius = 10
        promptLabel.text = "Please confirm below"
        artistLabel.text = mtArtist?.name
    }
    
    private func setupUI(){
        view.addSubview(containerView)
        containerView.addSubview(promptLabel)
        containerView.addSubview(avatarImage)
        containerView.addSubview(artistLabel)
        containerView.addSubview(cancelButton)
        containerView.addSubview(followButton)
        
        NSLayoutConstraint.activate([
//            containerView.topAnchor.constraint(equalTo: view.topAnchor),
//            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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
