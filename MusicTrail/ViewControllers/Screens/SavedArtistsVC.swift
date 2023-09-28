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
//    private var selectedArtists: [MTArtist] = []
    private var isEditMode: Bool = false
    private var isSearching: Bool = false
    private var isImporting: Bool = false
    private var isEmptyState: Bool = false
    
    private var selectedArtistIDs: Set<String> = []

    
    // MARK: - UI Components
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, MTArtist>!
    private var searchController = UISearchController()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showLoadingView()
        getSavedArtists()
        setupDefaultNavBar()
        setupSearchController()
        setupCollectionView()
        setupDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func getSavedArtists() {
        savedArtists = MusicDataManager.shared.getSavedArtists()
        updateCVUI(with: savedArtists)
        dismissLoadingView()
    }
    
    
    // MARK: - Setup UI
    private func setupDefaultNavBar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        
        let libraryButton = UIBarButtonItem(image: SFSymbol.libraryImport, style: .plain, target: self, action: #selector(libraryButtonTapped))
        
        navigationItem.rightBarButtonItems = [addButton, libraryButton]
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped))
    }
    
    private func setupEditNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Unfollow", style: .plain, target: self, action: #selector(unfollowButtonTapped))]
//        navigationItem.rightBarButtonItem?.isEnabled = !selectedArtists.isEmpty
        navigationItem.rightBarButtonItem?.isEnabled = !selectedArtistIDs.isEmpty
    }
    
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Artist"
        searchController.searchBar.image(for: .search, state: .normal)
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }
    
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UIHelper.createColumnFlowLayout(in: view, numCols: 3))
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(ArtistCVCell.self, forCellWithReuseIdentifier: ArtistCVCell.reuseID)
    }

    
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, MTArtist>(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, artist in
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArtistCVCell.reuseID, for: indexPath) as! ArtistCVCell
                
                cell.set(artist: artist)
                
                guard let catID = artist.catalogID else { return cell }
//                cell.isHighlighted = self.selectedArtistIDs.contains(catID.rawValue)
                if self.selectedArtistIDs.contains(catID.rawValue) {
                    cell.backgroundColor = UIColor.systemGray.withAlphaComponent(0.5) // Or any other highlight color
                } else {
                    cell.backgroundColor = .clear
                }
                
                return cell
            })
    }
    
    private func updateCVUI(with artists: [MTArtist]) {
        updateData(on: savedArtists)
        updateEmptyState()
    }
    
    private func updateData(on artists: [MTArtist]) {
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
    
    private func updateEmptyState() {
        if savedArtists.isEmpty {
            isEmptyState = true
            DispatchQueue.main.async {
                self.showEmptyStateView(for: .noSavedArtists, in: self.view)
            }
        } else if isEmptyState {
            hideEmptyStateView()
            isEmptyState = false
        }
    }
    
    // MARK: - Methods
    @objc private func libraryButtonTapped() {
        let vcToPresent = LibraryArtistsVC()
        vcToPresent.delegate = self
        vcToPresent.savedArtists = self.savedArtists
        
        let navController = UINavigationController(rootViewController: vcToPresent)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }

    
    @objc private func addButtonTapped() {
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

//    @objc private func unfollowButtonTapped() {
//        // MARK: - CHECK LOGIC BELOW
//        editButtonTapped()
//        
//        // delete isTracked in savedArtists
//        for artist in selectedArtists {
//            guard let index = savedArtists.firstIndex(of: artist) else { return }
//            deleteArtist(index)
//        }
//        
//        selectedArtists.removeAll()
//    }
    
    @objc private func unfollowButtonTapped() {
        // MARK: - CHECK LOGIC BELOW
        editButtonTapped()
        
        // delete isTracked in savedArtists
        for artistID in selectedArtistIDs {
            if let index = savedArtists.firstIndex(where: { $0.catalogID?.rawValue == artistID }) {
                deleteArtist(index)
            }
        }
        
        selectedArtistIDs.removeAll()
//        updateData(on: savedAr)
    }
    
    
    @objc private func cancelButtonTapped() {
        print("CANCEL BUTTON TAPPED")
        selectedArtistIDs.removeAll()
        editButtonTapped()
        
        // Reload the entire section or collectionView
        var snapshot = dataSource.snapshot()
        snapshot.reloadSections([.main])
        dataSource.apply(snapshot, animatingDifferences: true)
        
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
        updateCVUI(with: savedArtists)
      
        MusicDataManager.shared.deleteArtistWithRecords(artistToDelete)
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
//            savedArtists[indexPath.item].isTracked.toggle()
//            
//            let selectedArtist = savedArtists[indexPath.item]
//            selectedArtist.isTracked ?
//            selectedArtists.append(selectedArtist) :
//            selectedArtists.removeAll(where: { $0.name == selectedArtist.name })
//            
//            // Immediately update the selected cell's appearance
//            if let cell = collectionView.cellForItem(at: indexPath) as? ArtistCVCell {
//                if selectedArtist.isTracked {
//                    cell.backgroundColor = UIColor.systemGray.withAlphaComponent(0.5)
//                } else {
//                    cell.backgroundColor = .clear
//                }
//                cell.layer.cornerRadius = 5
//            }
//            
//            updateData(on: savedArtists)
//            updateNavBar()
            let selectedArtist = savedArtists[indexPath.item]
            guard let catID = selectedArtist.catalogID else { return }
            if selectedArtistIDs.contains(catID.rawValue) {
                selectedArtistIDs.remove(catID.rawValue)
            } else {
                selectedArtistIDs.insert(catID.rawValue)
            }
            
            // Update navigation bar
            navigationItem.rightBarButtonItem?.isEnabled = !selectedArtistIDs.isEmpty

            // Create and apply a new snapshot to reflect the changes
            var snapshot = dataSource.snapshot()
            snapshot.reloadItems([selectedArtist])
            dataSource.apply(snapshot, animatingDifferences: true)
        } else {
            //        let currentArtists = isSearching ? filteredArtists : savedArtists
            //        let selectedArtist = currentArtists[indexPath.item]
            //        Logger.shared.debug(selectedArtist.name)
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
        updateCVUI(with: savedArtists)
        MusicDataManager.shared.saveNewArtists(newArtists)
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
        updateCVUI(with: savedArtists)
        
        MusicDataManager.shared.saveNewArtists([newArtist])
    }
}
