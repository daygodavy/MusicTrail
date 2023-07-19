//
//  ViewController.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/11/23.
//


import MusicKit
import MediaPlayer
import UIKit

class ViewController: UIViewController {

    // MARK: - Variables
    private var artists: [LibraryArtist] = []
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .systemBackground
        tv.register(ArtistCell.self, forCellReuseIdentifier: ArtistCell.identifier)
        return tv
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testFetch()
        setupUI()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    // MARK: - Setup UI
    func setupUI() {
        view.backgroundColor = .systemBlue
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
        ])
    }
    
    // MARK: - Selectors
    

    
    func testFetch() {
        Task {
            
            await requestMusicAuthorization()
         
            do {
                try await checkAppleMusicStatus()
                
            } catch {
                print("error")
            }
            
            
            do {
//                try await searchAppleMusic()
                artists = try await fetchLibraryArtists()
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("error2")
            }
        }
    }

}



// MARK: - TableView Functions
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ArtistCell.identifier, for: indexPath) as? ArtistCell else { fatalError("Unable to dequeue ArtistCell in ViewController") }
        
        let artist = artists[indexPath.row]
        cell.configure(with: artist)
        
        return cell
    }
    
}
