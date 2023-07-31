//
//  String+Ext.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/31/23.
//

import UIKit

extension String {
    
    func formatToCatalogArtworkURL() -> URL? {
        
        let urlString = self

        // Extract catalog artwork URL from library artwork URL
        if let urlComponents = URLComponents(string: urlString),
           let queryItems = urlComponents.queryItems,
           let aatItem = queryItems.first(where: { $0.name == "aat" }),
           let aatValue = aatItem.value,
           let aatURL = URL(string: aatValue) {
            
            // Replace default image dimensions with the specified image dimensions
            if let paths = urlComponents.string?.components(separatedBy: "?aat"),
               let newSizeIndex = paths.first?.lastIndex(of: "/"),
               let correctedSize = paths.first?[newSizeIndex...],
               let oldSizeIndex = aatURL.absoluteString.lastIndex(of: "/") {

                let urlPrefix = aatURL.absoluteString[..<oldSizeIndex]
                let urlSuffix = "bb.jpg"
                let finalURL = String(urlPrefix + correctedSize + urlSuffix)

                return URL(string: finalURL) ?? aatURL
            }
            
            return aatURL
        }
        
        return nil
    }
}
