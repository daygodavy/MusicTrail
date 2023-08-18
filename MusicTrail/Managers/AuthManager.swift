//
//  LoginManager.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/20/23.
//

import MusicKit
import UIKit

class AuthManager {
    
    static let shared = AuthManager()
    
    func checkAuthorizationStatus() async -> Bool {
        let status = await MusicAuthorization.request()
        
        switch status {
        case .authorized:
            print("User authorized access to their music library.")
            // transition to importVC or tabVC
            return true
        case .denied:
            print("User denied access to their music library.")
            // present screen access denied; change settings
            return false
        case .notDetermined:
            print("User denied access to their music library.")
            return false
        case .restricted:
            // present screen access denied; device restriction
            print("User device is restricted.")
            return false
        @unknown default:
            print("Something went wrong with checking authorization.")
            return false
        }
    }
    
    func checkAppleMusicStatus() async -> Bool {
        do {
            return try await MusicSubscription.current.canPlayCatalogContent
        } catch {
            print("Something went wrong with checking Apple Music status.")
            return false
        }
    }
}
