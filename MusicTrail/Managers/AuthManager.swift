//
//  LoginManager.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/20/23.
//

import MusicKit
import UIKit

class AuthManager {
    
    private func checkAuthorizationStatus() async throws {
        guard MusicAuthorization.currentStatus != .authorized else { return }
        
        let status = await MusicAuthorization.request()
        
        switch status {
        case .authorized:
            // user accepted permission to use MusicKit
            return
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

    // Check if user has apple music subscription (to access library)
    private func checkAppleMusicStatus() async throws {
        guard try await MusicSubscription.current.canPlayCatalogContent else {
            throw MTError.invalidAppleMusicSub
        }
    }
    
    func ensureAppleMusicSubscription() async throws {
        do {
            try await checkAppleMusicStatus()
        } catch {
            throw error
        }
    }
    
    func ensureAuthorization() async throws {
        do {
            try await checkAuthorizationStatus()
        } catch {
            throw error
        }
    }

}
