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
                try await MusicKitManager.shared.fetchNewMusic()
            } catch {
                print("ERROR!")
            }
        }
    }
    
    
    
    // MARK: - UI Setup
    
    // MARK: - Methods
}
