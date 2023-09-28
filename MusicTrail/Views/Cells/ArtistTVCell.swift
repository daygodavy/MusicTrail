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
    case adding
}

class ArtistTVCell: UITableViewCell {

    static let identifier = "ArtistCell"
    
    // MARK: - Variables
    private(set) var artist: MTArtist!
    
    // MARK: - UI Components
    private let artistImage = ArtworkImageView(frame: .zero, style: .circle)
    
    private var checkImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = SFSymbol.checkmark
        imageView.tintColor = .systemMint
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var nameLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = .systemOrange
        titleLabel.textAlignment = .left
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.text = "Error"
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
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
    
    
    // TODO: - Prepare for reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        artistImage.image = nil
    }
    
    func configure(with artist: MTArtist, state: ArtistViewState) {
        
        self.artistImage.downloadArtworkImage(artist.imageUrl)
        self.artist = artist
        self.nameLabel.text = artist.name
        setCheckmark(state)
    }
    
    private func setCheckmark(_ state: ArtistViewState) {
        if state == .library {
            updateCheckmark(artist.isTracked)
        } else {
            checkImage.isHidden = true
        }
    }
    
    func updateCheckmark(_ isTracked: Bool) {
        if isTracked { checkImage.isHidden = false }
        else { checkImage.isHidden = true }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.addSubview(artistImage)
        self.addSubview(nameLabel)
        self.addSubview(checkImage)
        
        NSLayoutConstraint.activate([
            artistImage.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            artistImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            artistImage.heightAnchor.constraint(equalToConstant: 50),
            artistImage.widthAnchor.constraint(equalToConstant: 50),
            
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
