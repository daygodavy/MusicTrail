//
//  SavedArtistsVC.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/18/23.
//

import UIKit

class SavedArtistsVC: MTDataLoadingVC {
    
    enum Section { case main }
    
    // MARK: - Variables
    private var savedArtists: [MTArtist] = []
    private var filteredArtists: [MTArtist] = []
    private var selectedArtists: [MTArtist] = []
    private let musicArtistRepo: MusicArtistRepo = MusicArtistRepo()
    private var isEditMode: Bool = false
    private var isSearching: Bool = false
    private var isImporting: Bool = false

    // MARK: - UI Components
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, MTArtist>!
    private var searchController = UISearchController()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showLoadingView()
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
        dismissLoadingView()
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
//            savedArtists.sort { $0.name < $1.name }
            updateData(on: savedArtists)
        } else {
            // TODO: - empty state
            // Hide search bar
            // Disable vertical scroll bounce for collection view
        }
    }
    
    func updateData(on artists: [MTArtist]) {
//        var sortedArtists = artists.sorted { $0.name < $1.name }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, MTArtist>()
        snapshot.appendSections([.main])
        snapshot.appendItems(artists)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.dataSource.apply(snapshot, animatingDifferences: true)
            
            if self.isImporting {
                self.isImporting = false
                dismissLoadingNavBarButton()
                updateNavBar()
            }
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
        let vcToPresent = AddNewArtistVC()
        vcToPresent.delegate = self
        vcToPresent.savedArtists = self.savedArtists
        
        let navController = UINavigationController(rootViewController: vcToPresent)
        navController.modalPresentationStyle = .popover
        present(navController, animated: true)
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
        
        if isEditMode && !isSearching {
            savedArtists[indexPath.item].isTracked.toggle()
            
            let selectedArtist = savedArtists[indexPath.item]
            selectedArtist.isTracked ?
            selectedArtists.append(selectedArtist) :
            selectedArtists.removeAll(where: { $0.name == selectedArtist.name })
            
            updateData(on: savedArtists)
            updateNavBar()
        } else {
            //        let currentArtists = isSearching ? filteredArtists : savedArtists
            //        let selectedArtist = currentArtists[indexPath.item]
            //        print(selectedArtist.name)
        }
    
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


// MARK: - LibraryArtistVC Protocols
extension SavedArtistsVC: LibraryArtistVCDelegate {
    
    func importSavedArtists(_ newArtists: [MTArtist]) {
        savedArtists.append(contentsOf: newArtists)
        savedArtists.sort { $0.name.lowercased() < $1.name.lowercased() }
        musicArtistRepo.saveLibraryArtists(newArtists)
        updateCVUI(with: savedArtists)
        
    }
    
    
    func importInProgress() {
        isImporting = true
        showLoadingNavBarButton()
    }
}


// MARK: - AddNewArtistVC Protocols
extension SavedArtistsVC: AddNewArtistVCDelegate {
    
    func saveNewArtist(_ newArtist: MTArtist) {
        savedArtists.append(newArtist)
        savedArtists.sort { $0.name.lowercased() < $1.name.lowercased() }
        musicArtistRepo.saveCatalogArtist(newArtist)
        
        resetTracked()
        updateCVUI(with: savedArtists)
    }
}
