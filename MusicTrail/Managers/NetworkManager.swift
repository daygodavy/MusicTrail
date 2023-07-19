//
//  NetworkManager.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/19/23.
//

import UIKit

class NetworkManager {
    
    static let shared = NetworkManager()
    let cache = NSCache<NSString, UIImage>()
    
    private init() {}
    
    public func downloadImage(from url: URL) async -> UIImage? {
        
        let cacheKey = NSString(string: url.absoluteString)
        
        if let image = cache.object(forKey: cacheKey) { return image }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            
            cache.setObject(image, forKey: cacheKey)
            return image
        } catch {
            return nil
        }
    }
    
//    func formatToCatalogArtworkURL(_ url: URL) -> URL {
//        let urlString = url.absoluteString
//        print("STARTING NOW")
//        print(urlString)
//        
//        
//        if let urlComponents = URLComponents(string: urlString),
//           let queryItems = urlComponents.queryItems,
//           let aatItem = queryItems.first(where: { $0.name == "aat" }),
//           let aatValue = aatItem.value,
//           let aatURL = URL(string: aatValue) {
//            print(aatURL.absoluteString)
//            print("=========")
//            return aatURL
//        }
//        
//        
//        
//        return url
//    }
}
