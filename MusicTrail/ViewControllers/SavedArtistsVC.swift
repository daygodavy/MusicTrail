//
//  SavedArtistsVC.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/18/23.
//

import UIKit

class SavedArtistsVC: UIViewController {
    
    // MARK: - Variables
    private var savedArtists: [MTArtist] = []
    private let musicArtistRepo: MusicArtistRepo = MusicArtistRepo()

    // MARK: - UI Components
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .systemBackground
        tv.register(ArtistCell.self, forCellReuseIdentifier: ArtistCell.identifier)
        return tv
    }()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPink
        
        savedArtists = musicArtistRepo.fetchSavedArtists()
        setupUI()
        setupNavBar()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    
    // MARK: - Setup UI
    func setupUI() {
        view.backgroundColor = .systemBlue
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
        ])
    }
    
    
    func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(libraryButtonTapped))
    }
    
    
    func updateUI() {
        if !savedArtists.isEmpty {
            Task {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.view.bringSubviewToFront(self.tableView)
                }
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
                savedArtists.append(newArtist)
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadData()
                }
            } catch {
                print("ERROR!")
            }
        }
    }
    
    
    func deleteArtist(_ index: IndexPath) {
        let artistToDelete = savedArtists.remove(at: index.row)
        self.tableView.deleteRows(at: [index], with: .fade)
        musicArtistRepo.unsaveArtist(artistToDelete)
    }
}


// MARK: - UITableView protocols
extension SavedArtistsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedArtists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ArtistCell.identifier, for: indexPath) as? ArtistCell else { fatalError("Unable to dequeue ArtistCell in ViewController") }
        
        let artist = savedArtists[indexPath.row]
        cell.configure(with: artist)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84.0
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            
            self.deleteArtist(indexPath)
            completionHandler(true)
        }
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        return config
    }
}


// MARK: - LibraryArtistVC protocols
extension SavedArtistsVC: LibraryArtistVCDelegate {
    func importSavedArtists(_ newArtists: [MTArtist]) {
        savedArtists.append(contentsOf: newArtists)
        musicArtistRepo.saveLibraryArtists(newArtists)
        updateUI()
    }
}
