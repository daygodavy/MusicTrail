//
//  MonthSectionHeaderView.swift
//  MusicTrail
//
//  Created by Davy Chuon on 9/20/23.
//

import UIKit

class MonthSectionHeaderView: UICollectionReusableView {
    
    static let reuseID = "MonthSectionHeaderView"
    
    private let titleLabel = MTTitleLabel(textAlignment: .left, fontSize: 30, textColor: .label)
    
    private let separatorView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemBackground
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(separatorView)
        addSubview(titleLabel)
        
        let padding: CGFloat = 12
        
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    func set(with monthSection: MonthSection, firstSection: Bool) {
        titleLabel.text = monthSection.monthYear
        showSeparatorView(firstSection)
    }
    
    private func showSeparatorView(_ show: Bool) {
        separatorView.isHidden = !show
    }
    
}

