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
        
        repeat {
            do {
                return try await operation()
            } catch {
                if retryCount < maxRetries {
                    retryCount += 1
                    
                    // Implement exponential backoff:
                    // Exponential backoff
                    let delaySeconds = pow(2.0, Double(retryCount))
                    
                    // Maximum delay (e.g., 1 minute)
                    let maxDelaySeconds = 60.0
                    let retryDelay = min(delaySeconds, maxDelaySeconds)
                    
                    print("Retrying in \(retryDelay) seconds (Retry \(retryCount) of \(maxRetries))")
                    
                    // Convert seconds to nanoseconds
                    let nanoseconds = UInt64(retryDelay * 1_000_000_000)
                    
                    // Use Task.sleep(nanoseconds:) to delay the retry
                    try await Task.sleep(nanoseconds: nanoseconds)
                } else {
                    throw error
                }
            }
        } while true
    }
    
    enum NetworkError: Error {
        
    }
    
}
