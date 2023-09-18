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
        // TODO: - VERIFY IF WARNING IS VALID TO 'LET'
        for artist in artists {
            var newArtist = MusicArtist(context: cdRepo.getContext())
            newArtist.name = artist.name
            newArtist.libraryID = artist.libraryID?.rawValue
            newArtist.catalogID = artist.catalogID?.rawValue
            newArtist.topSongID = artist.topSongID?.rawValue
            newArtist.imageUrl = artist.imageUrl
            newArtist.artistUrl = nil
            newArtist.genreName = nil
            newArtist.isTracked = false
        }
        
        cdRepo.save()
    }
    
    func saveCatalogArtist(_ artist: MTArtist) {
        var newArtist = MusicArtist(context: cdRepo.getContext())
        newArtist.name = artist.name
        newArtist.libraryID = nil
        newArtist.catalogID = artist.catalogID?.rawValue
        newArtist.topSongID = artist.topSongID?.rawValue
        newArtist.imageUrl = artist.imageUrl
        newArtist.artistUrl = nil
        newArtist.genreName = nil
        newArtist.isTracked = false

        cdRepo.save()
    }
    
    // TODO: - CHANGE PREDICATE TO CATALOG ID
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
            guard let name = artist.name,
                    let catalogID = convertToMusicItemID(artist.catalogID)
            else { continue }
            
            let libraryID = convertToMusicItemID(artist.libraryID)
            let topSongID = convertToMusicItemID(artist.topSongID)
            let imageUrl = artist.imageUrl
            let artistUrl = artist.artistUrl
            let genreName = artist.genreName

            let currentArtist = MTArtist(name: name,
                                         catalogID: catalogID,
                                         libraryID: libraryID,
                                         topSongID: topSongID,
                                         imageUrl: imageUrl,
                                         artistUrl: artistUrl,
                                         genres: genreName)
        
            fetchedArtists.append(currentArtist)
        }
        
        fetchedArtists.sort { $0.name < $1.name }
        return fetchedArtists
    }
    
    func convertToMusicItemID(_ stringID: String?) -> MusicItemID? {
        
        guard let validID = stringID else { return nil }
        
        return MusicItemID(validID)
    }
}
