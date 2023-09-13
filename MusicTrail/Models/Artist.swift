//
//  Artist.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/14/23.
//

import Foundation
import MusicKit

struct MTArtist: Codable, Hashable {
    let name: String
    let id: MusicItemID
    let imageUrl: URL?
    var isTracked = false
    //    var url: URL?
    // isLibrary --> is artist in library
    // genreNames: [String]?
    // libraryAddedDate: Date? --> determine if user added new artist
    // url: URL? --> url for the artist
}



//struct MTArtist: Codable, Hashable {
//    let name: String
//    let imageUrl: URL?
//    let topSongID: MusicItemID
//    let catalogID: MusicItemID
//    var libraryID: MusicItemID?
//    var isTracked = false
//    var artistUrl: URL?
//    var genres: Genre?
//}
