//
//  ArtistCell.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/17/23.
//


import UIKit

enum ArtistViewState {
    case library
    case saved
}

class ArtistTVCell: UITableViewCell {

    static let identifier = "ArtistCell"
    
    // MARK: - Variables
    private(set) var artist: MTArtist!
    
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
        titleLabel.numberOfLines = 0
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
    
    public func configure(with artist: MTArtist, state: ArtistViewState) {
        if let url = artist.imageUrl {
            self.artistImage.downloadArtistImage(url, artist: artist.name)
        }
        
        self.artist = artist
        self.nameLabel.text = artist.name
        updateCheck(state)
    }
    
    private func updateCheck(_ state: ArtistViewState) {
        if artist.isTracked && state == .library {
            checkImage.isHidden = false
        } else {
            checkImage.isHidden = true
        }
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
            artistImage.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            artistImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            artistImage.heightAnchor.constraint(equalToConstant: 80),
            artistImage.widthAnchor.constraint(equalToConstant: 80),
            
            checkImage.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            checkImage.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
            checkImage.heightAnchor.constraint(equalToConstant: 30),
            checkImage.widthAnchor.constraint(equalToConstant: 30),
            
            nameLabel.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: artistImage.trailingAnchor, constant: 30),
            nameLabel.trailingAnchor.constraint(equalTo: checkImage.leadingAnchor, constant: -5),
            nameLabel.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor)
        ])
    }
}
