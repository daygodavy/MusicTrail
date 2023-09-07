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
    private let musicArtistRepo: MusicArtistRepo = MusicArtistRepo()
    private var isEditMode: Bool = false
    private var isSearching: Bool = false

    // MARK: - UI Components
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, MTArtist>!
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getSavedArtists()
        setupSearchController()
        setupCollectionView()
        setupDataSource()
        setupNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func getSavedArtists() {
        savedArtists = musicArtistRepo.fetchSavedArtists()
        updateCVUI(with: savedArtists)
        
        print("FETCHED SAVED ARTISTS:")
        savedArtists.forEach { print($0.isTracked) }
    }
    
    
    // MARK: - Setup UI
    private func setupNavBar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        
        let libraryButton = UIBarButtonItem(image: UIImage(systemName: "music.note.list"), style: .plain, target: self, action: #selector(libraryButtonTapped))
        
        navigationItem.rightBarButtonItems = [addButton, libraryButton]
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped))
    }
    
    @objc private func editButtonTapped() {
//        toggleEditMode()
    }
    
    private func setupSearchController() {
        let searchController = UISearchController()
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
        collectionView.register(ArtistCVCell.self, forCellWithReuseIdentifier: ArtistCVCell.reuseID)
    }
    
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, MTArtist>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, artist) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArtistCVCell.reuseID, for: indexPath) as! ArtistCVCell
            
            cell.set(artist: artist)
            
            cell.backgroundColor = UIColor.systemGray.withAlphaComponent(0.5)
            cell.layer.cornerRadius = 5
            
            return cell
        })
    }
    
    func updateCVUI(with artists: [MTArtist]) {
        
        if !savedArtists.isEmpty {
            updateData(on: savedArtists)
        } else {
            // TODO: - empty state
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
    
    
    func deleteArtist(_ index: IndexPath) {
        let artistToDelete = savedArtists.remove(at: index.item)
        updateData(on: savedArtists)
        musicArtistRepo.unsaveArtist(artistToDelete)
    }
    

}


// MARK: - UICollectionView protocols
extension SavedArtistsVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentArtists = isSearching ? filteredArtists : savedArtists
        let selectedArtist = currentArtists[indexPath.item]
        print(selectedArtist.name)
        
//        let selectedCell = collectionView.cellForItem(at: indexPath) as! ArtistCVCell
//        
//        if selectedCell.isSelected {
//            // Deselect the cell
//            collectionView.deselectItem(at: indexPath, animated: true)
//            selectedCell.isSelected = false
//        } else {
//            // Select the cell
//            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
//            selectedCell.isSelected = true
//        }
        
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
        updateCVUI(with: savedArtists)
//        updateUI()
        
        print("NEW ARTISTS:")
        newArtists.forEach { print($0.isTracked) }
        print("ALL ARTISTS:")
        savedArtists.forEach { print($0.isTracked) }
    }
}
