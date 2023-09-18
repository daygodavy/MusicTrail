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
    let imageWidth: Int = 336
    let imageHeight: Int = 336
    
    var originalLibraryArtists: [MusicItemID : Artist] = [:]
    
    private init() {}
    
    func searchCatalogArtists(term: String, limit: Int? = nil) async throws -> MusicItemCollection<Artist> {
        var request = MusicCatalogSearchRequest(term: term, types: [Artist.self])
        request.limit = limit
        let response = try await request.response()
        print("ARTIST COUNT FROM RESPONSE: \(response.artists.count)")
        return response.artists
    }
    
    func fetchSearchedArtists(_ searchTerm: String, excludedArtists: [MTArtist]) async throws -> [MTArtist] {
        var resultArtists: [MTArtist] = []

        let searchedArtists = try await searchCatalogArtists(term: searchTerm, limit: 25)
        
        for artist in searchedArtists {
            
            if try await !isExcludedArtist(artist, currSource: .catalog, excludedArtists: excludedArtists) {
                
                if let artworkUrl = artist.artwork?.url(
                    width: imageWidth,
                    height: imageHeight) {
                    
                    resultArtists.append(
                        MTArtist(name: artist.name,
                                 catalogID: artist.id,
                                 libraryID: nil,
                                 imageUrl: artworkUrl))
                } else {
                    let topSongID = try await fetchArtistTopSongID(currArtist: artist, currSource: .catalog)
                    
                    resultArtists.append(
                        MTArtist(name: artist.name,
                                 catalogID: artist.id,
                                 libraryID: nil,
                                 topSongID: topSongID,
                                 imageUrl: nil))
                }
                
            }
            
        }
        
        return resultArtists
    }
    
    
    func fetchCatalogArtistByTopSongID(_ libraryArtist: Artist, librarySongID: MusicItemID) async throws -> MTArtist {
        
//        var request = MusicCatalogSearchRequest(term: libraryArtist.name, types: [Artist.self])
//        
//        let response = try await request.response()
        
//        let catalogArtists = response.artists
        
        let catalogArtists = try await searchCatalogArtists(term: libraryArtist.name)
        
        // TODO: - NO NAME MATCH -> HANDLE ERROR
        if catalogArtists.isEmpty { print("EMPTY!!!!!!!") }
        
        for artist in catalogArtists {
            
            if artist.name.lowercased() == libraryArtist.name.lowercased() {
                
                guard let catalogSongID = try await fetchArtistTopSongID(currArtist: artist, currSource: .catalog) else { fatalError() }
                
                if catalogSongID == librarySongID {
                    print("MATCH FOUND")
                    
                    if let artworkUrl = artist.artwork?.url(width: imageWidth, height: imageHeight) {
                        
                        return MTArtist(name: artist.name,
                                        catalogID: artist.id,
                                        libraryID: libraryArtist.id,
                                        topSongID: catalogSongID,
                                        imageUrl: artworkUrl)
                    } else {

                        return MTArtist(name: artist.name,
                                        catalogID: artist.id,
                                        libraryID: libraryArtist.id,
                                        topSongID: catalogSongID,
                                        imageUrl: nil)
                    }
                }
            }
        }
        
        // TODO: - MATCH NOT FOUND.... HANDLE IT
        
        throw fatalError()
    }
    
    
    
    func fetchArtistTopSongID(currArtist: Artist, currSource: MusicPropertySource) async throws -> MusicItemID? {
        
        let artistWithTopSongs = try await currArtist.with(
            [
                .topSongs
            ],
            preferredSource: currSource
        )
        
        print("\(artistWithTopSongs.name): \(artistWithTopSongs.topSongs?.first)")
        
        // MARK: - IF TOP SONG NIL; ARTIST DOESN'T EXIST
        guard let topSongID = artistWithTopSongs.topSongs?.first?.id else { return nil }
        
        return topSongID
    }
    
    
    // MARK: - MAPPING LIBRARY ARTIST IMAGE TO CATALOG ARTIST IMAGE
    func fetchCatalogArtistByImageURL(currArtist: MTArtist) async throws -> MTArtist? {
//        var request = MusicCatalogSearchRequest(term: currArtist.name, types: [Artist.self])
//        
//        let response = try await request.response()
        
//         MARK: - ARTIST WITH LIBRARY IMAGE BUT NO CATALOG IMAGE
//        if response.artists.isEmpty { return nil }
        
        let catalogArtists = try await searchCatalogArtists(term: currArtist.name)
        
        for artist in catalogArtists {
            
            if artist.name.lowercased() == currArtist.name.lowercased() {
                
                let catArtistImageURL = artist.artwork?.url(width: imageWidth, height: imageHeight)
                
                guard isMatchingImageURL(catArtistImageURL, currArtist.imageUrl) else {
                    return nil
                }
                
                return MTArtist(name: artist.name,
                                catalogID: artist.id,
                                libraryID: currArtist.libraryID,
                                imageUrl: currArtist.imageUrl)
                
            }
        }
        
        return nil
    }
    
    func isMatchingImageURL(_ imgUrl1: URL?, _ imgUrl2: URL?) -> Bool {
        
        guard let imgUrl1 = imgUrl1, let imgUrl2 = imgUrl2 else { return false }
        var strUrl1 = imgUrl1.absoluteString
        var strUrl2 = imgUrl2.absoluteString
        
        guard strUrl1.removeLast(6) == strUrl2.removeLast(6) else { return false }
        
        return true
    }
    
    func mapLibraryToCatalog(_ artists: [MTArtist]) async throws -> [MTArtist] {
        var catalogArtists: [MTArtist] = []
        
        // TODO: - MAP BY TOP SONG ID TOO?
        
        for artist in artists {
            
            guard let currID = artist.libraryID,
                    let currArtist = originalLibraryArtists[currID]
            else { fatalError() }
            
            // TODO: - VERIFY LIBRARY ARTIST IS VALID IN CATALOG, ELSE SKIP IT

            // CHECK IF LIBRARY ARTIST HAS IMAGEURL, IF YES THEN COMPARE TO CATALOG COUNTERPART
            if let _ = artist.imageUrl,
                let catArtistMatch = try await
                fetchCatalogArtistByImageURL(currArtist: artist) {
                // IMAGE URL MATCH FOUND -> ARTIST MAPPED
                
                catalogArtists.append(catArtistMatch)
            } else if let topSongID = try await fetchArtistTopSongID(currArtist: currArtist, currSource: .library) {
                // IF LIBRARY IMAGEURL DOESN'T EXIST, CHECK TOP SONG ID
                // COMPARE TOP SONG ID IF IT EXISTS
                
                // TOP SONG MATCH FOUND -> ARTIST MAPPED
                catalogArtists.append(try await fetchCatalogArtistByTopSongID(currArtist, librarySongID: topSongID))
            }
        }
        
        return catalogArtists
    }
    
    
    
    // Fetch all artists from library
    func fetchLibraryArtists(_ savedArtists: [MTArtist]) async throws -> [MTArtist] {
        var allArtists: [MTArtist] = []
        originalLibraryArtists.removeAll()
        
        var request = MusicLibraryRequest<Artist>()
        request.sort(by: \.name, ascending: true)
        let response = try await request.response()
        
        try await withThrowingTaskGroup(of: MTArtist?.self) { group in
            
            for artist in response.items {
                group.addTask {
                    
                    guard try await self.isArtistValid(artist, excludedArtists: savedArtists),
                            let currArtist = try await self.convertLibraryArtistToMTArtist(artist)
                    else { return nil }
                    
                    // Store original library artist object
                    self.originalLibraryArtists[artist.id] = artist
                    return currArtist
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
    
    
    // Converting library artist to MTArtist if valid
    func convertLibraryArtistToMTArtist(_ artist: Artist) async throws -> MTArtist? {
        
        if let imageURL = formatLibraryArtistArtwork(artist) {
            return MTArtist(name: artist.name,
                            libraryID: artist.id,
                            imageUrl: imageURL)
        } else {
            
            // Check if non-image artist exists in catalog via top song ID
            guard let topSongID = try await fetchArtistTopSongID(
                currArtist: artist,
                currSource: .library)
            else { return nil }
            
            return MTArtist(name: artist.name,
                            libraryID: artist.id,
                            topSongID: topSongID,
                            imageUrl: nil)
        }
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
            // TODO: - CONFIRM IF I CAN COMPARE OPTIONAL ID AND ID HERE
            if excludedArtists.contains(
                where: { $0.libraryID == currArtist.id }) {
                
                return true
            }
        
            // Edge case: artist imported from catalog, then user adds artist in their library -> compare imageURL
            let currArtistImageURL = formatLibraryArtistArtwork(currArtist)
            
            if excludedArtists.contains(
                where: { isMatchingImageURL($0.imageUrl, currArtistImageURL) }) {
                
                return true
            }
            
            // Worst case for assurance -> compare topSongID match if imageURL doesn't match
            // Edge case: artist in library with no image, but user adds artist from catalog with image
            guard let currArtistTopSongID = try await fetchArtistTopSongID(currArtist: currArtist, currSource: .library)
            else { return true }
            
            if excludedArtists.contains(
                where: { $0.topSongID == currArtistTopSongID }) {
                
                return true
            }
            
        case .catalog:
            // Check if catalogID match in excludedArtists
            // TODO: - CONFIRM IF I CAN COMPARE OPTIONAL ID AND ID HERE
            if excludedArtists.contains(where: { $0.catalogID == currArtist.id }) {
                return true
            }
        @unknown default:
            fatalError()
        }
        
        return false
    }
    
}
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
//    func getLibraryArtist(_ artistName: String) async throws -> Artist? {
//        if #available(iOS 16.0, *) {
//            var request = MusicLibraryRequest<Artist>()
//            request.sort(by: \.name, ascending: true)
//            
//            let response = try await request.response()
//            
//            for artist in response.items {
//                if artist.name == "LouieTheRapper" {
//                    
//                    var imageUrl = artist.artwork?.url(width: imageWidth, height: imageHeight)
//                    
//                    if let libraryUrl = imageUrl?.absoluteString {
//                        imageUrl = libraryUrl.formatToCatalogArtworkURL()
//                    }
//                    print("LIBRARY ARTIST MATCH1: \(artist.name)")
//                    print(imageUrl)
//                    guard let finalUrl = imageUrl else { fatalError() }
//                    print("LIBRARY ARTIST MATCH2: \(artist.name)")
//                    print(finalUrl)
//                    
//                    
//                }
//            }
//            
//            let foundArtist = response.items.first {
//                $0.name == artistName
//            }
////            print("FOUND LIBRARY ARTIST: \(foundArtist)")
//            guard let libArtist = foundArtist else { fatalError() }
//            
//            let allSongs = try await libArtist.with(
//                [
//                    .topSongs
//                ],
//                preferredSource: .library
//            )
//            
//            
//            print("LIBRARY ARTIST:")
//            print(allSongs.topSongs?.first)
//            print("LIBRARY ~~~~~~~~~~~~~~~~~~")
//
//            return allSongs
//        } else {
//            // Fallback on earlier versions
//        }
//        
//        return nil
//    }
//    
//    func getCatalogArtist(_ artistName: String) async throws -> Artist {
//        if #available(iOS 16.0, *) {
//            
//            var request = MusicCatalogSearchRequest(term: artistName, types: [Artist.self])
//            request.limit = 15
//            
//            let response = try await request.response()
//            print("RESPONSE ARTISTS: \(response.artists)")
//            
//            for artist in response.artists {
//                if artist.name == artistName {
//                    print("FOUND CATALOG MATCH: \(artist.name)")
//                    guard let artworkUrl = artist.artwork?.url(width: imageWidth, height: imageHeight) else { fatalError() }
//                    print(artworkUrl)
//                }
//                let allSongs = try await artist.with(
//                    [
//                        .topSongs
//                    ],
//                    preferredSource: .catalog
//                )
//                
//            }
//
//            guard let catalogArtist = response.artists.first else { fatalError() }
//
//            let allSongs = try await catalogArtist.with(
//                [
//                    .topSongs
//                ],
//                preferredSource: .catalog
//            )
//            
//            print("CATALOG ARTIST:")
//            print(allSongs.topSongs?.first)
//            print("CATALOG ~~~~~~~~~~~~~~~~~~")
//
//
//            return allSongs
//            
//        } else {
//            // Fallback on earlier versions
//        }
//        
//        throw fatalError()
//    }
//
//    
//
//
//    func fetchNewMusic() async throws {
//        if #available(iOS 16.0, *) {
//            var allArtists: [MTArtist] = []
//            
//            var request = MusicCatalogSearchRequest(term: "nocap", types: [Artist.self])
//            request.limit = 1
//            
//            let response = try await request.response()
//            
//            let artistData = response.artists.first
//            let artworkUrl = artistData?.artwork?.url(width: imageWidth, height: imageHeight)
//            guard let name = artistData?.name,
//                  let id = artistData?.id,
//                  let url = artworkUrl else { fatalError() }
//            var artist: MTArtist = MTArtist(name: name, id: id, imageUrl: url)
//            
//            guard let finalArtist = artistData else { fatalError() }
//            let allAlbums = try await finalArtist.with(
//                [
//                    .albums, // Y
//                    .appearsOnAlbums, // Y
//                    .compilationAlbums, // N
//                    .featuredAlbums, // N
//                    .topSongs,
//                    .latestRelease
//                ],
//                preferredSource: .catalog
//            )
//            
//            
//            
//            
//
//            var checker = allAlbums.albums ?? []
//            var batchIdx = 0
//            var totalAlbums: [String] = []
//            print("batch number \(batchIdx + 1) => \(checker.count) albums, hasNextBatch: \(checker.hasNextBatch)")
//            repeat {
//                print("ADDING IN BATCH NUMBER \(batchIdx + 1)")
//                for record in checker {
//                    totalAlbums.append("\(record.artistName): \(record.title)")
//                }
//                print("BATCH NUMBER \(batchIdx + 1) ALBUM COUNT: \(totalAlbums.count)")
//                if let nextBatchOfAlbums = try await checker.nextBatch() {
//                    checker = nextBatchOfAlbums
//                    batchIdx += 1
//                    print("batch number \(batchIdx + 1) => \(checker.count) albums, hasNextBatch: \(checker.hasNextBatch)")
//                } else {
//                    print("no more batches")
//                    break
//                }
//                
//            } while checker.hasNextBatch
//            
//            for record in checker {
//                totalAlbums.append("\(record.artistName): \(record.title)")
//            }
//        
//            print(totalAlbums)
//            print(totalAlbums.count)
//               
//            
//        } else {
//            // Fallback on earlier versions
//        }
//    }
//}
//
