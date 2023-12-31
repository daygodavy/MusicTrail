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

class AddNewArtistVC: MTDataLoadingVC {
    
    // MARK: - Variables
    var searchedArtists: [MTArtist] = []
    var savedArtists: [MTArtist] = []
    var isSearching: Bool = false
    var isLoading: Bool = false
    
    var searchDelayTimer: Timer?
    let delayDuration: TimeInterval = 0.2
    
    var fetchArtistsTask: Task<Void, Never>?
    
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopLoader()
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
            self?.fetchArtistsTask = Task {
                do {
                    self?.isLoading = true
                    self?.showLoadingView()
                    let newResults = try await MusicKitManager.shared.fetchSearchedArtists(searchTerm, excludedArtists: self?.savedArtists ?? [])
                    
                    if searchTerm == self?.navigationItem.searchController?.searchBar.text {
                        self?.searchedArtists = newResults
                        self?.stopLoader()
                        self?.updateData()
                    }
                } catch {
                    Logger.shared.debug("ERROR!!!!!!!!!!! - \(error.localizedDescription)")
                    return
                }
            }
        })
    }
    
    
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
    
    private func searchTermUpdating() {
        fetchArtistsTask?.cancel()
        searchDelayTimer?.invalidate()
        searchedArtists.removeAll()
        stopLoader()
        updateData()
    }
    
    private func stopLoader() {
        if isLoading {
            isLoading = false
            dismissLoadingView()
        }
    }
    
    private func presentConfirmNewArtist(with artist: MTArtist) {
        searchDelayTimer?.invalidate()
        let vcToPresent = ConfirmNewArtistVC()
        vcToPresent.mtArtist = artist
        
        vcToPresent.onDismiss = { [weak self] in
            self?.saveSelectedArtist(artist)
        }
        
        vcToPresent.modalPresentationStyle = .overFullScreen
        present(vcToPresent, animated: true)
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
//        saveSelectedArtist(searchedArtists[indexPath.row])
        presentConfirmNewArtist(with: searchedArtists[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }

}


extension AddNewArtistVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        searchTermUpdating()
        guard let searchTerm = searchController.searchBar.text, !searchTerm.isEmpty else { return }
        getSearchedArtists(searchTerm)
    }

}
