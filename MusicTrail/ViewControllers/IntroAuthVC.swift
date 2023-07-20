//
//  IntroAuthVC.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/20/23.
//

import UIKit

class IntroAuthVC: UIViewController {
    
    // MARK: - Variables
    
    // MARK: - UI Components
    private let introTitleLabel = MTTitleLabel(textAlignment: .left, fontSize: 60, textColor: .systemOrange)
    private let introBodyLabel = MTBodyLabel(textAlignment: .left, fontSize: 22, textColor: .secondaryLabel)
    private let startButton = MTButton(bgColor: .systemOrange, title: "Get Started", systemImageName: "chevron.forward")
    private let introImageView = UIImageView()


    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureUI()
    }
    
    
    // MARK: - Setup UI
    private func configureUI() {
        introTitleLabel.text = "Music Trail"
        introBodyLabel.text = "A simple way to track all new music releases from the artists you love."
        
        introImageView.image = UIImage(named: "introAuthImage")
        introImageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(introTitleLabel)
        view.addSubview(introImageView)
        view.addSubview(introBodyLabel)
        view.addSubview(startButton)
        
        NSLayoutConstraint.activate([
            introTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            introTitleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            introTitleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            introTitleLabel.heightAnchor.constraint(equalToConstant: 60),
            
            introBodyLabel.topAnchor.constraint(equalTo: introTitleLabel.bottomAnchor),
            introBodyLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            introBodyLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            introBodyLabel.heightAnchor.constraint(equalToConstant: 75),
            
            introImageView.topAnchor.constraint(equalTo: introBodyLabel.bottomAnchor, constant: 50),
            introImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            introImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            introImageView.heightAnchor.constraint(equalToConstant: 350),
            
            startButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40),
            startButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            startButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
}
