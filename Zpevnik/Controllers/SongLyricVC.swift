//
//  SongLyricVC.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 25/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit
import Firebase

class SongLyricVC: ViewController {
    
    private var currentRotation = UIDeviceOrientation.portrait
    private var isAutoScrolling = false
    
    private let optionsDataSource = OptionsDataSource(.songLyric)
    var dataSource: SongLyricDataSource!
    
    private var songLyric: SongLyric! {
        didSet {
            verses = SongLyricsParser.parseVerses(songLyric.lyrics)
            songLyricView.updateSongLyric(songLyric, verses)
            starButton.image = songLyric.isFavorite() ? .starFilled : .star
            
            bottomSlidingView.shouldUpdateButtonsState()
        
            setNavigationBar()
            
            Analytics.setScreenName(songLyric.name, screenClass: nil)
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: "id-\(songLyric.id!)",
                AnalyticsParameterItemName: songLyric.name!,
                AnalyticsParameterContentType: "cont"
            ])
        }
    }
    private var verses: [Verse]?
    
    var songLyricViewBottomConstraint: NSLayoutConstraint?
    var optionsTableTopConstraint: NSLayoutConstraint?
    var optionsTableHeightConstraint: NSLayoutConstraint?
    var slideViewWidthConstraint: NSLayoutConstraint?
    var slideViewBottomConstraint: NSLayoutConstraint?
    
    private let optionsTableWidth: CGFloat = 200
    private var optionsTableHeight: CGFloat = 255
    
    private lazy var translateButton: UIBarButtonItem = { createBarButtonItem(image: .translate, selector: #selector(showTranslations)) }()
    private lazy var starButton: UIBarButtonItem = { createBarButtonItem(image: songLyric.isFavorite() ? .starFilled : .star, selector: #selector(toggleFavorite)) }()
    private lazy var moreButton: UIBarButtonItem = { createBarButtonItem(image: .more, selector: #selector(toggleMoreOptions)) }()
    
    private lazy var optionsTable: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.dataSource = optionsDataSource
        tableView.delegate = self
        
        tableView.isHidden = true
        
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        
        tableView.register(MoreOptionsCell.self, forCellReuseIdentifier: "moreOptionsCell")
        
        tableView.layer.borderColor = UIColor.gray4.cgColor
        tableView.layer.borderWidth = 1
        
        return tableView
    }()
    
    private lazy var songLyricView: SongLyricView = {
        let songLyricView = SongLyricView()
        songLyricView.translatesAutoresizingMaskIntoConstraints = false
        
        songLyricView.scrollView.delegate = self
        
        return songLyricView
    }()
    
    private lazy var bottomSlidingView: SlidingView = {
        let slidingView = SlidingView()
        slidingView.translatesAutoresizingMaskIntoConstraints = false
        
        slidingView.delegate = self
        
        return slidingView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViews()
        
        setGestureRecognizers()
        
        songLyric = dataSource.currentSongLyric
    
        setNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        songLyricView.fontSizeChanged(verses)
        
        bottomSlidingView.isHidden = !UserSettings.showBottomOptions
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        isAutoScrolling = false
        optionsTableTopConstraint?.constant = -optionsTableHeight
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let rotation = UIDevice.current.orientation
        
        if currentRotation.isLandscape != rotation.isLandscape {
            currentRotation = rotation
            
            let hidden = navigationController?.navigationBar.isHidden ?? false
            
            if hidden {
                tabBarController?.setTabBarHidden(true, animated: false)
            }
        }
    }
    
    private func setViews() {
        view.addSubview(songLyricView)
        view.addSubview(optionsTable)
        view.addSubview(bottomSlidingView)
        
        songLyricView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        songLyricViewBottomConstraint = songLyricView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        songLyricViewBottomConstraint?.isActive = true
        
        songLyricView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        songLyricView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        // constant 1 to hide right border
        optionsTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 1).isActive = true
        optionsTable.widthAnchor.constraint(equalToConstant: optionsTableWidth).isActive = true
        optionsTable.heightAnchor.constraint(equalToConstant: optionsTableHeight).isActive = true
        optionsTableTopConstraint = optionsTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -optionsTableHeight)
        optionsTableTopConstraint?.isActive = true
        
        // constant 1 to hide right border
        bottomSlidingView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 1).isActive = true
        slideViewBottomConstraint = bottomSlidingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        slideViewBottomConstraint?.isActive = true
        
        bottomSlidingView.heightAnchor.constraint(equalToConstant: bottomSlidingView.height).isActive = true
        slideViewWidthConstraint = bottomSlidingView.widthAnchor.constraint(equalToConstant: bottomSlidingView.collapsedWidth)
        slideViewWidthConstraint?.isActive = true
    }
    
    private func setNavigationBar() {
        navigationItem.title = songLyric.id
        
        // add spacer to force left aligned title
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacer.width = view.frame.width
        
        let items = songLyric.hasTranslations() ? [moreButton, starButton, translateButton, spacer] : [moreButton, starButton, spacer]
        
        navigationItem.setRightBarButtonItems(items, animated: false)
    }
    
    private func setGestureRecognizers() {
        for direction in [UISwipeGestureRecognizer.Direction.left, .right] {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(changeSongLyric(gestureRecognizer:)))
            swipe.delegate = self
            swipe.direction = direction
            view.addGestureRecognizer(swipe)
        }
        
        view.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(changeFontSize(gestureRecognizer:))))
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        
//        view.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(testAllSongs)))
    }
    
    private func createBarButtonItem(image: UIImage?, selector: Selector) -> UIBarButtonItem {
        let barButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: selector)
        barButtonItem.tintColor = .icon
        
        return barButtonItem
    }
    
    private func autoScroll(completionHandler: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2)) {
            if self.canScroll() {
                self.isAutoScrolling = false
            } else {
                self.songLyricView.scrollView.contentOffset.y += 0.5
            }
            
            if self.isAutoScrolling {
                self.autoScroll(completionHandler: completionHandler)
            } else {
                completionHandler(self.isAutoScrolling)
            }
        }
    }
}

// MARK: - Action handlers

extension SongLyricVC {
    
    @objc func showTranslations() {
        let translationsViewVC = TranslationsViewVC()
        
        translationsViewVC.delegate = self
        translationsViewVC.songLyric = songLyric
        
        navigationController?.pushViewController(translationsViewVC, animated: true)
    }
    
    @objc func toggleFavorite() {
        starButton.image = dataSource.toggleFavorite() ? .starFilled : .star
    }
    
    @objc func toggleMoreOptions() {
        if optionsTableTopConstraint?.constant == -optionsTableHeight {
            self.optionsTable.isHidden = false
            // - 1 to hide top border
            optionsTableTopConstraint?.constant = -1
        } else {
            optionsTableTopConstraint?.constant = -optionsTableHeight
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            if self.optionsTableTopConstraint?.constant == -self.optionsTableHeight {
                self.optionsTable.isHidden = true
            }
        }
    }
}

// MARK: - TranslationDelegate

extension SongLyricVC: TranslationDelegate {
    
    func songLyricTranslationChanged(_ songLyric: SongLyric) {
        if self.songLyric.id != songLyric.id {
            self.songLyric = songLyric
            dataSource.currentSongLyricIndex = nil
        }
        
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - SlideViewDelegate

extension SongLyricVC: SlideViewDelegate {
    
    func songLyricHasSupportedExternals() -> Bool {
        guard let externals = songLyric.externals?.allObjects as? [External] else { return false }
        
        for external in externals {
            if let typeString = external.typeString, SupportedExternals(rawValue: typeString) != nil {
                return true
            }
        }
        
        return false
    }
    
    func canScroll() -> Bool {
        let scrollView = songLyricView.scrollView
        scrollView.layoutIfNeeded()
        
        return scrollView.contentSize.height - scrollView.contentOffset.y + scrollView.contentInset.bottom <= scrollView.frame.height
    }
    
    func showTuneOptions() {
        
    }
    
    func showExternals() {
        isAutoScrolling = false
        
        halfViewPresentationManager.heightMultiplier = 1.0 / 2.0
        
        let externalsViewVC = ExternalsViewVC()
        externalsViewVC.songLyric = songLyric
        
        presentModally(externalsViewVC, animated: true)
    }
    
    func toggleSlideView(animations: @escaping () -> Void, completionHandler: @escaping () -> Void) {
        if bottomSlidingView.collapsed {
            slideViewWidthConstraint?.constant = bottomSlidingView.width
        } else {
            slideViewWidthConstraint?.constant = bottomSlidingView.collapsedWidth
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            animations()
            self.view.layoutIfNeeded()
        }) { _ in
            completionHandler()
        }
    }
    
    func toggleAutoScroll(completionHandler: @escaping (Bool) -> Void) {
        isAutoScrolling = !isAutoScrolling
        
        completionHandler(isAutoScrolling)
        
        if isAutoScrolling {
            autoScroll(completionHandler: completionHandler)
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension SongLyricVC: UITableViewDelegate {
    
//    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//        return indexPath
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch indexPath.row {
        case 0:
            addToPlaylist()
        case 2:
            showMusicNotes()
        case 3:
            shareSong()
        case 4:
            openOnWeb()
        case 5:
            reportSongLyric()
        default:
            break
        }
    }
    
    private func addToPlaylist() {
        halfViewPresentationManager.heightMultiplier = 1.0 / 2.0
        
        let addToPLaylistVC = AddToPlaylistVC()
        addToPLaylistVC.songLyrics = [songLyric]
        
        presentModally(addToPLaylistVC, animated: true)
        toggleMoreOptions()
    }
    
    private func showMusicNotes() {
        let musicNotesVC = MusicNotesVC()
        musicNotesVC.songLyric = songLyric
        
        navigationController?.pushViewController(musicNotesVC, animated: true)
    }
    
    private func shareSong() {
        toggleMoreOptions()
        
        let textToShare = ["https://zpevnik.proscholy.cz/pisen/\(songLyric.id!)"]

        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if activityViewController.responds(to: #selector(getter: UIViewController.popoverPresentationController)) {
                activityViewController.popoverPresentationController?.sourceView = optionsTable
            }
        }
        
        self.present(activityViewController, animated: true)
    }
    
    private func openOnWeb() {
        guard let url = URL(string: "https://zpevnik.proscholy.cz/pisen/\(songLyric.id!)") else { return }
        
        UIApplication.shared.open(url) { _ in
            self.toggleMoreOptions()
        }
    }
    
    private func reportSongLyric() {
        guard let encodedUrl = ("https://docs.google.com/forms/d/e/1FAIpQLSdTaOCzzlfZmyoCB0I_S2kSPiSZVGwDhDovyxkWB7w2LfH0IA/viewform?entry.2038741493=\(songLyric.name!)").addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let url = URL(string: encodedUrl) else { return }
        
        UIApplication.shared.open(url) { _ in
            self.toggleMoreOptions()
        }
    }
}

// MARK: - UIScrollViewDelegate

extension SongLyricVC: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if(optionsTableTopConstraint?.constant == -1) {
            toggleMoreOptions()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        bottomSlidingView.shouldUpdateButtonsState()
    }
}

// MARK: - Gesture handlers

extension SongLyricVC {
    
    @objc func testAllSongs() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(20), execute: {
            if UserSettings.fontSize == Constants.maxFontSize {
                self.dataSource.nextSongLyric()
                self.songLyric = self.dataSource.currentSongLyric
                UserSettings.fontSize = Constants.minFontSize
            } else {
                UserSettings.fontSize += 1
                self.songLyricView.fontSizeChanged(self.verses)
            }
            self.testAllSongs()
        })
    }
    
    @objc func changeSongLyric(gestureRecognizer: UISwipeGestureRecognizer) {
        if(optionsTableTopConstraint?.constant == -1) {
            toggleMoreOptions()
        }
        
        if gestureRecognizer.direction == .left {
            dataSource.nextSongLyric()
        } else if gestureRecognizer.direction == .right {
            dataSource.previousSongLyric()
        }
        
        if let songLyric = dataSource.currentSongLyric {
            self.songLyric = songLyric
        }
    }
    
    @objc func changeFontSize(gestureRecognizer: UIPinchGestureRecognizer) {
        if (gestureRecognizer.state == .began || gestureRecognizer.state == .changed) {
            UserSettings.fontSize *= gestureRecognizer.scale
            songLyricView.fontSizeChanged(verses)
            gestureRecognizer.scale = 1.0
        }
    }
    
    @objc func didTap() {
        if(optionsTableTopConstraint?.constant == -1) {
            toggleMoreOptions()
        } else {
            toggleFullScreen()
        }
    }
    
    private func toggleFullScreen() {
        let hidden = navigationController?.navigationBar.isHidden ?? false
        
        navigationController?.setNavigationBarHidden(!hidden, animated: true)
        tabBarController?.setTabBarHidden(!hidden, animated: true)
        
        if !hidden {
            songLyricViewBottomConstraint?.constant += tabBarController?.tabBar.frame.height ?? 0
            slideViewBottomConstraint?.constant += tabBarController?.tabBar.frame.height ?? 0
        } else {
            songLyricViewBottomConstraint?.constant = 0
            slideViewBottomConstraint?.constant = -16
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

extension SongLyricVC: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view, view.isDescendant(of: optionsTable) || view.isDescendant(of: bottomSlidingView) {
            return false
        }

        return true
    }
}
