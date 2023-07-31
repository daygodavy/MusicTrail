//
//  ArtistCell.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/17/23.
//

import UIKit

class ArtistCell: UITableViewCell {

    static let identifier = "ArtistCell"
    
    // MARK: - Variables
    private(set) var artist: LibraryArtist!
    
    // MARK: - UI Components
    private let artistImage = ArtistImageView(frame: .zero)
    
    
    private var checkImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = .systemMint
        imageView.isHidden = true
        return imageView
    }()
    
    private var nameLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = .systemOrange
        titleLabel.textAlignment = .left
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.text = "Error"
        return titleLabel
    }()
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with artist: LibraryArtist) {
//        self.artistImage.setDefault()
        if let url = artist.imageUrl {
            self.artistImage.downloadArtistImage(url, artist: artist.name)
        }
        if artist.isSaved {
            checkImage.isHidden = false
        } else {
            checkImage.isHidden = true
        }
        self.artist = artist
        self.nameLabel.text = artist.name
    }
    
    
    // TODO: - Prepare for reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        artistImage.image = nil
    }
    
    
    
    // MARK: - UI Setup
    private func setupUI() {
        self.addSubview(artistImage)
        self.addSubview(nameLabel)
        self.addSubview(checkImage)
        
        artistImage.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        checkImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
//            artistImage.topAnchor.constraint(equalTo: self.topAnchor),
            artistImage.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
//            artistImage.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            artistImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            artistImage.heightAnchor.constraint(equalToConstant: 84),
            artistImage.widthAnchor.constraint(equalToConstant: 84),
            
            nameLabel.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: artistImage.trailingAnchor, constant: 50),
            nameLabel.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor),
            
            checkImage.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            checkImage.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            checkImage.heightAnchor.constraint(equalToConstant: 30),
            checkImage.widthAnchor.constraint(equalToConstant: 30)
            
        ])
    }
    
    
    

}
