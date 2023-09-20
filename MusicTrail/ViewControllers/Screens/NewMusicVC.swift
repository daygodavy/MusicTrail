//
//  NewMusicVC.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/18/23.
//

import UIKit

class NewMusicVC: UIViewController {
    
    enum Section { case main }
    
    // MARK: - Variables
    private var trackedRecords: [MTRecord] = []
    
    // MARK: - UI Components
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, MTRecord>!
    private var searchController = UISearchController()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        getNewMusicReleases()
//        setupSearchController()
        setupCollectionView()
        setupDataSource()
//        setupDefaultNavBar()
    }
    
    private func getNewMusicReleases() {
        Task {
            trackedRecords = await MusicKitManager.shared.fetchNewMusic()
            updateCVUI(with: trackedRecords)
        }
    }
    
    // MARK: - UI Setup
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UIHelper.createColumnFlowLayout(in: view, numCols: 2))
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(RecordCVCell.self, forCellWithReuseIdentifier: RecordCVCell.reuseID)
    }
    
    private func setupDataSource() {
        
        dataSource = UICollectionViewDiffableDataSource<Section, MTRecord>(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, record) -> UICollectionViewCell? in
                
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecordCVCell.reuseID, for: indexPath) as! RecordCVCell
            
            cell.set(with: record)
            
            return cell
        })
    }
    
    // MARK: - Methods
    
    
    private func updateCVUI(with records: [MTRecord]) {
        
        if !trackedRecords.isEmpty {
            updateData(on: trackedRecords)
        } else {
            // TODO: - empty state
            // Hide search bar
            // Disable vertical scroll bounce for collection view
        }
    }
    
    private func updateData(on records: [MTRecord]) {
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, MTRecord>()
        snapshot.appendSections([.main])
        snapshot.appendItems(records)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
}

// MARK: - UICollectionView protocols
extension NewMusicVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // TODO: - Implement cell selection
    }
}
