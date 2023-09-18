//
//  MTError.swift
//  MusicTrail
//
//  Created by Davy Chuon on 9/18/23.
//

import Foundation

enum MTError: String, Error {
    
    case permissionDenied = "Permission denied. Please update your authorization consent to access your Apple Music library."
    case unknown = "An unknown or unexpected error has occured. Please retry again."
}
