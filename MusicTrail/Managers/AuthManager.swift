//
//  LoginManager.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/20/23.
//

import MusicKit
import UIKit

class AuthManager {
    
    private func checkAuthorizationStatus() async throws -> Bool {
        guard MusicAuthorization.currentStatus != .authorized else { return true }
        
        let status = await MusicAuthorization.request()
        
        switch status {
        case .authorized:
            // user accepted permission to use MusicKit
            return true
        case .denied:
            // user denied permission to use MusicKit
            throw MTError.permissionDenied
        case .notDetermined:
            // user permission has not been determined yet
            throw MTError.permissionNotDetermined
        case .restricted:
            // user's device incapable of using MusicKit
            throw MTError.permissionRestricted
        @unknown default:
            throw MTError.unknown
        }
    }
    
    
    func ensureAuthorization() async throws {
        do {
            try await checkAuthorizationStatus()
        } catch {
            throw error
        }
    }


    func checkAppleMusicStatus() async {
        // check if canPlayCatalogContent == true --> they're a subscriber
        
        
        // == false --> check if canBecomeSubscriber
        
        
        do {
            print("PRINTING MUSIC SUB CURRENT STATUS: ")
            try await print(MusicSubscription.current)
        } catch {
            print("ERROR CAUGHT IN CHECKING APPLE MUSIC STATUS")
        }
    }
    
//    func checkAppleMusicStatus() async throws -> Bool {
//        guard try await MusicSubscription.current.canPlayCatalogContent else {
//            throw MTError.
//        }
//        
//        return true
        
//        do {
//            return try await MusicSubscription.current.canPlayCatalogContent
//        } catch {
//            print("Something went wrong with checking Apple Music status.")
//            
//        }
//    }
}
