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
    
    enum Section { case main }
    
    // MARK: - Variables
    var libraryArtists: [MTArtist] = []
    var filteredArtists: [MTArtist] = []
    var selectedArtists: [MTArtist] = []
    var savedArtists: [MTArtist] = []
    var isSearching: Bool = false
    
    weak var delegate: LibraryArtistVCDelegate?
    
    private var dataSource: UITableViewDiffableDataSource<Section, MTArtist>!
    
    // MARK: - UI Components
    let mtTableView = MTArtistImportTableView()
    
    lazy var checkMenu: UIMenu = {
        let selectImage = UIImage(systemName: "checklist.checked")
        let deselectImage = UIImage(systemName: "checklist.unchecked")
        let selectItem = UIAction(title: "Select All", image: selectImage) { _ in
            self.selectButtonTapped()
        }

        let deselectItem = UIAction(title: "Deselect All", image: deselectImage) { _ in
            self.deselectButtonTapped()
        }
        let menu = UIMenu(title: "Options", children: [selectItem, deselectItem])
        
        return menu
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getLibraryArtists()
        configureNavBar()
        configureTableView()
        configureImportButton()
        configureSearchBar()
        showLoadingView()
    }
    
    
    // MARK: - UI Setup
    private func configureNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        
        let dropDownImage = UIImage(systemName: "chevron.down.circle")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: dropDownImage, menu: checkMenu)
    }

    
    private func configureTableView() {
        view.backgroundColor = .secondarySystemBackground
        view.addSubview(mtTableView)
        mtTableView.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            mtTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mtTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mtTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mtTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        mtTableView.tableView.backgroundColor = .systemBackground
        mtTableView.tableView.rowHeight = 64
        mtTableView.tableView.delegate = self
//        mtTableView.tableView.dataSource = self
        mtTableView.tableView.register(ArtistTVCell.self, forCellReuseIdentifier: ArtistTVCell.identifier)
        
        dataSource = UITableViewDiffableDataSource<Section, MTArtist>(tableView: mtTableView.tableView) { (tableView, indexPath, artist) -> UITableViewCell? in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ArtistTVCell.identifier, for: indexPath) as? ArtistTVCell else { fatalError("Unable to dequeue ArtistCell in ViewController") }
            
            print("\(artist.name) @ \(indexPath.row) == \(artist.isTracked)")
            cell.configure(with: artist, state: .library)
            return cell
        }
    }
    
    private func configureImportButton() {
        mtTableView.importButton.setTitle("Import", for: .normal)
        mtTableView.importButton.isHidden = true
        
        mtTableView.importButton.backgroundColor = .systemBlue
        mtTableView.importButton.layer.cornerRadius = 25
        mtTableView.importButton.layer.masksToBounds = true
        mtTableView.importButton.setTitleColor(.white, for: .normal)
        mtTableView.importButton.addTarget(self, action: #selector(importButtonTapped), for: .touchUpInside)
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
    
    @objc private func selectButtonTapped() {
        navigationController?.navigationBar.isUserInteractionEnabled = false
        
        toggleSelectAll(true)
        selectedArtists = libraryArtists
        updateImportStatus()
        updateData()
        navigationController?.navigationBar.isUserInteractionEnabled = true
    }
    
    @objc private func deselectButtonTapped() {
        navigationController?.navigationBar.isUserInteractionEnabled = false
        toggleSelectAll(false)
        selectedArtists.removeAll()
        updateImportStatus()
        updateData()
        navigationController?.navigationBar.isUserInteractionEnabled = true
    }
    
    private func toggleSelectAll(_ isSelected: Bool) {
        for i in 0..<libraryArtists.count {
            libraryArtists[i].isTracked = isSelected
            let indexPath = IndexPath(row: i, section: 0)
//            if let cell = mtTableView.tableView.cellForRow(at: indexPath) as? ArtistTVCell {
//
//                cell.updateCheckmark(libraryArtists[indexPath.row].isTracked)
//            }
        }
        filteredArtists = libraryArtists
    }
    
    
    @objc private func importButtonTapped() {
        
        Task.init(priority: .background) {
            do {
                delegate?.importInProgress()
                
                backButtonTapped()
                
                selectedArtists = try await MusicKitManager.shared.mapLibraryToCatalog(selectedArtists)
                
                delegate?.importSavedArtists(selectedArtists)

            } catch {
                Logger.shared.debug("ERROR!!!!!!!!!!!")
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
//                configurePostNavBar()
//                testSelectArtists(900)
            } catch {
                if let mtError = error as? MTError {
                    // present MTAlert with error.rawvalue
                    DispatchQueue.main.async {
                        self.dismissLoadingView()
                        self.presentMTAlert(title: "Permission Denied", message: mtError.rawValue, buttonTitle: "Ok")
                        // TODO: - show text over table view to say access denied
                    }
                } else {
                    // present default error
                    DispatchQueue.main.async {
                        self.dismissLoadingView()
                        self.presentDefaultError()
                        // TODO: - show text over table view to say access denied
                    }
                }
            }
        }
    }
    
    
//    private func updateData() {
//        DispatchQueue.main.async { [weak self] in
//            self?.mtTableView.tableView.reloadData()
//        }
//    }
    
    func updateData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MTArtist>()
        snapshot.appendSections([.main])
        snapshot.appendItems(self.filteredArtists)
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }

    
    
    private func updateTrackedArtist(_ indexPath: IndexPath) {
        filteredArtists[indexPath.row].isTracked.toggle()
        if let idxMatch = libraryArtists.firstIndex(where: {$0.name.contains(filteredArtists[indexPath.row].name)}) {
            libraryArtists[idxMatch].isTracked = filteredArtists[indexPath.row].isTracked
        }
        
        if filteredArtists[indexPath.row].isTracked {
            selectedArtists.append(filteredArtists[indexPath.row])
        } else {
            selectedArtists.removeAll(where: {$0.name == filteredArtists[indexPath.row].name})
        }
        
//        if let cell = mtTableView.tableView.cellForRow(at: indexPath) as? ArtistTVCell {
//            cell.updateCheckmark(filteredArtists[indexPath.row].isTracked)
//        }
        updateData()
    }
    
    private func updateImportStatus() {
        if !selectedArtists.isEmpty {
            mtTableView.importButton.setTitle("Import (\(selectedArtists.count))", for: .normal)
            mtTableView.importButton.isHidden = false
            mtTableView.importButton.isEnabled = true
        } else {
            mtTableView.importButton.isHidden = true
            mtTableView.importButton.isEnabled = false
        }
    }
}


// MARK: - UITableView Protocols
extension LibraryArtistsVC: UITableViewDelegate {
//extension LibraryArtistsVC: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return filteredArtists.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: ArtistTVCell.identifier, for: indexPath) as? ArtistTVCell else { fatalError("Unable to dequeue ArtistCell in ViewController") }
//        
//        let artist = filteredArtists[indexPath.row]
//        cell.configure(with: artist, state: .library)
//        
//        return cell
//    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.updateTrackedArtist(indexPath)
            self?.updateImportStatus()
        }

//        DispatchQueue.main.async { [weak self] in
//            self?.mtTableView.tableView.reloadRows(at: [indexPath], with: .automatic)
//        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            tableView.deselectRow(at: indexPath, animated: false)
//        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 140))
        footerView.backgroundColor = .clear
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 140
    }

}


// MARK: - UISearchController Protocols
extension LibraryArtistsVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            filteredArtists = libraryArtists
            updateData()
            isSearching = false
            return
        }
        
        isSearching = true
        let newFilteredArtist  = libraryArtists.filter {
            $0.name.lowercased().contains(filter.lowercased())
        }
        
        if newFilteredArtist != filteredArtists {
            filteredArtists = newFilteredArtist
            updateData()
        }
//        updateData()
    }
    
}

