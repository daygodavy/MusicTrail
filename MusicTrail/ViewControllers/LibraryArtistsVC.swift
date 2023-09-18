//
//  LibraryArtistsVC.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/19/23.
//

import UIKit

protocol LibraryArtistVCDelegate: AnyObject {
    func importSavedArtists(_ newArtists: [MTArtist])
    func importInProgress()
}


class LibraryArtistsVC: MTDataLoadingVC {
    
    // MARK: - Variables
    var libraryArtists: [MTArtist] = []
    var filteredArtists: [MTArtist] = []
    var selectedArtists: [MTArtist] = []
    var savedArtists: [MTArtist] = []
    var isSearching: Bool = false
    
    weak var delegate: LibraryArtistVCDelegate?
    
    // MARK: - UI Components
    let tableView = UITableView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getLibraryArtists()
        configureNavBar()
        configureTableView()
        configureSearchBar()
        showLoadingView()
    }
    
    
    // MARK: - UI Setup
    private func configureNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Import", style: .plain, target: self, action: #selector(importButtonTapped))
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func configureTableView() {
        view.backgroundColor = .secondarySystemBackground
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.backgroundColor = .systemBackground
        tableView.rowHeight = 64
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(ArtistTVCell.self, forCellReuseIdentifier: ArtistTVCell.identifier)
    }
    
    private func configureSearchBar() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.image(for: .search, state: .normal)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    
    // MARK: - Methods
    @objc private func backButtonTapped() {
        if let navigationController = self.navigationController {
            navigationController.dismiss(animated: true)
        }
    }
    
    
    @objc private func importButtonTapped() {
        
        Task.init(priority: .background) {
            do {
                delegate?.importInProgress()
                
                backButtonTapped()
                
                selectedArtists = try await MusicKitManager.shared.mapLibraryToCatalog(selectedArtists)
                
                delegate?.importSavedArtists(selectedArtists)

            } catch {
                print("ERROR!!!!!!!!!!!")
                return
            }
            
        }
    }
    
    
    private func getLibraryArtists() {
        Task {
            do {
                libraryArtists = try await MusicKitManager.shared
                    .fetchLibraryArtists(savedArtists)
                libraryArtists.sort { $0.name.lowercased() < $1.name.lowercased() }
                filteredArtists = libraryArtists
                updateData()
                dismissLoadingView()
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
    
    private func updateTrackedArtist(_ index: Int) {
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
    
    private func updateImportStatus() {
        if !selectedArtists.isEmpty {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
}


// MARK: - UITableView Protocols
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
        updateTrackedArtist(indexPath.row)
        updateImportStatus()

        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }

}


// MARK: - UISearchController Protocols
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
