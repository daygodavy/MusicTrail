//
//  AddNewArtistVC.swift
//  MusicTrail
//
//  Created by Davy Chuon on 9/11/23.
//

import UIKit

protocol AddNewArtistVCDelegate: AnyObject {
    func saveNewArtist(_ newArtist: MTArtist)
}

class AddNewArtistVC: UIViewController {
    
    // MARK: - Variables
    var searchedArtists: [MTArtist] = []
    var savedArtists: [MTArtist] = []
    var isSearching: Bool = false
    
    var searchDelayTimer: Timer?
    let delayDuration: TimeInterval = 0.25
    
    weak var delegate: AddNewArtistVCDelegate?
    
    // MARK: - UI Components
    let tableView = UITableView()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavBar()
        configureTableView()
        configureSearchBar()
    }

    
    // MARK: - UI Setup
    private func configureNavBar() {
        navigationItem.title = "Add New Artist"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(backButtonTapped))
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
    
    private func getSearchedArtists(_ searchTerm: String) {
        searchDelayTimer = Timer.scheduledTimer(withTimeInterval: delayDuration, repeats: false, block: { [weak self] _ in
            Task {
                do {
                    let newResults = try await MusicKitManager.shared.fetchSearchedArtists(searchTerm, excludedArtists: self?.savedArtists ?? [])
                    
                    if searchTerm == self?.navigationItem.searchController?.searchBar.text {
                        self?.searchedArtists = newResults
                        self?.updateData()
                    }
                } catch {
                    print("ERROR!!!!!!!!!!!")
                    return
                }
            }
        })
    }
    
//    private func getSearchedArtists(_ searchTerm: String) {
//        searchDelayTimer = Timer.scheduledTimer(withTimeInterval: delayDuration, repeats: false, block: { [weak self] _ in
//            Task {
//                do {
//                    self?.searchedArtists.removeAll()
//                    self?.updateData()
//                    self?.searchedArtists = try await MusicKitManager.shared.fetchSearchedArtists(searchTerm, excludedArtists: self?.savedArtists ?? [])
//                    self?.updateData()
//                } catch {
//                    print("ERROR!!!!!!!!!!!")
//                    return
//                }
//            }
//        })
//    }
    
    private func saveSelectedArtist(_ artist: MTArtist) {
        searchDelayTimer?.invalidate()
        delegate?.saveNewArtist(artist)
        backButtonTapped()
    }
    
    private func updateData() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
}


// MARK: - UITableView Protocols
extension AddNewArtistVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedArtists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ArtistTVCell.identifier, for: indexPath) as? ArtistTVCell else { fatalError("Unable to dequeue ArtistCell in ViewController") }
        
        let artist = searchedArtists[indexPath.row]
        cell.configure(with: artist, state: .adding)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        saveSelectedArtist(searchedArtists[indexPath.row])
    }

}


extension AddNewArtistVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        searchDelayTimer?.invalidate()
        guard let searchTerm = searchController.searchBar.text, !searchTerm.isEmpty else { return }
        getSearchedArtists(searchTerm)
    }

}
