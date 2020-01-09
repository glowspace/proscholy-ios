//
//  SongBookListController.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 24/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class SongBooksListVC: SearchViewVC {
    
    private let dataSource = SongBookDataSource()
    
    private lazy var songBooksCollection: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        
        collectionView.register(SongBookCell.self, forCellWithReuseIdentifier: "songBookCell")
        
        if #available(iOS 13, *) {
            collectionView.backgroundColor = .systemBackground
        }
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.showAll {
            self.songBooksCollection.reloadData()
        }
        
        setViews()
    }
    
    private func setViews() {
        setPlaceholder("Zadejte název či zkratku")
        
        view.addSubview(songBooksCollection)
        
        songBooksCollection.topAnchor.constraint(equalToSystemSpacingBelow: searchView.bottomAnchor, multiplier: 1).isActive = true
        songBooksCollection.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        songBooksCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        songBooksCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

extension SongBooksListVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private var spacing: CGFloat { return 15 }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchView.searchField.resignFirstResponder()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 2 - 3 * spacing / 2
        
        return CGSize(width: width, height: 3 * width / 4 + 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let songBookViewVC = SongBookViewVC()
        
        songBookViewVC.songBook = dataSource.songBook(at: indexPath.row)
        
        navigationController?.pushViewController(songBookViewVC, animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension SongBooksListVC {
    
    @objc override func toggleSearch() {
        super.toggleSearch()
        
        if !isSearching {
            dataSource.showAll {
                self.songBooksCollection.reloadData()
            }
        }
    }
    
    @objc override func searchTextChanged(sender: UITextField) {
        super.searchTextChanged(sender: sender)
        
        dataSource.search(sender.text) {
            self.songBooksCollection.reloadData()
            
            if self.songBooksCollection.visibleCells.count > 0 {
                self.songBooksCollection.showsVerticalScrollIndicator = false
                self.songBooksCollection.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                self.songBooksCollection.showsVerticalScrollIndicator = true
            }
        }
    }
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        super.textFieldDidBeginEditing(textField)
        
        if dataSource.searchText.count == 0 {
            dataSource.search(nil) {
                self.songBooksCollection.reloadData()
                
                if self.songBooksCollection.visibleCells.count > 0 {
                    self.songBooksCollection.showsVerticalScrollIndicator = false
                    self.songBooksCollection.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                    self.songBooksCollection.showsVerticalScrollIndicator = true
                }
            }
        }
    }
}
