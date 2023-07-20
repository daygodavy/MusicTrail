//
//  MTButton.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/20/23.
//

import UIKit

class MTButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init (bgColor: UIColor, title: String, systemImageName: String) {
        self.init(frame: .zero)
        setupUI(bgColor, title, systemImageName)
    }
    
    private func configure() {
        configuration = .borderedTinted()
        configuration?.cornerStyle = .medium
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupUI(_ color: UIColor, _ title: String, _ imageName: String) {
        configuration?.baseBackgroundColor = color
        configuration?.baseForegroundColor = color
        
        configuration?.image = UIImage(systemName: imageName)
        configuration?.imagePadding = 10
        configuration?.imagePlacement = .trailing
        
        configuration?.attributedTitle = AttributedString(title)
        configuration?.attributedTitle?.font = UIFont.systemFont(ofSize: 24)
    }

}
