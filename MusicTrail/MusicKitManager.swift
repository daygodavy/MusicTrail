//
//  MusicKitManager.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/14/23.
//

import MusicKit
import Foundation

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
            let person = LibraryArtist(name: artist.name)
            allArtists.append(person)
        }
        print(allArtists)
        


        
        var catalogRequest = MusicCatalogSearchRequest(term: "nocap", types: [Song.self])
        catalogRequest.limit = 10
        let response2 = try await catalogRequest.response()
        print(response2.debugDescription)
        
        
        
//            var testRequest = MusicCatalogSearchRequest(term: "nocap", types: [Song.self])
//            let currentYear = Calendar.current.component(.year, from: Date())
//            let startDate = DateComponents(calendar: .current, year: currentYear, month: 1, day: 1).date!
//            let dateFormatter = ISO8601DateFormatter()
//            testRequest.filterItems { item in
//                guard let releaseDate = item.releaseDate else { return false }
//                return releaseDate >= dateFormatter.string(from: startDate)
//            }
        
    } else {
        // Fallback on earlier versions
    }
    
    
    
    
//        if #available(iOS 16.0, *) {
//            var searchRequest = MusicLibrarySearchRequest(term: "Kanye", types: [Artist.self])
//            let response = try await searchRequest.response()
//            print(response)
//            print("========")
//        } else {
//            // Fallback on earlier versions
//        }
}
