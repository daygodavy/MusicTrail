//
//  MTDataLoadingVC.swift
//  MusicTrail
//
//  Created by Davy Chuon on 9/7/23.
//

import UIKit

class MTDataLoadingVC: UIViewController {
    
    var containerView: UIView!
    var emptyStateView: MTEmptyStateView!
    
    func showLoadingNavBarButton() {
        let spinner = UIActivityIndicatorView(style: .medium)
        let navBarSpinner = UIBarButtonItem(customView: spinner)
        
        navigationItem.rightBarButtonItems = [navBarSpinner]
        navigationItem.leftBarButtonItems = nil
        spinner.startAnimating()
    }
    
    func dismissLoadingNavBarButton() {
        navigationItem.rightBarButtonItem = nil
    }
    
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
    
    func showEmptyStateView(for state: CurrentView, in view: UIView) {
        emptyStateView = MTEmptyStateView(in: state)
        emptyStateView.frame = view.bounds
        view.addSubview(emptyStateView)
    }
    
    func hideEmptyStateView() {
        DispatchQueue.main.async {
            self.emptyStateView.removeFromSuperview()
            self.emptyStateView = nil
        }
    }
}
