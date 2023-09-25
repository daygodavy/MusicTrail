//
//  MusicKitManager.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/14/23.
//

import MusicKit
import UIKit


class MusicKitManager {
    
    static let shared = MusicKitManager()
    let accessAuthenticator = AuthManager()
    
    let imageWidth: Int = 336
    let imageHeight: Int = 336
    
//    var originalLibraryArtists: [MusicItemID : Artist] = [:]
    
    private init() {}

    func searchCatalogArtists(term: String, limit: Int? = nil) async throws -> MusicItemCollection<Artist> {
        var request = MusicCatalogSearchRequest(term: term, types: [Artist.self])
        request.limit = limit
        do {
            let response = try await NetworkManager.shared.retry(4) { () async throws -> MusicCatalogSearchResponse in
                let response = try await request.response()
                if response.artists.isEmpty {
                    Logger.shared.debug("NO ARTISTS FOUND IN SEARCHING CATALOG ARTISTS")
                }
//                Logger.shared.debug("00 RETRY ATTEMPT HERE: \(term)")
                return response
                
            }
            return response.artists
        } catch {
            throw error
        }
    }
    
    // Converting Artist to MTArtist if valid
    func convertToMTArtist(_ artist: Artist, libID: MusicItemID?=nil, catID: MusicItemID?=nil, songID: MusicItemID?=nil, source: MusicPropertySource?=nil) async throws -> MTArtist? {
        
        if let artworkUrl = formatLibraryArtistArtwork(artist) ??
            artist.artwork?.url(width: imageWidth, height: imageHeight) {
            
            return MTArtist(name: artist.name,
                                    catalogID: catID,
                                    libraryID: libID,
                                    imageUrl: artworkUrl)
        }
        
        if let topSongID = songID {
            return MTArtist(name: artist.name,
                            catalogID: catID,
                            libraryID: libID,
                            topSongID: topSongID,
                            imageUrl: nil)
        }
        
        guard let source = source, let topSongID = await fetchArtistTopSongID(currArtist: artist, currSource: source) else {
            return nil
        }
        
        return MTArtist(name: artist.name,
                        catalogID: catID,
                        libraryID: libID,
                        topSongID: topSongID,
                        imageUrl: nil)
    }
    

    func fetchSearchedArtists(_ searchTerm: String, excludedArtists: [MTArtist]) async throws -> [MTArtist] {
        try await accessAuthenticator.ensureAuthorization()
        
        var resultArtists: [MTArtist] = []
        let searchedArtists = try await searchCatalogArtists(term: searchTerm, limit: 20)
        
        for artist in searchedArtists {
            if try await !isExcludedArtist(artist, currSource: .catalog, excludedArtists: excludedArtists),
                let mtArtist = try await convertToMTArtist(artist, catID: artist.id, source: .catalog) {
                
                resultArtists.append(mtArtist)
            }
        }
        return resultArtists
    }
    
    
    func fetchCatalogArtistByTopSongID(_ libraryArtist: Artist, librarySongID: MusicItemID) async throws -> MTArtist? {
        
        let catalogArtists = try await searchCatalogArtists(term: libraryArtist.name)
        
        for artist in catalogArtists {
            if artist.name.lowercased() == libraryArtist.name.lowercased() {
                guard let catalogSongID = await fetchArtistTopSongID(currArtist: artist, currSource: .catalog) else { return nil }
                if catalogSongID == librarySongID,
                    let mtArtist = try await convertToMTArtist(artist, libID: libraryArtist.id, catID: artist.id, songID: catalogSongID, source: .catalog) {

                    return mtArtist
                }
            }
        }
        return nil
    }
    
    
    func fetchArtistTopSongID(currArtist: Artist, currSource: MusicPropertySource) async -> MusicItemID? {
        
        do {
            let artistWithTopSongs = try await currArtist.with([.topSongs], preferredSource: currSource)
            
            guard let topSongID = artistWithTopSongs.topSongs?.first?.id else { return nil }
            
            return topSongID
        }
        catch { return nil }
    }
    
    
    // MARK: - MAPPING LIBRARY ARTIST IMAGE TO CATALOG ARTIST IMAGE
//    func fetchCatalogArtistByImageURL(currArtist: MTArtist) async throws -> MTArtist? {
//        
//        let catalogArtists = try await searchCatalogArtists(term: currArtist.name)
//        
//        for artist in catalogArtists {
//            
//            if artist.name.lowercased() == currArtist.name.lowercased() {
//
//                let catArtistImageURL = artist.artwork?.url(width: imageWidth, height: imageHeight)
//                
//                guard isMatchingImageURL(catArtistImageURL, currArtist.imageUrl) else { return nil }
//                
//                return MTArtist(name: artist.name,
//                                catalogID: artist.id,
//                                libraryID: currArtist.libraryID,
//                                imageUrl: currArtist.imageUrl)
//            }
//        }
//        
//        return nil
//    }
    
    func fetchCatalogArtistByImageURL(currArtist: MTArtist) async throws -> MTArtist? {
        let catalogArtists = try await searchCatalogArtists(term: currArtist.name)
        
        for artist in catalogArtists {
            
            if artist.name.lowercased() == currArtist.name.lowercased(),
               let catArtistImageURL = artist.artwork?.url(width: imageWidth, height: imageHeight),
                isMatchingImageURL(catArtistImageURL, currArtist.imageUrl) {
                
                let mtArtist = MTArtist(name: artist.name,
                                catalogID: artist.id,
                                libraryID: currArtist.libraryID,
                                imageUrl: currArtist.imageUrl)

                return mtArtist
            }
        }
        
        Logger.shared.debug("NO IMAGE MATCH!!!!! \(currArtist.name)")
        return nil
    }
    
    
    func isMatchingImageURL(_ imgUrl1: URL?, _ imgUrl2: URL?) -> Bool {
        
        guard let imgUrl1 = imgUrl1, let imgUrl2 = imgUrl2 else {
            return false
        }
        var strUrl1 = imgUrl1.absoluteString
        var strUrl2 = imgUrl2.absoluteString
        
        guard strUrl1.removeLast(6) == strUrl2.removeLast(6) else {
            return false
        }
    
        return true
    }
    
    
    func mapLibraryToCatalog(_ artists: [MTArtist]) async throws -> [MTArtist] {
        try await accessAuthenticator.ensureAuthorization()
        
        var catalogArtists: [MTArtist] = []
        let indexHandler = ArtistIndexHandler()
        
        await withTaskGroup(of: MTArtist?.self) { group in
            let maxFetchTask = min(20, artists.count)
            
            for _ in 0..<maxFetchTask {
                group.addTask {
                    let index = await indexHandler.getNext()
                    guard index < artists.count else { return nil }
                    return await self.getCatalogArtistMatch(artists[index])
                }
            }
            
            for await result in group {
                if let artist = result {
                    catalogArtists.append(artist)
                }
                
                let nextIndex = await indexHandler.getNext()
                if nextIndex < artists.count {
                    group.addTask {
                        return await self.getCatalogArtistMatch(artists[nextIndex])
                    }
                }
            }
        }
        Logger.shared.debug("MAPLIBRARYTOCATALOG DONE, RETURNING \(catalogArtists.count) MTARTISTS", toggle: true)
        return catalogArtists
    }
    

    
    private func getCatalogArtistMatch(_ artist: MTArtist) async -> MTArtist? {
            
        guard let currID = artist.libraryID,
//                let currArtist = originalLibraryArtists[currID]
              let currArtist = await libraryArtistsHandler.getArtist(for: currID)
        else {
            Logger.shared.debug("0GETCATALOGARTISTMATCH RETURNING NIL")
            return nil
        }
        
        if let _ = artist.imageUrl {
            
            do {
                let catArtistMatch = try await
                fetchCatalogArtistByImageURL(currArtist: artist)
                
                
                
                if let _ = catArtistMatch {
                    
                } else {
                    Logger.shared.debug("1NIL ARTIST \(artist.name) - \(artist.catalogID)", toggle: true)
                }
                
                
                
                
                return catArtistMatch
            } catch {
                Logger.shared.debug("\(artist.name) - \(artist.libraryID)")
                Logger.shared.debug("1GETCATALOGARTISTSMATCH: CAUGHT ERROR RETURNING NIL", toggle: true)
                Logger.shared.debug(error.localizedDescription)
                return nil
            }
        } else if let topSongID = await fetchArtistTopSongID(currArtist: currArtist, currSource: .library) {
            
            do {
                let catArtistMatch = try await fetchCatalogArtistByTopSongID(currArtist, librarySongID: topSongID)
                
                
                if let _ = catArtistMatch {
                    
                } else {
                    Logger.shared.debug("2NIL ARTIST \(artist.name) - \(artist.catalogID)", toggle: true)
                }
                
                
                
                return catArtistMatch
            } catch {
                Logger.shared.debug("\(artist.name) - \(artist.libraryID)")
                Logger.shared.debug("2GETCATALOGARTISTSMATCH: CAUGHT ERROR RETURNING NIL", toggle: true)
                Logger.shared.debug(error.localizedDescription)
                return nil
            }
            
        } else {
            Logger.shared.debug("\(artist.name) - \(artist.libraryID)")
            Logger.shared.debug("3GETCATALOGARTISTSMATCH: CAUGHT ERROR RETURNING NIL", toggle: true)
            return nil
        }
    }
    
    
    actor LibraryArtistsHandler {
        private var originalLibraryArtists: [MusicItemID : Artist] = [:]
        
        func setArtist(_ artist: Artist, for id: MusicItemID) {
            originalLibraryArtists[id] = artist
        }
        
        func getArtist(for id: MusicItemID) -> Artist? {
            return originalLibraryArtists[id]
        }
    }

    let libraryArtistsHandler = LibraryArtistsHandler()
    
    // Fetch all artists from library
    func fetchLibraryArtists(_ savedArtists: [MTArtist]) async throws -> [MTArtist] {
        try await accessAuthenticator.ensureAuthorization()
        try await accessAuthenticator.ensureAppleMusicSubscription()
        
        var allArtists: [MTArtist] = []
//        originalLibraryArtists.removeAll()
        
        var request = MusicLibraryRequest<Artist>()
        request.sort(by: \.name, ascending: true)
        let response = try await request.response()
        
        try await withThrowingTaskGroup(of: MTArtist?.self) { group in
            
            for artist in response.items {
                group.addTask {
                    
                    guard try await self.isArtistValid(artist, excludedArtists: savedArtists)
                    else { return nil }
                    
                    // Store original library artist object
                    await self.libraryArtistsHandler.setArtist(artist, for: artist.id)
//                    self.originalLibraryArtists[artist.id] = artist
                    return try await self.convertToMTArtist(artist, libID: artist.id, source: .library)
                }
            }
            
            for try await artist in group {
                if let artist = artist {
                    allArtists.append(artist)
                }
            }
        }
        return allArtists
    }
    
    
    
    // Converts library artist artwork URL to catalog format
    func formatLibraryArtistArtwork(_ currArtist: Artist) -> URL? {
        return currArtist
            .artwork?
            .url(width: imageWidth, height: imageHeight)?
            .absoluteString
            .formatToCatalogArtworkURL()
    }
    
    
    // Conditions to filter out extraneous library artists
    func isArtistValid(_ currArtist: Artist, excludedArtists: [MTArtist]) async throws -> Bool {
        
        let artistName = currArtist.name
        // Filter out extraneous artists
        if artistName.contains(",") ||
            artistName.contains("&") ||
            artistName.lowercased().contains("various artists") {
            return false
        }
        
        if try await isExcludedArtist(currArtist, currSource: .library, excludedArtists: excludedArtists) {
            return false
        }
        
        return true
    }
    
    
    func isExcludedArtist(_ currArtist: Artist, currSource: MusicPropertySource, excludedArtists: [MTArtist]) async throws -> Bool {
        
        guard excludedArtists.contains(where: { $0.name.lowercased() == currArtist.name.lowercased() })
        else { return false }
        
        switch currSource {
        case .library:
            // Check comparison if libraryID match in excludedArtists
            if excludedArtists.contains(
                where: { $0.libraryID == currArtist.id }) {
                
                return true
            }
        
            // Edge case: artist imported from catalog, then user adds artist in their library -> compare imageURL
            if let currArtistImageURL = formatLibraryArtistArtwork(currArtist),
                excludedArtists.contains(where: { isMatchingImageURL($0.imageUrl, currArtistImageURL) }) {
                
                return true
            }
            
            // Worst case for assurance -> compare topSongID match if imageURL doesn't match
            // Edge case: artist in library with no image, but user adds artist from catalog with image
            guard let currArtistTopSongID = await fetchArtistTopSongID(currArtist: currArtist, currSource: .library)
            else { return true }
            
            if excludedArtists.contains(
                where: { $0.topSongID == currArtistTopSongID }) {
                
                return true
            }
            
        case .catalog:
            // Check if catalogID match in excludedArtists
            if excludedArtists.contains(where: { $0.catalogID == currArtist.id }) {
                return true
            }

        @unknown default:
            // TODO: - unknown error happened, please try again
            break
        }
        
        return false
    }
    
    
    actor ArtistIndexHandler {
        private var nextIndex: Int = 0
        
        func getNext() -> Int {
            let current = nextIndex
            nextIndex += 1
            return current
        }
    }

    func fetchNewMusic(for artists: [MTArtist]) async -> [MonthSection : [MTRecord]] {
        var recordsByMonth: [MonthSection : [MTRecord]] = [:]
        let indexHandler = ArtistIndexHandler()

        await withTaskGroup(of: [MonthSection : [MTRecord]].self) { group in
            // TODO: - TEST INCREASING THIS NUMBER
            let maxFetchTasks = min(35, artists.count)
            for _ in 0..<maxFetchTasks {
                group.addTask {
                    let index = await indexHandler.getNext()
                    guard index < artists.count, let catalogID = artists[index].catalogID else { return [:] }
                    return await self.fetchRecordsForArtist(catalogID)
                }
            }

            for await result in group {
                for (monthYear, records) in result {
                    recordsByMonth[monthYear, default: []].append(contentsOf: records)
                }
                
                let nextIndex = await indexHandler.getNext()
                if nextIndex < artists.count {
                    group.addTask {
                        guard let catalogID = artists[nextIndex].catalogID else { return [:] }
                        return await self.fetchRecordsForArtist(catalogID)
                    }
                }
            }
        }
        return recordsByMonth
    }


    func fetchRecordsForArtist(_ artistCatalogID: MusicItemID) async -> [MonthSection : [MTRecord]] {
        
        do {
            let response = try await NetworkManager.shared.retry(4) { () async throws -> MusicCatalogResourceResponse<Artist> in
                var request = MusicCatalogResourceRequest<Artist>(matching: \.id, equalTo: artistCatalogID)
                request.limit = 1
                let response = try await request.response()
                if response.items.isEmpty {
                    Logger.shared.debug("EMPTY RESPONSE ITEMS FOR \(artistCatalogID)")
                }
//                Logger.shared.debug("1FIRST: RETRY ATTEMPT HERE")
                return response
            }

            guard let artist = response.items.first else {
                Logger.shared.debug("FETCHRECORDSFORARTIST RESPONSE IS EMPTY!!!!!!!!!!! - \(artistCatalogID)")
                return [:]
            }
            
//            let allMusic = try await artist.with([.albums], preferredSource: .catalog)
            let allMusic = try await NetworkManager.shared.retry(4) { () async throws -> MusicItemCollection<Artist>.Element in
                
//                Logger.shared.debug("2SECOND: RETRY ATTEMPT HERE - \(artistCatalogID)")
                return try await artist.with([.albums], preferredSource: .catalog)
            }
            
            var trackedRecordsDict: [String : Album] = [:]
            var batchRecords = allMusic.albums ?? []
            var isLastBatch: Bool = false
            
            repeat {
                
                for record in batchRecords {
                    if trackedRecordsDict.keys.contains(record.title),
                       let rating = trackedRecordsDict[record.title]?.contentRating,
                       rating == .explicit {
                        continue
                    } else {
                        trackedRecordsDict[record.title] = record
                    }
                }
                
                let nextBatch = try await NetworkManager.shared.retry(4) { () async throws -> MusicItemCollection<Album>? in
//                    Logger.shared.debug("3THIRD: RETRY ATTEMPT HERE - \(artistCatalogID)")
                    guard let nextBatch = try await batchRecords.nextBatch() else {
                        return nil
                    }
                    return nextBatch
                }
                
                guard let nextBatch = nextBatch else {
                    isLastBatch = true
                    continue
                }
                batchRecords = nextBatch
//                guard let nextBatch = try await batchRecords.nextBatch() else {
//                    isLastBatch = true
//                    continue
//                }
//                batchRecords = nextBatch
                
            } while !isLastBatch
            
            var recordsByMonth: [MonthSection : [MTRecord]] = [:]
            for record in trackedRecordsDict.values {
                guard let releaseDate = record.releaseDate,
                      let artworkURL = record.artwork?.url(width: imageWidth + 168, height: imageHeight + 168) else {
                          continue
                      }
                
                let monthYearString = DateUtil.monthYearFormatter.string(from: releaseDate)
                let monthSection = MonthSection(monthYear: monthYearString)
                
                let mtRecord = MTRecord(title: record.title, artistName: record.artistName, recordID: record.id, artistCatalogID: artistCatalogID, imageUrl: artworkURL, releaseDate: releaseDate)
                
                recordsByMonth[monthSection, default: []].append(mtRecord)
            }
            
            return recordsByMonth
            
        } catch let error as NSError {
            if error.code == 429 {
                // Handle rate limiting error
                Logger.shared.debug("Rate limit exceeded. Retrying...")
            } else {
                Logger.shared.debug("Error fetching data for catalog ID: \(artistCatalogID), Error \(error.code): \(error)")
            }
        } catch {
            Logger.shared.debug("Error fetching data for catalog ID: \(artistCatalogID), Error: \(error)")
            fatalError()
        }
        
        return [:]
    }

    
//    func fetchRecordsForArtist(_ artistCatalogID: MusicItemID) async -> [MonthSection : [MTRecord]] {
//        
//        do {
//            let response = try await NetworkManager.shared.retry(3) { () async throws -> MusicCatalogResourceResponse<Artist> in
//                var request = MusicCatalogResourceRequest<Artist>(matching: \.id, equalTo: artistCatalogID)
//                request.limit = 1
//                let response = try await request.response()
//                if response.items.isEmpty {
//                    Logger.shared.debug("EMPTY RESPONSE ITEMS FOR \(artistCatalogID)")
//                }
//                return response
//            }
//
//            guard let artist = response.items.first else {
//                Logger.shared.debug("FETCHRECORDSFORARTIST REPONSE IS EMPTY!!!!!!!!!!!")
//                return [:]
//            }
//            
//            let allMusic = try await artist.with([.albums], preferredSource: .catalog)
//            
//            var trackedRecordsDict: [String : Album] = [:]
//            var batchRecords = allMusic.albums ?? []
//            var isLastBatch: Bool = false
//            
//            repeat {
//                
//                for record in batchRecords {
//                    if trackedRecordsDict.keys.contains(record.title),
//                       let rating = trackedRecordsDict[record.title]?.contentRating,
//                       rating == .explicit {
//                        continue
//                    } else {
//                        trackedRecordsDict[record.title] = record
//                    }
//                }
//                
//                guard let nextBatch = try await batchRecords.nextBatch() else {
//                    isLastBatch = true
//                    continue
//                }
//                batchRecords = nextBatch
//                
//            } while !isLastBatch
//            
//            var recordsByMonth: [MonthSection : [MTRecord]] = [:]
//            for record in trackedRecordsDict.values {
//                guard let releaseDate = record.releaseDate,
//                      let artworkURL = record.artwork?.url(width: imageWidth + 168, height: imageHeight + 168) else {
//                          continue
//                      }
//                
//                let monthYearString = DateUtil.monthYearFormatter.string(from: releaseDate)
//                let monthSection = MonthSection(monthYear: monthYearString)
//                
//                let mtRecord = MTRecord(title: record.title, artistName: record.artistName, recordID: record.id, artistCatalogID: artistCatalogID, imageUrl: artworkURL, releaseDate: releaseDate)
//                
//                recordsByMonth[monthSection, default: []].append(mtRecord)
//            }
//            
//            return recordsByMonth
//            
//        } catch let error as NSError {
//            if error.code == 429 {
//                // Handle rate limiting error
//                Logger.shared.debug("Rate limit exceeded. Retrying...")
//            } else {
//                Logger.shared.debug("Error fetching data for catalog ID: \(artistCatalogID), Error \(error.code): \(error)")
//            }
//        } catch {
//            Logger.shared.debug("Error fetching data for catalog ID: \(artistCatalogID), Error: \(error)")
//            fatalError()
//        }
//        
//        return [:]
//    }
    
}
    
