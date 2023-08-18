//
//  MusicArtistRepo.swift
//  MusicTrail
//
//  Created by Davy Chuon on 8/18/23.
//

import Foundation
import MusicKit


class MusicArtistRepo {
    let cdRepo = CoreDataRepo()
    
    func saveLibraryArtists(_ artists: [MTArtist]) {
        
        for artist in artists {
            var newArtist = MusicArtist(context: cdRepo.getContext())
            newArtist.imageUrl = artist.imageUrl
            newArtist.name = artist.name
            newArtist.isLibrary = true
            newArtist.artistId = artist.id.rawValue
//            newArtist.artistUrl = artist.url
        }
        
        cdRepo.save()
    }
    
    func unsaveArtist(_ artist: MTArtist) {
        let pred = NSPredicate(format: "name == %@", artist.name)
        
        guard let artistToDelete = cdRepo.fetch(MusicArtist.self, predicate: pred).first else {
            print("FAILING TO FETCH ARTIST")
            return
        }
        
        print("PROCEEDING TO DELETE")
        cdRepo.delete(artistToDelete)
    }
    
    func fetchSavedArtists() -> [MTArtist] {
        var fetchedArtists: [MTArtist] = []
        let savedArtists: [MusicArtist] = cdRepo.fetch(MusicArtist.self)
        
        for artist in savedArtists {

            guard let artistId = artist.artistId, let artistName = artist.name else { continue }
            
            let currentArtist = MTArtist(name: artistName, id: MusicItemID(artistId), imageUrl: artist.imageUrl)
            
            fetchedArtists.append(currentArtist)
        }
        
        return fetchedArtists
    }
}
