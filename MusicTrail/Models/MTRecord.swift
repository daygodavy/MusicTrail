//
//  MTRecord.swift
//  MusicTrail
//
//  Created by Davy Chuon on 9/19/23.
//

import Foundation
import MusicKit

struct MTRecord: Codable, Hashable, Equatable {
    let title: String
    let artistName: String
    let recordID: MusicItemID
    let artistCatalogID: MusicItemID
    var imageUrl: URL?
    var recordUrl: URL?
    var releaseDate: Date
    var genres: String?
    var contentRating: ContentRating?
    var isSingle: Bool?
//    var tracks: MusicItemCollection<Track>?
    
    static func == (lhs: MTRecord, rhs: MTRecord) -> Bool {
        return lhs.title == rhs.title &&
            lhs.artistName == rhs.artistName &&
            lhs.recordID == rhs.recordID &&
            lhs.artistCatalogID == rhs.artistCatalogID &&
            lhs.releaseDate == rhs.releaseDate
    }
}
