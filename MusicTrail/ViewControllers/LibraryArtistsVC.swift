//
//  LibraryArtistsVC.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/19/23.
//

import UIKit

class LibraryArtistsVC: UIViewController {
    
    // MARK: - Variables
    var libraryArtists: [LibraryArtist] = []
    
    // MARK: - UI Components
    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemRed
        // setup tableview
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // setup artists data
        
    }
    
    func configureTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.rowHeight = 84
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(ArtistCell.self, forCellReuseIdentifier: ArtistCell.identifier)
    }

}


extension LibraryArtistsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return libraryArtists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ArtistCell.identifier, for: indexPath) as? ArtistCell else { fatalError("Unable to dequeue ArtistCell in ViewController") }
        
        let artist = libraryArtists[indexPath.row]
        cell.configure(with: artist)
        
        return cell
    }
    
    
}
