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
    
    
    // MARK: - Methods
    @objc func startButtonTapped() {
        var permissionStatus = false
        var appleMusicStatus = false
        
        // request access to user's music data
        Task {
            permissionStatus = await LoginManager.shared.checkAuthorizationStatus()
            print("permissionStatus: \(permissionStatus)")
            
            if permissionStatus {
                // confirm apple music subscription
                appleMusicStatus = await LoginManager.shared.checkAppleMusicStatus()
                
                if appleMusicStatus {
                    // both confirmed -> continue
                    print("Success: both confirmed")
                    presentTabBarVC()
                } else {
                    // no apple music subscription
                    // show VC that they're blocked
                    print("Sorry you need Apple Music")
                }
            } else {
                // permission not granted
                // show VC that they're blocked
                print("Sorry you need to provide permission to access")
            }
        }
    }
    
    private func presentTabBarVC() {
        let tabBarVC = MTTabBarController()
        let navController = UINavigationController(rootViewController: tabBarVC)
        navController.modalPresentationStyle = .fullScreen
        navController.modalTransitionStyle = .crossDissolve
        present(navController, animated: true)
    }
    
    
    // MARK: - Setup UI
    private func configureUI() {
        introTitleLabel.text = "Music Trail"
        introBodyLabel.text = "A simple way to track new music releases from all the artists you love."
        
        introImageView.image = UIImage(named: "introAuthImage")
        introImageView.translatesAutoresizingMaskIntoConstraints = false
        
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
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
