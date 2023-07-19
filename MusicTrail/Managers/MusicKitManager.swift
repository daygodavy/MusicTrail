//
//  MusicKitManager.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/14/23.
//

import MusicKit
import UIKit

var isAuthorizedForMusicKit = false
var musicAuthStatus: MusicAuthorization.Status? = nil
var appleMusicSubStatus: Bool = false
var allArtists: [LibraryArtist] = []

func requestMusicAuthorization() async {
    musicAuthStatus = await MusicAuthorization.request()
    
}

func checkAppleMusicStatus() async throws {
    let currentSub = try await MusicSubscription.current
    print(currentSub)

}

func fetchNewArtist(_ name: String) async throws -> LibraryArtist {
    if #available(iOS 16.0, *) {
        var request = MusicCatalogSearchRequest(term: name, types: [Artist.self])
        request.limit = 1
//        request.sort(by: \.albumCount, ascending: false)
        
        let response = try await request.response()
        
        let artistData = response.artists.first
//        let artworkUrl = artistData?.artwork?.url(width: artistData?.artwork?.maximumWidth ?? 0, height: artistData?.artwork?.maximumHeight ?? 0)
        // TODO: - maxwidth/height = 2400
        let artworkUrl = artistData?.artwork?.url(width: 168, height: 168)
        guard let name = artistData?.name,
              let id = artistData?.id,
              let url = artworkUrl else { fatalError() }
        print("URL!!!: \(url)")
        var artist: LibraryArtist = LibraryArtist(name: name, id: id, imageUrl: url)
        
        return artist
        
    } else {
        // Fallback on earlier versions
    }
    
    throw fatalError()
}


func fetchLibraryArtists() async throws -> [LibraryArtist] {
    if #available(iOS 16.0, *) {
        var request = MusicLibraryRequest<Artist>()
        
        request.limit = 20
        request.sort(by: \.albumCount, ascending: false)
        
        let response = try await request.response()
        
        for artist in response.items {
            
            let imageUrl = artist.artwork?.url(width: 168, height: 168)
            guard let libraryUrl = imageUrl else { fatalError() }
            
            let url = formatToCatalogArtworkURL(libraryUrl)
            
            let person = LibraryArtist(name: artist.name, id: artist.id, imageUrl: url)
            allArtists.append(person)
        }
        
    } else {
        // Fallback on earlier versions
    }
    
    return allArtists
}


func formatToCatalogArtworkURL(_ url: URL) -> URL {
    let urlString = url.absoluteString
    
    if let urlComponents = URLComponents(string: urlString),
       let queryItems = urlComponents.queryItems,
       let aatItem = queryItems.first(where: { $0.name == "aat" }),
       let aatValue = aatItem.value,
       let aatURL = URL(string: aatValue) {
        return aatURL
    }
    

    return url
}


func searchAppleMusic() async throws {
    if #available(iOS 16.0, *) {
        var libraryRequest = MusicLibraryRequest<Artist>()
        libraryRequest.limit = 5
        libraryRequest.sort(by: \.albumCount, ascending: false)
        let response = try await libraryRequest.response()
        var artistsList = response.debugDescription
        print(artistsList)
        
        for artist in response.items {
            print(artist)
            let person = LibraryArtist(name: artist.name, id: artist.id, imageUrl: artist.url)
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



//            var testRequest = MusicCatalogSearchRequest(term: "nocap", types: [Song.self])
//            let currentYear = Calendar.current.component(.year, from: Date())
//            let startDate = DateComponents(calendar: .current, year: currentYear, month: 1, day: 1).date!
//            let dateFormatter = ISO8601DateFormatter()
//            testRequest.filterItems { item in
//                guard let releaseDate = item.releaseDate else { return false }
//                return releaseDate >= dateFormatter.string(from: startDate)
//            }
