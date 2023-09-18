//
//  MTAlertContainerView.swift
//  MusicTrail
//
//  Created by Davy Chuon on 9/18/23.
//

import UIKit

class MTAlertContainerView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .systemGray2
        layer.cornerRadius = 16
        layer.borderWidth = 2
        layer.borderColor = UIColor.darkGray.cgColor
        translatesAutoresizingMaskIntoConstraints = false
    }

}
