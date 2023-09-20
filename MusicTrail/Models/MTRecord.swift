//
//  MTRecord.swift
//  MusicTrail
//
//  Created by Davy Chuon on 9/19/23.
//

import Foundation
import MusicKit

struct MTRecord: Codable, Hashable {
    let artistName: String
    let title: String
    let ID: MusicItemID
    let artistCatalogID: MusicItemID
    var imageUrl: URL?
    var recordUrl: URL?
    var releaseDate: Date
    var contentRating: ContentRating?
    var genreNames: [String]?
    var isSingle: Bool?
    var tracks: MusicItemCollection<Track>?
}

//struct MTArtist: Codable, Hashable {
//    let name: String
//    var catalogID: MusicItemID?
//    var libraryID: MusicItemID?
//    var topSongID: MusicItemID?
//    var imageUrl: URL?
//    var artistUrl: URL? // REFACTOR MKMANAGER TO RETRIEVE
//    var genres: String? // REFACTOR MKMANAGER TO RETRIEVE
//    var isTracked = false
//}
