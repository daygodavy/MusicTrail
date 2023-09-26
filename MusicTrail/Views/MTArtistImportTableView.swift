//
//  MTArtistTableView.swift
//  MusicTrail
//
//  Created by Davy Chuon on 9/25/23.
//

import UIKit

class MTArtistImportTableView: UIView {
    
    let containerView: UIView = {
       let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()

    let tableView: UITableView = {
       let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let importButton: UIButton = {
        let importButton = UIButton()
        importButton.translatesAutoresizingMaskIntoConstraints = false
        return importButton
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    private func setupViews() {
        addSubview(containerView)
        containerView.addSubview(tableView)
        containerView.addSubview(importButton)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            tableView.topAnchor.constraint(equalTo: containerView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            importButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 140),
            importButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -140),
            importButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -100),
            importButton.heightAnchor.constraint(equalToConstant: 50),
        ])

    }
    
}
