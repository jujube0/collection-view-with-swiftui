//
//  ViewController.swift
//  collection-view-with-swiftui
//
//  Created by 김가영 on 2023/01/22.
//

import UIKit
import SwiftUI

class ViewController: UIViewController {
    private var items: [BlockDataModel] = []
    
    private var dataSource: DataSource!
    private var collectionView: UICollectionView!
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Int>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Int>

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        dataSource = createDataSource(with: collectionView)
        collectionView.dataSource = dataSource
        
        apply()
    }
    
    private func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            let leadingItem = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(0.7), heightDimension: .fractionalHeight(1.0)))
            let trailingItem = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5)))
            let trailingGroup = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(0.3), heightDimension: .fractionalHeight(1.0)), repeatingSubitem: trailingItem, count: 2)
            let topGroup = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.7)), subitems: [leadingItem, trailingGroup])
            let bottomItem = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.3)))
            
            let nestedGroup = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.5)), subitems: [topGroup, bottomItem])
            return NSCollectionLayoutSection(group: nestedGroup)
        }
    }
    
    private func apply() {
        items = [
            BlockDataModel(title: "2,764원", description: "카카오페이머니"),
            BlockDataModel(title: "선택하기", description: "송금"),
            BlockDataModel(title: "신한카드", description: "결제"),
            BlockDataModel(title: "Spotify AB", description: "11,990원")
        ]
        
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(Array(0..<items.count), toSection: 0)
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
    
    private func createDataSource(with collectionView: UICollectionView) -> DataSource {
        DataSource(collectionView: collectionView) { [unowned self] collectionView, indexPath, itemIndex in
            guard itemIndex >= 0 && itemIndex < items.count else { fatalError() }
            let item = items[itemIndex]
            return collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
        }
    }
    
    var registration: UICollectionView.CellRegistration<UICollectionViewCell, BlockDataModel> = .init { cell, indexPath, item in
        cell.contentConfiguration = UIHostingConfiguration {
            BlockView(title: item.title, description: item.description)
        }
        .margins(.all, 3.0)
    }
}

struct BlockDataModel: Hashable {
    var title: String
    var description: String?
}
