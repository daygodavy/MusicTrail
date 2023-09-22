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
    private let musicArtistRepo: MusicArtistRepo = MusicArtistRepo()
    
    private var savedArtists: [MTArtist] = []
    private var allMusicRecords: [MonthSection : [MTRecord]] = [:]
    
    private var newMusicRecords: [MonthSection : [MTRecord]] = [:]
    
    
    func saveNewArtists(_ artists: [MTArtist]) {
        
        savedArtists.append(contentsOf: artists)
        
        getNewMusic(for: artists) {
            // Convert fetched music records into [MTRecord] and save them into Core Data
            let mtRecords = self.newMusicRecords.flatMap { $0.value }
            self.musicRecordRepo.saveMusicRecords(mtRecords)
            Logger.shared.debug("MUSICDATAMANAGER: SAVEMUSICRECORDS DONE")
            self.musicArtistRepo.saveArtists(artists)
            Logger.shared.debug("MUSICDATAMANAGER: SAVEARTISTS DONE")
            NotificationCenter.default.post(name: .artistsUpdated, object: nil, userInfo: ["artist" : artists])
        }
    }
    
    
    
    func getNewMusic(for artists: [MTArtist], completion: @escaping () -> Void) {
        Task {
            
            let getNewRecords = await MusicKitManager.shared.fetchNewMusic(for: artists)
            
            newMusicRecords = getNewRecords
            
            allMusicRecords.merge(getNewRecords) { (current, new) in current + new }
            
            completion()
        }
    }

    
    func deleteArtistWithRecords(_ artist: MTArtist) {
        savedArtists.removeAll { $0.catalogID == artist.catalogID }
        musicArtistRepo.unsaveArtist(artist)
        NotificationCenter.default.post(name: .artistsUpdated, object: nil)
    }
    
    
    func getSavedArtists() -> [MTArtist] {
        return musicArtistRepo.fetchSavedArtists()
    }
}


extension Notification.Name {
    static let artistsUpdated = Notification.Name("artistsUpdated")
}
