//
//  NewMusicVC.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/18/23.
//

import UIKit

class NewMusicVC: UIViewController {
    
    // MARK: - Variables
    
    // MARK: - UI Components

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemTeal
        
        // TODO: - fetch new music
        fetchNewRecords()
    }
    
    func fetchNewRecords() {
        Task {
            do {
//                try await MusicKitManager.shared.fetchNewMusic()
//                try await MusicKitManager.shared.
                let artistName: String = "Morgan"
                let libraryArtist = try await MusicKitManager.shared.getLibraryArtist(artistName)
                
                guard let libraryTopSong = libraryArtist?.topSongs?.first else { return }
                
                let catalogArtist = try await MusicKitManager.shared.getCatalogArtist(artistName, topSong: libraryTopSong)
            
                guard let catalogTopSing = catalogArtist.topSongs?.first else { return }
                print("Library artist (\(libraryArtist?.name))- \(libraryArtist?.id): \(libraryTopSong)")
                print("Catalog artist (\(catalogArtist.name))- \(catalogArtist.id): \(catalogTopSing)")
                print("Same artist? -> \(libraryTopSong == catalogTopSing)")
            } catch {
                print("ERROR!")
            }
        }
    }
    
    
    
    // MARK: - UI Setup
    
    // MARK: - Methods
}
