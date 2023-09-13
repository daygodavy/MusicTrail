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
    

//    func fetchNewArtist(_ name: String) async throws -> MTArtist {
//        if #available(iOS 16.0, *) {
//            var allArtists: [MTArtist] = []
//            
//            var request = MusicCatalogSearchRequest(term: name, types: [Artist.self])
//            
////            request.limit = 1 // MARK: UNCOMMENT?
//             
//    //        request.sort(by: \.albumCount, ascending: false)
//            
//            let response = try await request.response()
//            if response.artists.isEmpty { print("EMPTY!!!!!!!")}
//            for artist in response.artists {
//                print("\(artist.name) is \(artist.genreNames):")
//                print(artist.latestRelease)
//                print("\n-------------------------------------------")
//            }
//            let artistData = response.artists.first
//            
//            
//
//            let artworkUrl = artistData?.artwork?.url(width: imageWidth, height: imageHeight)
//            
//            print("\(artistData?.name): \(artistData?.id) - \(artworkUrl)")
//            
//            
//            guard let name = artistData?.name,
//                  let id = artistData?.id,
//                  let url = artworkUrl else { fatalError() }
//            var artist: MTArtist = MTArtist(name: name, id: id, imageUrl: url)
//            
//            guard let finalArtist = artistData else { fatalError() }
//            
//            print(artist.name) // MARK: - DELETE
//
//            return artist
//            
//        } else {
//            // Fallback on earlier versions
//        }
//        
//        throw fatalError()
//    }
    
    func fetchNewArtist(_ name: String, librarySongID: MusicItemID) async throws -> MTArtist {
        if #available(iOS 16.0, *) {
            var allArtists: [MTArtist] = []
            
            var request = MusicCatalogSearchRequest(term: name, types: [Artist.self])
            
            
            let response = try await request.response()
            if response.artists.isEmpty { print("EMPTY!!!!!!!")}
            for artist in response.artists {
                if artist.name.lowercased() == name.lowercased() {
                    let catalogSongID = try await fetchArtistTopSongID(currArtist: artist, currSource: .catalog)
                    if catalogSongID == librarySongID {
                        print("MATCH FOUND")
                        guard let artworkUrl = artist.artwork?.url(width: imageWidth, height: imageHeight) else { fatalError() }
                        return MTArtist(name: artist.name, id: artist.id, imageUrl: artworkUrl)

                    }
                }
            }
            
            // TODO: - MATCH NOT FOUND.... HANDLE IT
            
            let artistData = response.artists.first
            
            

            let artworkUrl = artistData?.artwork?.url(width: imageWidth, height: imageHeight)
            
            
            guard let name = artistData?.name,
                  let id = artistData?.id,
                  let url = artworkUrl else { fatalError() }
            var artist: MTArtist = MTArtist(name: name, id: id, imageUrl: url)
            
            guard let finalArtist = artistData else { fatalError() }
            
            print(artist.name) // MARK: - DELETE

            return artist
            
        } else {
            // Fallback on earlier versions
        }
        
        throw fatalError()
    }
    
    
    @available(iOS 16.0, *)
    func mapLibraryToCatalog(_ artists: [MTArtist]) async throws -> [MTArtist] {
        var catalogArtists: [MTArtist] = []
        
        // TODO: - MAP BY TOP SONG ID TOO?
        
        for artist in artists {
            // TODO: - VERIFY LIBRARY ARTIST IS VALID IN CATALOG, ELSE SKIP IT
            // COMBINE BELOW CHECK SINCE ITS AN EXTRA SEARCHREQUEST
            if try await checkValidLibraryArtist(artist.name) {
                
                guard let currArtist = originalLibraryArtists[artist.id] else { fatalError() }
                
                let topSongID = try await fetchArtistTopSongID(currArtist: currArtist, currSource: .library)
                
                catalogArtists.append(try await fetchNewArtist(artist.name, librarySongID: topSongID))
            }
        }
        
        return catalogArtists
    }
    
    
    
    func checkValidLibraryArtist(_ artistName: String) async throws -> Bool {
        var request = MusicCatalogSearchRequest(term: artistName, types: [Artist.self])
        request.limit = 1
//        request.sort(by: \.albumCount, ascending: false)
        
        let response = try await request.response()
        if response.artists.isEmpty { return false }
        
        return true
    }

    func fetchLibraryArtists(_ savedArtists: [MTArtist]) async throws -> [MTArtist] {
        var allArtists: [MTArtist] = []
        originalLibraryArtists.removeAll()
        
        if #available(iOS 16.0, *) {
            var request = MusicLibraryRequest<Artist>()
            request.sort(by: \.name, ascending: true)
            
            let response = try await request.response()
            
            for artist in response.items {
                
                // Omit artist objects that comprise of multiple artists
                if artist.name.contains(",") ||
                    artist.name.contains("&") ||
                    (!savedArtists.isEmpty && savedArtists.contains(where: {$0.name.lowercased() == artist.name})) {
                    continue
                }
                
                // Store original artist
                originalLibraryArtists[artist.id] = artist
                
                // Convert artwork URL from library format to catalog format
                var imageUrl = artist.artwork?.url(width: imageWidth, height: imageHeight)
                
                if let libraryUrl = imageUrl?.absoluteString {
                    imageUrl = libraryUrl.formatToCatalogArtworkURL()
                }
                
                let person = MTArtist(name: artist.name, id: artist.id, imageUrl: imageUrl)
                allArtists.append(person)
            }
            
        } else {
            // Fallback on earlier versions
        }
        
        return allArtists
    }
    
    
//    func fetchLibraryArtists(_ savedArtists: [MTArtist]) async throws -> [MTArtist] {
//        var allArtists: [MTArtist] = []
//        
//        if #available(iOS 16.0, *) {
//            var request = MusicLibraryRequest<Artist>()
//            request.sort(by: \.name, ascending: true)
//            
//            let response = try await request.response()
//            
//            for artist in response.items {
//                
//                // Omit artist objects that comprise of multiple artists
//                if artist.name.contains(",") ||
//                    artist.name.contains("&") ||
//                    (!savedArtists.isEmpty && savedArtists.contains(where: {$0.name == artist.name})) {
//                    continue
//                }
//                
//                // Convert artwork URL from library format to catalog format
//                var imageUrl = artist.artwork?.url(width: imageWidth, height: imageHeight)
//                
//                if let libraryUrl = imageUrl?.absoluteString {
//                    imageUrl = libraryUrl.formatToCatalogArtworkURL()
//                }
//                
//                let person = MTArtist(name: artist.name, id: artist.id, imageUrl: imageUrl)
//                allArtists.append(person)
//            }
//            
//        } else {
//            // Fallback on earlier versions
//        }
//        
//        return allArtists
//    }
    
    @available(iOS 16.0, *)
    func fetchArtistTopSongID(currArtist: Artist, currSource: MusicPropertySource) async throws -> MusicItemID {

        let artistWithTopSongs = try await currArtist.with(
            [
                .topSongs
            ],
            preferredSource: currSource
        )
        
        // MARK: - IF TOP SONG NIL; ARTIST DOESN'T EXIST
        guard let topSongID = artistWithTopSongs.topSongs?.first?.id else { fatalError() }

        return topSongID
    }
    
    func getLibraryArtist(_ artistName: String) async throws -> Artist? {
        if #available(iOS 16.0, *) {
            var request = MusicLibraryRequest<Artist>()
            request.sort(by: \.name, ascending: true)
            
            let response = try await request.response()
            
            for artist in response.items {
                if artist.name == "Morgan" {
                    print("\(artist.name): \(artist.id): \(artist.topSongs?.first)")
                }
            }
            
            let foundArtist = response.items.first {
                $0.name == artistName
            }
            print("FOUND ARTIST: \(foundArtist)")
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
    
    
    func getCatalogArtist(_ artistName: String, topSong: Song) async throws -> Artist {
        
        if #available(iOS 16.0, *) {
            
            var request = MusicCatalogSearchRequest(term: artistName, types: [Artist.self])
            request.limit = 15
            
            let response = try await request.response()
            
            for artist in response.artists {
                let allSongs = try await artist.with(
                    [
                        .topSongs
                    ],
                    preferredSource: .catalog
                )
                guard let checkSong = allSongs.topSongs?.first else { fatalError() }
                if checkSong == topSong {
                    print("FOUND CATALOG MATCH: \(artist)")
                    return allSongs
                }
                
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
                    .topSongs
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

