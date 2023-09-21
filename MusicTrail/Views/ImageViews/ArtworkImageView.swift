//
//  ArtistImageView.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/19/23.
//

import UIKit

enum ArtworkStyle {
    case square
    case circle
}

class ArtworkImageView: UIImageView {
    
    let placeholderImage = SFSymbol.artistPlaceholder
    var fetchImageTask: Task<Void, Never>?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        fetchImageTask = nil
        configure()
    }
    
    init(frame: CGRect, style: ArtworkStyle) {
        super.init(frame: frame)
        fetchImageTask = nil
        configure(style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(style: ArtworkStyle = .square) {
        if style == .circle { layer.cornerRadius = 25 }
        else { layer.cornerRadius = 5 }
        
        clipsToBounds = true
        image = placeholderImage
        tintColor = .systemGray
        
        contentMode = .scaleAspectFit
        translatesAutoresizingMaskIntoConstraints = false
    }
  
    func downloadArtworkImage(_ url: URL?) {
        fetchImageTask?.cancel()
        
        guard let url = url else {
            setDefault()
            return
        }
        
        fetchImageTask = Task {
            image = await NetworkManager.shared.downloadImage(from: url)?.withRenderingMode(.alwaysOriginal) ?? placeholderImage
            tintColor = .systemGray
        }
    }
    
    func setDefault() {
        image = placeholderImage
        tintColor = .systemGray
    }

}
