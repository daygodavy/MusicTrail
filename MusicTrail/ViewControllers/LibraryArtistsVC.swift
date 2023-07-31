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
    var filteredArtists: [LibraryArtist] = []
    var isSearching: Bool = false
    
    // MARK: - UI Components
    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemRed
        
        setupNavBar()
        // setup tableview
        configureTableView()
        configureSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // setup artists data
        getLibraryArtists()
        
    }
    
    private func setupNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.rowHeight = 84
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(ArtistCell.self, forCellReuseIdentifier: ArtistCell.identifier)
    }
    
    private func configureSearchBar() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.image(for: .search, state: .normal)
//        searchController.obscuresBackgroundDuringPresentation = false

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
    }
    
    @objc private func backButtonTapped() {
        dismiss(animated: true)
    }
    
    private func getLibraryArtists() {
        Task {
            do {
                libraryArtists = try await MusicKitManager.shared.fetchLibraryArtists()
                filteredArtists = libraryArtists
                
                updateData()
            } catch {
                print("ERROR!!!!!!!!!!!")
                return
            }
        }
    }
    
    private func updateData() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    
}


extension LibraryArtistsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredArtists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ArtistCell.identifier, for: indexPath) as? ArtistCell else { fatalError("Unable to dequeue ArtistCell in ViewController") }
        
        let artist = filteredArtists[indexPath.row]
        cell.configure(with: artist)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        filteredArtists[indexPath.row].isSaved.toggle()
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    
}

extension LibraryArtistsVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            filteredArtists.removeAll()
            filteredArtists = libraryArtists
            updateData()
            isSearching = false
            return
        }
        
        isSearching = true
        filteredArtists = libraryArtists.filter {
            $0.name.lowercased().contains(filter.lowercased())
        }
        updateData()
        
    }
}
