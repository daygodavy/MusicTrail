//
//  ArtistImageView.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/19/23.
//

import UIKit

class ArtistImageView: UIImageView {
    let cache = NetworkManager.shared.cache
    let placeholderImage = UIImage(systemName: "questionmark")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        layer.cornerRadius = 5
        clipsToBounds = true
        image = placeholderImage
        tintColor = .systemGray
        contentMode = .scaleAspectFit
        translatesAutoresizingMaskIntoConstraints = false
    }
  
    func downloadArtistImage(_ url: URL) {
        Task {
            image = await NetworkManager.shared.downloadImage(from: url)?.withRenderingMode(.alwaysOriginal) ?? placeholderImage
        }
    }
    
    func setDefault() {
        image = placeholderImage
        tintColor = .systemGray
    }
    
}
