//
//  ArtistsListVC.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/18/23.
//

import UIKit

class ArtistsListVC: UIViewController {
    
    // MARK: - Variables
//    private var artists: [LibraryArtist] = LibraryArtist.getMockArray()
    private var artists: [LibraryArtist] = []

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
        print(artists)
        if !artists.isEmpty {
            Task {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.view.bringSubviewToFront(self.tableView)
                }
            }
        }
    }
    
    @objc func libraryButtonTapped() {
        // fetch library artists
        let myArtists = getLibraryArtists()
        // pop up modal with tableView
//        let vcToPresent = LibraryArtistsVC()
//        vcToPresent.modalPresentationStyle = .popover
//        
//        vcToPresent.libraryArtists = myArtists
//        print("BEFORE PRESENT")
//        present(vcToPresent, animated: true)
        
        // show library artists
    }
    
    func getLibraryArtists() -> [LibraryArtist] {
        Task {
            do {
                let allArtists = try await fetchLibraryArtists()
                let vcToPresent = LibraryArtistsVC()
                vcToPresent.modalPresentationStyle = .popover
                
                vcToPresent.libraryArtists = allArtists
                print("BEFORE PRESENT")
                present(vcToPresent, animated: true)
                print("GOT THE LIBRARY ARTISTS")
            } catch {
                print("ERROR!!!!!!!!!!!")
                return
            }
        }
        print("RETURNING LIBRARY ARTISTS")
        return allArtists
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
                let newArtist = try await fetchNewArtist(artistName)
                artists.append(newArtist)
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadData()
                }
            } catch {
                print("ERROR!!!!!!!!!!!")
            }
        }
    }
}


extension ArtistsListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ArtistCell.identifier, for: indexPath) as? ArtistCell else { fatalError("Unable to dequeue ArtistCell in ViewController") }
        
        let artist = artists[indexPath.row]
        cell.configure(with: artist)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84.0
    }
}
