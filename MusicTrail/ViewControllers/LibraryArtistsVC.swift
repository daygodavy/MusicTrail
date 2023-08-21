//
//  LibraryArtistsVC.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/19/23.
//

import UIKit

protocol LibraryArtistVCDelegate: AnyObject {
    func importSavedArtists(_ newArtists: [MTArtist])
}

class LibraryArtistsVC: UIViewController {
    
    // MARK: - Variables
    var libraryArtists: [MTArtist] = []
    var filteredArtists: [MTArtist] = []
    var selectedArtists: [MTArtist] = []
    var savedArtists: [MTArtist] = []
    var isSearching: Bool = false
    
    weak var delegate: LibraryArtistVCDelegate?
    
    // MARK: - UI Components
    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        view.backgroundColor = .systemRed
        
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Import", style: .plain, target: self, action: #selector(importButtonTapped))
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.rowHeight = 84
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(ArtistTVCell.self, forCellReuseIdentifier: ArtistTVCell.identifier)
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
    
    @objc private func importButtonTapped() {
        delegate?.importSavedArtists(selectedArtists)
        dismiss(animated: true)
    }
    
    private func getLibraryArtists() {
        Task {
            do {
                libraryArtists = try await MusicKitManager.shared.fetchLibraryArtists(savedArtists)
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
    
    
    private func updateLocalTracked(_ index: Int) {
        filteredArtists[index].isTracked.toggle()
        if let idxMatch = libraryArtists.firstIndex(where: {$0.name.contains(filteredArtists[index].name)}) {
            libraryArtists[idxMatch].isTracked = filteredArtists[index].isTracked
        }
        
        if filteredArtists[index].isTracked {
            selectedArtists.append(filteredArtists[index])
        } else {
            selectedArtists.removeAll(where: {$0.name == filteredArtists[index].name})
        }
    }
    
    private func updateSavedStatus() {
        if !selectedArtists.isEmpty {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
}


extension LibraryArtistsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredArtists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ArtistTVCell.identifier, for: indexPath) as? ArtistTVCell else { fatalError("Unable to dequeue ArtistCell in ViewController") }
        
        let artist = filteredArtists[indexPath.row]
        cell.configure(with: artist, state: .library)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // check logic here
        updateLocalTracked(indexPath.row)
        updateSavedStatus()

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
