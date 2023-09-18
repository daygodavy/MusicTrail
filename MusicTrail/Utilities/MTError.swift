//
//  MTError.swift
//  MusicTrail
//
//  Created by Davy Chuon on 9/18/23.
//

import Foundation

enum MTError: String, Error {
    
    case permissionDenied = "Please update your consent authorization in settings to access your Apple Music library."
    case permissionNotDetermined = "Please select your consent authorization in settings to access your Apple Music library."
    case permissionRestricted = "Unfortunately your device cannot access this feature."
    case privacyAcknowledgement = "Request denied. Please acknowledge the most recent privacy policy for Apple Music."
    case unknown = "An unknown or unexpected error has occured. Please retry again."
}
