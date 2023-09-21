//
//  MusicRecordRepo.swift
//  MusicTrail
//
//  Created by Davy Chuon on 9/20/23.
//

import Foundation
import MusicKit


class MusicRecordRepo {
    let cdRepo = CoreDataRepo()
    
    func saveMusicRecords(_ records: [MTRecord]) {
        for record in records {
            let newRecord = MusicRecord(context: cdRepo.getContext())
            newRecord.title = record.title
            newRecord.artistName = record.artistName
            newRecord.recordID = record.recordID.rawValue
            newRecord.artistID = record.artistCatalogID.rawValue
            newRecord.imageUrl = record.imageUrl
            newRecord.recordUrl = record.recordUrl
            newRecord.genres = record.genres
            newRecord.releaseDate = record.releaseDate
            
            guard let rating = record.contentRating,
                  let isSingle = record.isSingle else { continue }
            
            newRecord.isExplicit = rating == .explicit
            newRecord.isSingle = isSingle
        }

        if cdRepo.getContext().hasChanges {
            cdRepo.save()
        }
    }
    
    // TODO: - CURRENTLY DELETING RECORDS THAT MATCH ARTIST CATALOG ID
    // TODO: - ACCOUNT FOR MULTIPLE ARTISTS ID FOR A RECORD....
    func deleteMusicRecords(for artist: MTArtist) {
        guard let catalogID = artist.catalogID else { return }
        let pred = NSPredicate(format: "artistID == %@", catalogID.rawValue)
        
        let recordsToDelete = cdRepo.fetch(MusicRecord.self, predicate: pred)
        
        for record in recordsToDelete {
            cdRepo.delete(record)
        }
        
    }
    
    func fetchSavedMusicRecords() -> [MTRecord] {
        var fetchedRecords: [MTRecord] = []
        let savedRecords: [MusicRecord] = cdRepo.fetch(MusicRecord.self)
        
        for record in savedRecords {
            guard let title = record.title,
                  let artistName = record.artistName,
                  let recordId = record.recordID,
                  let artistId = record.artistID,
                  let releaseDate = record.releaseDate
            else {
                continue
            }
            
            let recordID = MusicItemID(recordId)
            let artistID = MusicItemID(artistId)
            let imageUrl = record.imageUrl
            let recordUrl = record.recordUrl
            let genres = record.genres
            let isSingle = record.isSingle
            
            var contentRating: ContentRating = .clean
            if record.isExplicit { contentRating = .explicit }
            
            let currentRecord = MTRecord(title: title,
                                         artistName: artistName,
                                         recordID: recordID,
                                         artistCatalogID: artistID,
                                         imageUrl: imageUrl,
                                         recordUrl: recordUrl,
                                         releaseDate: releaseDate,
                                         genres: genres,
                                         contentRating: contentRating,
                                         isSingle: isSingle)
            
            fetchedRecords.append(currentRecord)
        }
        
        
        return fetchedRecords
    }

}

