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
                print(artist.name)
                print(artworkUrl)
                let currentArtist = MTArtist(name: artist.name, id: artist.id, imageUrl: artworkUrl)
                resultArtists.append(currentArtist)
            }
            
            return resultArtists
            
        } else {
            // Fallback on earlier versions
        }
        
        throw fatalError()
    }
    

    func fetchNewArtist(_ name: String) async throws -> MTArtist {
        if #available(iOS 16.0, *) {
            var allArtists: [MTArtist] = []
            
            var request = MusicCatalogSearchRequest(term: name, types: [Artist.self])
            request.limit = 1
    //        request.sort(by: \.albumCount, ascending: false)
            
            let response = try await request.response()
            
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
    
    
    func mapLibraryToCatalog(_ artists: [MTArtist]) async throws -> [MTArtist] {
        var catalogArtists: [MTArtist] = []
        
        for artist in artists {
            catalogArtists.append(try await fetchNewArtist(artist.name))
        }
        
        return catalogArtists
    }


    func fetchLibraryArtists(_ savedArtists: [MTArtist]) async throws -> [MTArtist] {
        var allArtists: [MTArtist] = []
        
        if #available(iOS 16.0, *) {
            var request = MusicLibraryRequest<Artist>()
            request.sort(by: \.name, ascending: true)
            
            let response = try await request.response()
            
            for artist in response.items {
                
                // Omit artist objects that comprise of multiple artists
                if artist.name.contains(",") ||
                    artist.name.contains("&") ||
                    (!savedArtists.isEmpty && savedArtists.contains(where: {$0.name == artist.name})) {
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

