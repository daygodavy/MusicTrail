//
//  MusicDataManager.swift
//  MusicTrail
//
//  Created by Davy Chuon on 9/20/23.
//

import UIKit


class MusicDataManager {
    
    static let shared = MusicDataManager()
    
    private let musicRecordRepo: MusicRecordRepo = MusicRecordRepo()
    
    private var savedArtists: [MTArtist] = []
    private var musicRecords: [MonthSection : [MTRecord]] = [:]
    
    func saveArtists(_ artists: [MTArtist]) {
        print("appending new artists in MusicDataManager")
        savedArtists.append(contentsOf: artists)
        
        getNewMusic(for: artists) {
            print("posting artistsUpdated in MusicDataManager")
            NotificationCenter.default.post(name: .artistsUpdated, object: nil, userInfo: ["artist" : artists])
        }
    }
    
    func getNewMusic(for artists: [MTArtist], completion: @escaping () -> Void) {
        Task {
            print("starting getNewMusic Task in MusicDataManager")
            let getNewRecords = await MusicKitManager.shared.fetchNewMusic(for: artists)
            musicRecords.merge(getNewRecords) { (current, new) in current + new }
            
            // Convert fetched music records into [MTRecord] and save them into Core Data
            let mtRecords = getNewRecords.flatMap { $0.value }
            musicRecordRepo.saveMusicRecords(mtRecords)
            
            print("completing getNewMusic Task in MusicDataManager")
            completion()
        }
    }

    
    func getMusicRecords() -> [MonthSection : [MTRecord]] {
        return musicRecords
    }
    
    func deleteRecordsFromArtist(_ artist: MTArtist) {
        savedArtists.removeAll { $0.catalogID == artist.catalogID }
        // Remove from Core Data
        musicRecordRepo.deleteMusicRecords(for: artist)
        // Signal NewMusicVC to update UI to reflect changes
        NotificationCenter.default.post(name: .artistsUpdated, object: nil)
        
        
    }
}


extension Notification.Name {
    static let artistsUpdated = Notification.Name("artistsUpdated")
}

//class MusicDataManager {
//    
//    static let shared = MusicDataManager()
//    
//    private let musicRecordRepo: MusicRecordRepo = MusicRecordRepo()
//    
//    private var savedArtists: [MTArtist] = []
//    private var musicRecords: [MonthSection : [MTRecord]] = [:]
//    
//    func saveArtists(_ artists: [MTArtist]) {
//        savedArtists.append(contentsOf: artists)
//        
//
//        NotificationCenter.default.post(name: .artistsSaved, object: nil, userInfo: ["artists" : artists])
//    }
//    
//    func getNewMusic(for artists: [MTArtist], completion: @escaping () -> Void) {
//        Task {
//            let getNewRecords = await MusicKitManager.shared.fetchNewMusic(for: artists)
//            musicRecords.merge(getNewRecords) { (current, new) in current + new }
//            completion()
//        }
//    }
//    
//    func getMusicRecords() -> [MonthSection : [MTRecord]] {
//        return musicRecords
//    }
//}
//
//
//extension Notification.Name {
//    static let artistsSaved = Notification.Name("artistsSaved")
//}
