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
    
//    var allArtists: [LibraryArtist] = []
    private init() {}
    
    func fetchMockData(_ name: String) async throws -> [MTArtist] {
        var allArtists: [MTArtist] = []
        
        if #available(iOS 16.0, *) {
            var request = MusicCatalogSearchRequest(term: name, types: [Artist.self])
            request.limit = 25
            
            let response = try await request.response()
            
            for artist in response.artists {
                
                // edge case: artist in library no longer exists in catalog
                
                var imageUrl = artist.artwork?.url(width: imageWidth, height: imageHeight)
                
                let person = MTArtist(name: artist.name, id: artist.id, imageUrl: imageUrl)
                allArtists.append(person)
            }
        } else {
            // Fallback on earlier versions
        }
        
        return allArtists
    }
    

    func fetchNewArtist(_ name: String) async throws -> MTArtist {
        if #available(iOS 16.0, *) {
            var allArtists: [MTArtist] = []
            
            var request = MusicCatalogSearchRequest(term: name, types: [Artist.self])
            request.limit = 1
    //        request.sort(by: \.albumCount, ascending: false)
            
            let response = try await request.response()
            
            let artistData = response.artists.first
    //        let artworkUrl = artistData?.artwork?.url(width: artistData?.artwork?.maximumWidth ?? 0, height: artistData?.artwork?.maximumHeight ?? 0)
            // TODO: - maxwidth/height = 2400
            let artworkUrl = artistData?.artwork?.url(width: imageWidth, height: imageHeight)
            guard let name = artistData?.name,
                  let id = artistData?.id,
                  let url = artworkUrl else { fatalError() }
            var artist: MTArtist = MTArtist(name: name, id: id, imageUrl: url)
            
            print("CATALOG ID: \(name) - \(id)")
            print("CATALOG ID RAWVAL: \(name) - \(id.rawValue)")
            
            guard let finalArtist = artistData else { fatalError() }
            
            
            
            return artist
            
        } else {
            // Fallback on earlier versions
        }
        
        throw fatalError()
    }


    func fetchLibraryArtists(_ savedArtists: [MTArtist]) async throws -> [MTArtist] {
        var allArtists: [MTArtist] = []
        
        if #available(iOS 16.0, *) {
            var request = MusicLibraryRequest<Artist>()
            
//            request.limit = 20
            request.sort(by: \.name, ascending: true)
            
            let response = try await request.response()
            
            for artist in response.items {
                
                if artist.name == "NoCap" {
                    print("LIBRARY ID: \(artist.name) - \(artist.id)")
                    print("LIBRARY ID RAWVALUE: \(artist.name) - \(artist.id.rawValue)")
                }
                
                // Omit artist objects that comprise of multiple artists
                if artist.name.contains(",") ||
                    artist.name.contains("&") ||
                    savedArtists.contains(where: {$0.name == artist.name}) {
                    continue
                }
                
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


    func searchAppleMusic() async throws {
        var allArtists: [MTArtist] = []
        
        if #available(iOS 16.0, *) {
            var libraryRequest = MusicLibraryRequest<Artist>()
            libraryRequest.limit = 5
            libraryRequest.sort(by: \.albumCount, ascending: false)
            let response = try await libraryRequest.response()
            var artistsList = response.debugDescription
            print(artistsList)
            
            for artist in response.items {
                print(artist)
                let person = MTArtist(name: artist.name, id: artist.id, imageUrl: artist.url)
                allArtists.append(person)
            }
            print(allArtists)
            
            var catalogRequest = MusicCatalogSearchRequest(term: "nocap", types: [Song.self])
            catalogRequest.limit = 10
            let response2 = try await catalogRequest.response()
            print(response2.debugDescription)
            
            
        } else {
            // Fallback on earlier versions
        }
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

