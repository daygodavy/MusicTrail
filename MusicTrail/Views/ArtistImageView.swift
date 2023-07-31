//
//  ArtistImageView.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/19/23.
//

import UIKit


class ArtistImageView: UIImageView {
    
    let placeholderImage = UIImage(systemName: "questionmark")
    var fetchImageTask: Task<Void, Never>?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        fetchImageTask = nil
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
  
    func downloadArtistImage(_ url: URL, artist: String) {
        fetchImageTask?.cancel()
        fetchImageTask = Task {
            image = await NetworkManager.shared.downloadImage(from: url)?.withRenderingMode(.alwaysOriginal) ?? placeholderImage
        }
    }
    
    func setDefault() {
        image = nil
        image = placeholderImage
        tintColor = .systemGray
    }

}
