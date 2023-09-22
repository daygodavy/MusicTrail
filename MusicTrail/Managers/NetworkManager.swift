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
    
    
    public func retry<T>(_ maxRetries: Int, operation: @escaping () async throws -> T) async throws -> T {
        var retryCount = 0
        while true {
            do {
                return try await operation()
            } catch {
                if retryCount < maxRetries {
                    retryCount += 1
                    let delaySeconds = pow(2.0, Double(retryCount))
                    let maxDelaySeconds = 120.0  // Increased max delay to 2 minutes
                    let retryDelay = min(delaySeconds, maxDelaySeconds)
                    
                    // Adding jitter
                    let jitter = Double.random(in: 0.5..<1.5)
                    let totalDelay = retryDelay * jitter
                    
                    Logger.shared.debug("Retrying in \(totalDelay) seconds (Retry \(retryCount) of \(maxRetries))")
                    
                    let nanoseconds = UInt64(totalDelay * 1_000_000_000)
                    try await Task.sleep(nanoseconds: nanoseconds)
                } else {
                    throw error
                }
            }
        }
    }

    
    enum NetworkError: Error {
        
    }
    
}
