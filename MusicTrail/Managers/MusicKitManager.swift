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
    
    func fetchSearchedArtists(_ searchTerm: String, savedArtists: [MTArtist]) async throws -> [MTArtist] {
        if #available(iOS 16.0, *) {
            var resultArtists: [MTArtist] = []
            
            var request = MusicCatalogSearchRequest(term: searchTerm, types: [Artist.self])
            request.limit = 15
            
            let response = try await request.response()
            
            let searchedArtists = response.artists
            for artist in searchedArtists {

                if !savedArtists.isEmpty && savedArtists.contains(where: {$0.name == artist.name}) {
                    continue
                }
                let artworkUrl = artist.artwork?.url(width: imageWidth, height: imageHeight)
                
                let currentArtist = MTArtist(name: artist.name, id: artist.id, imageUrl: artworkUrl)
//                let currentArtist = MTArtist(name: artist.name, imageUrl: artworkUrl, topSongID: topSongId, catalogID: artist.id)
                resultArtists.append(currentArtist)
            }
            
            return resultArtists
            
        } else {
            // Fallback on earlier versions
        }
        
        throw fatalError()
    }
    
    
    func fetchNewArtist(_ name: String, librarySongID: MusicItemID) async throws -> MTArtist {
        if #available(iOS 16.0, *) {
            var allArtists: [MTArtist] = []
            
            var request = MusicCatalogSearchRequest(term: name, types: [Artist.self])
            
            let response = try await request.response()
            
            if response.artists.isEmpty { print("EMPTY!!!!!!!")}
            
            for artist in response.artists {
                
                if artist.name.lowercased() == name.lowercased() {
                    
                    guard let catalogSongID = try await fetchArtistTopSongID(currArtist: artist, currSource: .catalog) else { fatalError() }
                    
                    if catalogSongID == librarySongID {
                        print("MATCH FOUND")
                        
                        if let artworkUrl = artist.artwork?.url(width: imageWidth, height: imageHeight) {
                            return MTArtist(name: artist.name, id: artist.id, imageUrl: artworkUrl)
                        } else {
                            return MTArtist(name: artist.name, id: artist.id, imageUrl: nil)
                        }
                    }
                }
            }
            
            // TODO: - MATCH NOT FOUND.... HANDLE IT
            
        } else {
            // Fallback on earlier versions
        }
        
        throw fatalError()
    }
    
    
    func mapLibraryToCatalog(_ artists: [MTArtist]) async throws -> [MTArtist] {
        var catalogArtists: [MTArtist] = []
        
        // TODO: - MAP BY TOP SONG ID TOO?
        
        for artist in artists {
            
            guard let currArtist = originalLibraryArtists[artist.id] else
            {
                fatalError()
            }
            
            // TODO: - VERIFY LIBRARY ARTIST IS VALID IN CATALOG, ELSE SKIP IT
            // COMBINE BELOW CHECK SINCE ITS AN EXTRA SEARCHREQUEST
            if artist.imageUrl == nil {
                // TODO: - COMPARE TOP SONG ID IF IT EXISTS
                
                if let topSongID = try await fetchArtistTopSongID(currArtist: currArtist, currSource: .library) {
                    
                    // TOP SONG MATCH FOUND -> ARTIST MAPPED
                    catalogArtists.append(try await fetchNewArtist(artist.name, librarySongID: topSongID))
                } else {
                    // TOP SONG MATCH NOT FOUND
                    continue
                }
                
            } else {
                // TODO: - COMPARE IMAGE URL
                
                if let artistCatalogMatch = try await fetchArtistImageURL(currArtist: artist) {
                    // IMAGE URL FOUND -> ARTIST MAPPED
                    
                    catalogArtists.append(artistCatalogMatch)
                } else {
                    if let topSongID = try await fetchArtistTopSongID(currArtist: currArtist, currSource: .library) {
                        
                        // TOP SONG MATCH FOUND -> ARTIST MAPPED
                        catalogArtists.append(try await fetchNewArtist(artist.name, librarySongID: topSongID))
                    } else {
                        continue
                    }
                }
                
                // IMAGE URL NOT FOUND -> ATTEMPT TOP SONG MATCH
            }
            
        }
        
        return catalogArtists
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
    
    func fetchArtistImageURL(currArtist: MTArtist) async throws -> MTArtist? {
        var request = MusicCatalogSearchRequest(term: currArtist.name, types: [Artist.self])
        
        let response = try await request.response()
        
        // MARK: - ARTIST WITH LIBRARY IMAGE BUT NO CATALOG IMAGE
        if response.artists.isEmpty {
            print("EMPTY!!!!!!!")
            return nil
        }
        
        for artist in response.artists {
            
            if artist.name.lowercased() == currArtist.name.lowercased() {
                
                if let artworkUrl = artist.artwork?.url(width: imageWidth, height: imageHeight), let currUrl = currArtist.imageUrl {
                    
                    var catalogStr = artworkUrl.absoluteString
                    var libraryStr = currUrl.absoluteString
                    
                    let catalogCheck: () = catalogStr.removeLast(6)
                    let libraryCheck: () = libraryStr.removeLast(6)
                    
                    if catalogCheck == libraryCheck {
                        print("MATCHING URL")
                        
                        return MTArtist(name: artist.name, id: artist.id, imageUrl: currUrl)
                    }
                    
                } else {
                    // IMAGE URL DOESN'T EXIST COMPARE TOP SONGS
                }
            }
        }
        
        return nil
    }
    

    // Fetch all artists from library
    func fetchLibraryArtists(_ savedArtists: [MTArtist]) async throws -> [MTArtist] {
        var allArtists: [MTArtist] = []
        originalLibraryArtists.removeAll()
        
        var request = MusicLibraryRequest<Artist>()
        request.sort(by: \.name, ascending: true)
        
        let response = try await request.response()
        
        for artist in response.items {
            
            if !isArtistValid(artist.name, excludedArtists: savedArtists) { continue }
            
            if let currArtist = try await convertLibraryArtistToMTArtist(artist) {
                
                // Store original library artist object
                originalLibraryArtists[artist.id] = artist
                allArtists.append(currArtist)
            }
        }
            
        return allArtists
    }
    
    
    // Converting library artist to MTArtist if valid
    func convertLibraryArtistToMTArtist(_ artist: Artist) async throws -> MTArtist? {
        
        if let imageUrl = formatLibraryArtistArtwork(artist) {
            return MTArtist(name: artist.name, id: artist.id, imageUrl: imageUrl)
        } else {
            
            // Check if non-image artist exists in catalog via top song ID
            if try await fetchArtistTopSongID(currArtist: artist, currSource: .library) != nil {
                return MTArtist(name: artist.name, id: artist.id, imageUrl: nil)
            }
        }
        
        return nil
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
    func isArtistValid(_ artistName: String, excludedArtists: [MTArtist]) -> Bool {
        
        if artistName.contains(",") ||
            artistName.contains("&") ||
            artistName.lowercased().contains("various artists") ||
            (!excludedArtists.isEmpty &&
             excludedArtists.contains(where: { $0.name.lowercased() == artistName.lowercased() })) {
            return false
        }
        
        return true
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func getLibraryArtist(_ artistName: String) async throws -> Artist? {
        if #available(iOS 16.0, *) {
            var request = MusicLibraryRequest<Artist>()
            request.sort(by: \.name, ascending: true)
            
            let response = try await request.response()
            
            for artist in response.items {
                if artist.name == "LouieTheRapper" {
                    
                    var imageUrl = artist.artwork?.url(width: imageWidth, height: imageHeight)
                    
                    if let libraryUrl = imageUrl?.absoluteString {
                        imageUrl = libraryUrl.formatToCatalogArtworkURL()
                    }
                    print("LIBRARY ARTIST MATCH1: \(artist.name)")
                    print(imageUrl)
                    guard let finalUrl = imageUrl else { fatalError() }
                    print("LIBRARY ARTIST MATCH2: \(artist.name)")
                    print(finalUrl)
                    
                    
                }
            }
            
            let foundArtist = response.items.first {
                $0.name == artistName
            }
//            print("FOUND LIBRARY ARTIST: \(foundArtist)")
            guard let libArtist = foundArtist else { fatalError() }
            
            let allSongs = try await libArtist.with(
                [
                    .topSongs
                ],
                preferredSource: .library
            )
            
            
            print("LIBRARY ARTIST:")
            print(allSongs.topSongs?.first)
            print("LIBRARY ~~~~~~~~~~~~~~~~~~")

            return allSongs
        } else {
            // Fallback on earlier versions
        }
        
        return nil
    }
    
    func getCatalogArtist(_ artistName: String) async throws -> Artist {
        if #available(iOS 16.0, *) {
            
            var request = MusicCatalogSearchRequest(term: artistName, types: [Artist.self])
            request.limit = 15
            
            let response = try await request.response()
            print("RESPONSE ARTISTS: \(response.artists)")
            
            for artist in response.artists {
                if artist.name == artistName {
                    print("FOUND CATALOG MATCH: \(artist.name)")
                    guard let artworkUrl = artist.artwork?.url(width: imageWidth, height: imageHeight) else { fatalError() }
                    print(artworkUrl)
                }
                let allSongs = try await artist.with(
                    [
                        .topSongs
                    ],
                    preferredSource: .catalog
                )
                
            }

            guard let catalogArtist = response.artists.first else { fatalError() }

            let allSongs = try await catalogArtist.with(
                [
                    .topSongs
                ],
                preferredSource: .catalog
            )
            
            print("CATALOG ARTIST:")
            print(allSongs.topSongs?.first)
            print("CATALOG ~~~~~~~~~~~~~~~~~~")


            return allSongs
            
        } else {
            // Fallback on earlier versions
        }
        
        throw fatalError()
    }
    
    
//    func getCatalogArtist(_ artistName: String, topSong: Song) async throws -> Artist {
//        print("\(artistName): \(topSong)!!!!!!!!!")
//        if #available(iOS 16.0, *) {
//            
//            var request = MusicCatalogSearchRequest(term: artistName, types: [Artist.self])
//            request.limit = 15
//            
//            let response = try await request.response()
//            
//            for artist in response.artists {
//                let allSongs = try await artist.with(
//                    [
//                        .topSongs
//                    ],
//                    preferredSource: .catalog
//                )
//                guard let checkSong = allSongs.topSongs?.first else { fatalError() }
//                if checkSong == topSong {
//                    print("FOUND CATALOG MATCH: \(artist.name)")
//                    guard let artworkUrl = artist.artwork?.url(width: imageWidth, height: imageHeight) else { fatalError() }
//                    print(artworkUrl)
//                    return allSongs
//                }
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
    


    func fetchNewMusic() async throws {
        if #available(iOS 16.0, *) {
            var allArtists: [MTArtist] = []
            
            var request = MusicCatalogSearchRequest(term: "nocap", types: [Artist.self])
            request.limit = 1
            
            let response = try await request.response()
            
            let artistData = response.artists.first
            let artworkUrl = artistData?.artwork?.url(width: imageWidth, height: imageHeight)
            guard let name = artistData?.name,
                  let id = artistData?.id,
                  let url = artworkUrl else { fatalError() }
            var artist: MTArtist = MTArtist(name: name, id: id, imageUrl: url)
            
            guard let finalArtist = artistData else { fatalError() }
            let allAlbums = try await finalArtist.with(
                [
                    .albums, // Y
                    .appearsOnAlbums, // Y
                    .compilationAlbums, // N
                    .featuredAlbums, // N
                    .topSongs,
                    .latestRelease
                ],
                preferredSource: .catalog
            )
            
            
            
            

            var checker = allAlbums.albums ?? []
            var batchIdx = 0
            var totalAlbums: [String] = []
            print("batch number \(batchIdx + 1) => \(checker.count) albums, hasNextBatch: \(checker.hasNextBatch)")
            repeat {
                print("ADDING IN BATCH NUMBER \(batchIdx + 1)")
                for record in checker {
                    totalAlbums.append("\(record.artistName): \(record.title)")
                }
                print("BATCH NUMBER \(batchIdx + 1) ALBUM COUNT: \(totalAlbums.count)")
                if let nextBatchOfAlbums = try await checker.nextBatch() {
                    checker = nextBatchOfAlbums
                    batchIdx += 1
                    print("batch number \(batchIdx + 1) => \(checker.count) albums, hasNextBatch: \(checker.hasNextBatch)")
                } else {
                    print("no more batches")
                    break
                }
                
            } while checker.hasNextBatch
            
            for record in checker {
                totalAlbums.append("\(record.artistName): \(record.title)")
            }
        
            print(totalAlbums)
            print(totalAlbums.count)
               
            
        } else {
            // Fallback on earlier versions
        }
    }
}

