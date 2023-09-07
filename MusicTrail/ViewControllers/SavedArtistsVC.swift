//
//  SavedArtistsVC.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/18/23.
//

import UIKit

class SavedArtistsVC: UIViewController {
    
    enum Section { case main }
    
    // MARK: - Variables
    private var savedArtists: [MTArtist] = []
    private var filteredArtists: [MTArtist] = []
    private var selectedArtists: [MTArtist] = []
    private let musicArtistRepo: MusicArtistRepo = MusicArtistRepo()
    private var isEditMode: Bool = false
    private var isSearching: Bool = false

    // MARK: - UI Components
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, MTArtist>!
    private var searchController = UISearchController()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getSavedArtists()
        setupSearchController()
        setupCollectionView()
        setupDataSource()
        setupDefaultNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func getSavedArtists() {
        savedArtists = musicArtistRepo.fetchSavedArtists()
        updateCVUI(with: savedArtists)
    }
    
    
    // MARK: - Setup UI
    private func setupDefaultNavBar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        
        let libraryButton = UIBarButtonItem(image: UIImage(systemName: "music.note.list"), style: .plain, target: self, action: #selector(libraryButtonTapped))
        
        navigationItem.rightBarButtonItems = [addButton, libraryButton]
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped))
    }
    
    private func setupEditNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Unfollow", style: .plain, target: self, action: #selector(unfollowButtonTapped))]
        navigationItem.rightBarButtonItem?.isEnabled = !selectedArtists.isEmpty
    }
    
    private func updateNavBar() {
        switch isEditMode {
        case true:
            setupEditNavBar()
            searchController.searchBar.isHidden = true
        case false:
            setupDefaultNavBar()
            searchController.searchBar.isHidden = false
        }
    }
    
    @objc private func editButtonTapped() {
        isEditMode.toggle()
        updateNavBar()
    }

    @objc private func unfollowButtonTapped() {
        // MARK: - CHECK LOGIC BELOW
        editButtonTapped()
        
        // delete isTracked in savedArtists
        for artist in selectedArtists {
            guard let index = savedArtists.firstIndex(of: artist) else { return }
            deleteArtist(index)
        }
        
        selectedArtists.removeAll()
    }
    
    
    @objc private func cancelButtonTapped() {
        editButtonTapped()
        resetTracked()
        updateData(on: savedArtists)
    }
    
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Artist"
        searchController.searchBar.image(for: .search, state: .normal)
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }
    
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: view))
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(ArtistCVCell.self, forCellWithReuseIdentifier: ArtistCVCell.reuseID)
    }
    
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, MTArtist>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, artist) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArtistCVCell.reuseID, for: indexPath) as! ArtistCVCell
            
            cell.set(artist: artist)
            
            if artist.isTracked {
                cell.backgroundColor = UIColor.systemGray.withAlphaComponent(0.5)
            } else {
                cell.backgroundColor = .clear
            }
            cell.layer.cornerRadius = 5
            
            return cell
        })
    }
    
    func updateCVUI(with artists: [MTArtist]) {
        
        if !savedArtists.isEmpty {
            updateData(on: savedArtists)
        } else {
            // TODO: - empty state
            // Hide search bar
            // Disable vertical scroll bounce for collection view
        }
    }
    
    func updateData(on artists: [MTArtist]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MTArtist>()
        snapshot.appendSections([.main])
        snapshot.appendItems(artists)
        
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    
    
    // MARK: - Methods
    @objc func libraryButtonTapped() {
        let vcToPresent = LibraryArtistsVC()
        vcToPresent.delegate = self
        vcToPresent.savedArtists = self.savedArtists
        
        let navController = UINavigationController(rootViewController: vcToPresent)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }

    
    @objc func addButtonTapped() {
        let ac = UIAlertController(title: "New Artist", message: nil, preferredStyle: .alert)
        ac.addTextField { textField in
            textField.placeholder = "Enter artist name"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let textField = ac.textFields?.first,
                  let artist = textField.text,
                  !artist.isEmpty else { return }
            
            self?.addNewArtist(artist)
        }
        
        ac.addAction(cancelAction)
        ac.addAction(addAction)
        present(ac, animated: true)
    }
    
    
    func addNewArtist(_ artistName: String) {
        Task {
            do {
                let newArtist = try await MusicKitManager.shared.fetchNewArtist(artistName)
//                savedArtists.append(newArtist)
//                DispatchQueue.main.async { [weak self] in
//                    self?.tableView.reloadData()
//                }
            } catch {
                print("ERROR!")
            }
        }
    }
    
    
    private func deleteArtist(_ index: Int) {
        let artistToDelete = savedArtists.remove(at: index)
        updateData(on: savedArtists)
        musicArtistRepo.unsaveArtist(artistToDelete)
    }
    
    
    private func resetTracked() {
        for i in 0..<savedArtists.count {
            savedArtists[i].isTracked = false
        }
    }

}


// MARK: - UICollectionView protocols
extension SavedArtistsVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let currentArtists = isSearching ? filteredArtists : savedArtists
//        let selectedArtist = currentArtists[indexPath.item]
//        print(selectedArtist.name)
        
        
        if isEditMode && !isSearching {
            savedArtists[indexPath.item].isTracked.toggle()
            
            let selectedArtist = savedArtists[indexPath.item]
            selectedArtist.isTracked ?
            selectedArtists.append(selectedArtist) :
            selectedArtists.removeAll(where: { $0.name == selectedArtist.name })
            
            updateData(on: savedArtists)
            updateNavBar()
        }
    
        
//        deleteArtist(indexPath)
    }
}

extension SavedArtistsVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            filteredArtists.removeAll()
            updateData(on: savedArtists)
            isSearching = false
            return
        }
        
        isSearching = true
        filteredArtists = savedArtists.filter {
            $0.name.lowercased().contains(filter.lowercased())
        }
        updateData(on: filteredArtists)
        
        
    }
}


// MARK: - LibraryArtistVC protocols
extension SavedArtistsVC: LibraryArtistVCDelegate {
    func importSavedArtists(_ newArtists: [MTArtist]) {
        savedArtists.append(contentsOf: newArtists)
        musicArtistRepo.saveLibraryArtists(newArtists)
        resetTracked()
        updateCVUI(with: savedArtists)
//        updateUI()
        
    }
}
