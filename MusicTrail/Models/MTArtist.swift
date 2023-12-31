//
//  MTArtist.swift
//  MusicTrail
//
//  Created by Davy Chuon on 9/19/23.
//

import Foundation
import MusicKit

//struct MTArtist: Codable, Hashable {
//    let name: String
//    let id: MusicItemID
//    let imageUrl: URL?
//    var isTracked = false
//    //    var url: URL?
//    // isLibrary --> is artist in library
//    // genreNames: [String]?
//    // libraryAddedDate: Date? --> determine if user added new artist
//    // url: URL? --> url for the artist
//}

struct MTArtist: Codable, Hashable {
    let name: String
    var catalogID: MusicItemID?
    var libraryID: MusicItemID?
    var topSongID: MusicItemID?
    var imageUrl: URL?
    var artistUrl: URL? // REFACTOR MKMANAGER TO RETRIEVE
    var genres: String? // REFACTOR MKMANAGER TO RETRIEVE
    var isTracked = false
}
