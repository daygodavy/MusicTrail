//
//  MTEmptyStateView.swift
//  MusicTrail
//
//  Created by Davy Chuon on 9/21/23.
//

import UIKit

enum CurrentView {
    case noCatalogArtistsResults
    case noLibraryArtistsResults
    case noSavedArtists
    case noSavedRecords
}

class MTEmptyStateView: UIView {
    
    let titlePromptLabel = MTTitleLabel(textAlignment: .center, fontSize: 20, textColor: .systemGray)
    
    let bodyPromptLabel = MTBodyLabel(textAlignment: .center, fontSize: 16, textColor: .systemGray2)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(in state: CurrentView) {
        self.init(frame: .zero)
        setPromptLabel(state)
    }
    
    private func setPromptLabel(_ state: CurrentView) {
        switch state {
        case .noCatalogArtistsResults:
            bodyPromptLabel.text = "No results found \n Try a new search."
        case .noLibraryArtistsResults:
            bodyPromptLabel.text = "No results found \n Your music library is empty!"
        case .noSavedArtists:
            titlePromptLabel.text = "Start following artists to see them here!"
            bodyPromptLabel.text = "You can import them from your music library or search them up. \n\nUse the buttons in the top right to begin."
        case .noSavedRecords:
            bodyPromptLabel.text = "No releases available. \n Find your favorite artists in the 'Artists' tab to start your Music Trail!"
        }
    }
    
    private func setupUI() {
        self.addSubview(bodyPromptLabel)
        self.addSubview(titlePromptLabel)
        
        let padding: CGFloat = 25
        NSLayoutConstraint.activate([

            bodyPromptLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -padding),
            bodyPromptLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
            bodyPromptLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding),
            bodyPromptLabel.heightAnchor.constraint(equalToConstant: 200),
            
            titlePromptLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
            titlePromptLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding),
            titlePromptLabel.bottomAnchor.constraint(equalTo: bodyPromptLabel.topAnchor),
            titlePromptLabel.heightAnchor.constraint(equalToConstant: 25),
        ])
    }
}
