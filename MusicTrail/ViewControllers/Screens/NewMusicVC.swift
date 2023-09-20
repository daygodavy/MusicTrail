//
//  NewMusicVC.swift
//  MusicTrail
//
//  Created by Davy Chuon on 7/18/23.
//

import UIKit

struct MonthSection: Hashable {
    let monthYear: String
}

class NewMusicVC: UIViewController {
    
    enum MTRecordSection: Hashable {
        case month(MonthSection)
    }
    
    // MARK: - Variables
    private var trackedRecords: [MonthSection: [MTRecord]] = [:]
    
    // MARK: - UI Components
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<MTRecordSection, MTRecord>!
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
        collectionView.register(MonthSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MonthSectionHeaderView.reuseID)
    }
    
    private func setupDataSource() {
        
        dataSource = UICollectionViewDiffableDataSource<MTRecordSection, MTRecord>(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, record) -> UICollectionViewCell? in
                
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecordCVCell.reuseID, for: indexPath) as! RecordCVCell
            
            cell.set(with: record)
            
            return cell
        })
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionHeader {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MonthSectionHeaderView.reuseID, for: indexPath) as! MonthSectionHeaderView
                let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
                
                switch section {
                case .month(let monthSection):
                    header.set(with: monthSection, firstSection: indexPath.section != 0)
                }
                
                return header
            }
            return nil
        }
    }
    
    // MARK: - Methods
    
    
    private func updateCVUI(with records: [MonthSection : [MTRecord]]) {
        
        if !trackedRecords.isEmpty {
            updateData(on: trackedRecords)
        } else {
            // TODO: - empty state
            // Hide search bar
            // Disable vertical scroll bounce for collection view
        }
    }
    
    private func updateData(on records: [MonthSection : [MTRecord]]) {
        
        var snapshot = NSDiffableDataSourceSnapshot<MTRecordSection, MTRecord>()
        
        // Convert monthYear strings to Date objects and compare to sort
        let sortedSections = records.keys.sorted {
            DateUtil.compareMonthYear(
            s1: $0.monthYear,
            s2: $1.monthYear) == .orderedDescending }
        
        for monthSection in sortedSections {
            if let recordsForMonth = records[monthSection] {
                var sortedRecords = recordsForMonth
                sortedRecords.sort { $0.releaseDate > $1.releaseDate }
                snapshot.appendSections([.month(monthSection)])
                snapshot.appendItems(sortedRecords, toSection: .month(monthSection))
            }
        }
        
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
