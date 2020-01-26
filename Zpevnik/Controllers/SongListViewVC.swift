//
//  SongListViewVC.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 09/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit

class SongListViewVC: SearchViewVC {
    
    internal var dataSource: SongLyricDataSource!
    
    internal lazy var filterTagDataSource: FilterTagDataSource = {
        let filterTagDataSource = FilterTagDataSource()
        filterTagDataSource.delegate = self
        
        return filterTagDataSource
    }()
    
    internal lazy var songList: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.dataSource = dataSource
        tableView.delegate = self
        
        tableView.register(SongLyricCell.self, forCellReuseIdentifier: "songLyricCell")
        
        tableView.separatorStyle = .none
        
        if #available(iOS 13, *) {
            tableView.backgroundColor = .systemBackground
        }
        
        return tableView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        songList.reloadData()
        dataSource.currentSongLyricIndex = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let index = songList.indexPathForSelectedRow {
            songList.deselectRow(at: index, animated: animated)
        }
    }
}

// MARK: - UITableViewDelegate

extension SongListViewVC: UITableViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchView.searchField.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if dataSource.searchText.count > 0 && filterTagDataSource.activeFilters.count == 0 {
            return .leastNormalMagnitude
        }
        
        return tableView.sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if filterTagDataSource.activeFilters.count > 0 {
            return ActiveFilterHeaderView(dataSource: self, delegate: self)
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let songLyric = dataSource.songLyric(at: indexPath.row)
        let songLyricVC = SongLyricVC()
    
        // TODO: MOVE
        if isSearching {
            let defaults = UserDefaults.standard
            
            var lastSearched = defaults.array(forKey: "lastSearchedHome") as? [String] ?? []
            
            if let index = lastSearched.firstIndex(of: songLyric.id!) {
                lastSearched.remove(at: index)
            }
            
            lastSearched.append(songLyric.id!)
            
            defaults.set(lastSearched, forKey: "lastSearchedHome")
            
            if dataSource.searchText.count == 0 {
                dataSource.search(nil) {
                    self.songList.reloadData()
                }
            }
        }
        
        dataSource.currentSongLyricIndex = indexPath.row
        songLyricVC.dataSource = dataSource
        
        navigationController?.pushViewController(songLyricVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) { }
}

extension SongListViewVC {
    
    @objc override func toggleSearch() {
        super.toggleSearch()
        
        if !isSearching {
            dataSource.showAll {
                self.songList.reloadData()
                self.songList.scrollToTop()
            }
        }
    }
    
    @objc override func searchTextChanged(sender: UITextField) {
        super.searchTextChanged(sender: sender)
        
        searchView.trailingButton?.isEnabled = (sender.text?.count ?? 0) > 0
        
        dataSource.search(sender.text) {
            self.songList.reloadData()
            self.songList.scrollToTop()
        }
    }
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        super.textFieldDidBeginEditing(textField)
        
        if dataSource.searchText.count == 0 {
            dataSource.search(nil) {
                self.songList.reloadData()
                self.songList.scrollToTop()
            }
        }
    }
}

// MARK: Filters

extension SongListViewVC: FilterDelegate {
    
    @objc func showFilters() {
        halfViewPresentationManager.heightMultiplier = 1.0 / 2.0
        
        let filterViewVC = FilterViewVC()
        filterViewVC.dataSource = filterTagDataSource
        
        presentModally(filterViewVC, animated: true)
    }
    
    func activeFiltersChanged() {
        dataSource.filter {
            self.songList.scrollToTop()
            self.songList.reloadData()
        }
    }
}

extension SongListViewVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func removeFilter(_ filterName: String?) {
        guard let filterName = filterName else { return }
        
        filterTagDataSource.deactivateFilter(named: filterName)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterTagDataSource.activeFilters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "clearableFilterTagCell", for: indexPath) as? ClearAbleFilterTagCell else { return UICollectionViewCell() }
        
        cell.title = filterTagDataSource.activeFilters[indexPath.row]
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return ClearAbleFilterTagCell.sizeFor(filterTagDataSource.activeFilters[indexPath.row])
    }
}
