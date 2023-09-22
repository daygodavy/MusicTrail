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
    
    private func fetchAssociatedRecords(for artistID: MusicItemID?) -> [MusicRecord] {
        guard let artistID = artistID else { return [] }
        
        let pred = NSPredicate(format: "artistID == %@", artistID.rawValue as CVarArg)
        
        let associatedRecords = cdRepo.fetch(MusicRecord.self, predicate: pred)
        Logger.shared.debug("associatedRecords for \(artistID)")
        Logger.shared.debug("associatedRecords count: \(associatedRecords.count)")
        Logger.shared.debug("~~~~~~~~~~~~~~~~~~~~~~~~~~")
        if associatedRecords.isEmpty {
            Logger.shared.debug("ASSOCIATED RECORDS IS EMPTY FOR \(artistID)")
        }
        return associatedRecords
    }
    
    func saveArtists(_ artists: [MTArtist]) {
        cdRepo.getContext().performAndWait {
            for artist in artists {
                guard let catalogID = artist.catalogID else {
                    Logger.shared.debug("WARNING: Artist catalogID is nil for artist: \(artist.name)")
                    continue
                }
                
                let newArtist = MusicArtist(context: cdRepo.getContext())
                newArtist.name = artist.name
                newArtist.libraryID = artist.libraryID?.rawValue
                newArtist.catalogID = artist.catalogID?.rawValue
                newArtist.topSongID = artist.topSongID?.rawValue
                newArtist.imageUrl = artist.imageUrl
                newArtist.artistUrl = nil
                newArtist.genreName = nil
                newArtist.isTracked = false
                
                Logger.shared.debug("========CURRENT ARTIST BEING SAVED \(newArtist.name) - \(newArtist.catalogID):")
                newArtist.addToRecords(NSSet(array: fetchAssociatedRecords(for: catalogID)))
            }
            
            if cdRepo.getContext().hasChanges {
                do {
                    try cdRepo.getContext().save()
                } catch {
                    Logger.shared.debug("Error saving context: \(error)")
                }
            }
        }
    }
    
    // TODO: - CHANGE PREDICATE TO CATALOG ID
    func unsaveArtist(_ artist: MTArtist) {
        guard let catalogID = artist.catalogID else { return }
        let pred = NSPredicate(format: "catalogID == %@", catalogID.rawValue as CVarArg)
        
        guard let artistToDelete = cdRepo.fetch(MusicArtist.self, predicate: pred).first else {
            Logger.shared.debug("FAILING TO FETCH ARTIST")
            return
        }
        
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
        
        fetchedArtists.sort { $0.name.lowercased() < $1.name.lowercased() }
        
        return fetchedArtists
    }
    
    func convertToMusicItemID(_ stringID: String?) -> MusicItemID? {
        
        guard let validID = stringID else { return nil }
        
        return MusicItemID(validID)
    }
}
