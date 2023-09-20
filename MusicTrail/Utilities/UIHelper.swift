//
//  UIHelper.swift
//  MusicTrail
//
//  Created by Davy Chuon on 9/6/23.
//

import UIKit

enum UIHelper {
    
    static func createColumnFlowLayout(in view: UIView, numCols: CGFloat) -> UICollectionViewFlowLayout {
        let width = view.bounds.width
        let padding: CGFloat = 12
        var botPadding: CGFloat = 12
        let minimumItemSpacing: CGFloat = 10
        let availableWidth = width - (padding * 2) - (minimumItemSpacing * 2)
        let itemWidth = availableWidth / numCols
        var itemHeight = itemWidth
        
        let flowLayout = UICollectionViewFlowLayout()
        
        if numCols == 3 {
            itemHeight += 30
        } else {
            botPadding += 20
            flowLayout.minimumLineSpacing = 25.0
            flowLayout.headerReferenceSize = CGSize(width: width, height: 40)
        }
        
        flowLayout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: botPadding, right: padding)
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        
        return flowLayout
    }
}
