//
//  MTDataLoadingVC.swift
//  MusicTrail
//
//  Created by Davy Chuon on 9/7/23.
//

import UIKit

class MTDataLoadingVC: UIViewController {
    
    var containerView: UIView!

    func showLoadingView() {
        containerView = UIView(frame: view.bounds)
        view.addSubview(containerView)
        containerView.backgroundColor = .systemBackground.withAlphaComponent(0)
        
        UIView.animate(withDuration: 0.25) {
            self.containerView.alpha = 0.8
        }
        
        let spinner = UIActivityIndicatorView(style: .large)
        containerView.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            spinner.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            spinner.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        
        spinner.startAnimating()
    }
    
    func dismissLoadingView() {
        DispatchQueue.main.async {
            self.containerView.removeFromSuperview()
            self.containerView = nil
        }
    }
}
