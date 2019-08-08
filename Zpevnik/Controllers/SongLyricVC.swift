//
//  SongLyricVC.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 25/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class SongLyricVC: ViewController {
    
    var songLyric: SongLyric! {
        didSet {
            middle = nil
            do {
                (lyrics, chords) = try extractChords(songLyric.lyrics)
            } catch { }
        }
    }
    
    var middle: UITextPosition?
    
    lazy var starButton: UIBarButtonItem = {
        let tabBarItem = UIBarButtonItem(image: UIImage(named: "starIcon"), style: .plain, target: self, action: #selector(starSelected))
        
        return tabBarItem
    }()
    
    lazy var moreButton: UIBarButtonItem = {
        let tabBarItem = UIBarButtonItem(image: UIImage(named: "moreIcon"), style: .plain, target: self, action: #selector(toggleMore))
        
        return tabBarItem
    }()
    
    var lyrics: String?
    var chords: [Chord]?
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()
    
    let lyricsTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        textView.isEditable = false
        textView.isSelectable = false
        
        return textView
    }()
    
    let authorsLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.numberOfLines = 0
        label.setInsets()
        
        return label
    }()
    
    lazy var moreOptionsView: UITableView = {
        let tableView = TableView(frame: CGRect(x: view.frame.width - 151, y: -131, width: 151, height: 131))
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "cellId")
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.isScrollEnabled = false
        
        view.addSubview(tableView)
        
        return tableView
    }()
    
    var showingMore = false
    
    var delegate: SongLyricDelegate?
    
    var scrollViewTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViews()
        
        setGestureRecognizers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = Constants.getDarkColor() ?? .white
        scrollView.backgroundColor = Constants.getDarkColor() ?? .white
        
        navigationController?.navigationBar.barTintColor = Constants.getMiddleColor()
        
        updateSongLyrics()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if showingMore {
            moreOptionsView.frame.origin.y -= moreOptionsView.frame.height
            showingMore = false
        }
    }
    
    private func setGestureRecognizers() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(changeSongLyric(gestureRecognizer:)))
        swipeLeft.direction = .left
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(changeSongLyric(gestureRecognizer:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeLeft)
        view.addGestureRecognizer(swipeRight)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleFullDisplay))
        tap.delegate = self
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        view.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(changeFontSize(gestureRecognizer:))))
    }
    
    // MARK: - View settings
    
    private func setViews() {
        view.addSubview(scrollView)
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|", metrics: nil, views: ["scrollView": scrollView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[scrollView]|", metrics: nil, views: ["scrollView": scrollView]))
        
        scrollViewTopConstraint = NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
        view.addConstraint(scrollViewTopConstraint)
        
        setNavigationItem()
        
        scrollView.layoutIfNeeded()
        
        setScrollView()
    }
    
    private func setNavigationItem() {
        let starIcon = songLyric.favoriteOrder > -1 ? "starIconFilled": "starIcon"
        starButton.image = UIImage(named: starIcon)
        navigationItem.setRightBarButtonItems([moreButton, starButton], animated: true)
    }
    
    private func setScrollView() {
        scrollView.addSubview(lyricsTextView)
        scrollView.addSubview(authorsLabel)
        
        let views = [
            "lyricsTextView": lyricsTextView,
            "authorsLabel": authorsLabel
        ]
        
        let metrics = [
            "labelWidth": scrollView.frame.width - 16
        ]
        
        scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[lyricsTextView(labelWidth)]", metrics: metrics, views: views))
        scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-14-[authorsLabel(labelWidth)]", metrics: metrics, views: views))
        scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[lyricsTextView]-10-[authorsLabel]-10-|", metrics: nil, views: views))
    }
    
    func updateSongLyrics() {
        if let layers = lyricsTextView.layer.sublayers {
            for layer in layers {
                if layer is CATextLayer {
                    layer.removeFromSuperlayer()
                }
            }
        }
        lyricsTextView.isScrollEnabled = true
        lyricsTextView.textContainer.exclusionPaths = []
        
        setTitle(songLyric.name)
        
        var text = ""
        if !songLyric.isOriginal {
            if let song = songLyric.song, let original = song.original, let authors = original.authors?.allObjects as? [Author] {
                text += "Originál: " + original.name! + "\n"
                if authors.count == 1 {
                    text += "Autor: " + authors[0].name!
                } else if authors.count > 0 {
                    text += "Autoři: "
                    
                    for (i, author) in authors.enumerated() {
                        text += author.name!
                        if i != authors.count - 1 {
                            text += ", "
                        }
                    }
                }
                text += "\n"
            }
        }
        if let authors = songLyric.authors?.allObjects as? [Author] {
            if authors.count == 1 {
                text += "Autor" + (songLyric.isOriginal ? ": " : " překladu: ") + authors[0].name!
            } else if authors.count > 0 {
                text += "Autoři" + (songLyric.isOriginal ? ": " : " překladu: ")
                
                for (i, author) in authors.enumerated() {
                    text += author.name!
                    if i != authors.count - 1 {
                        text += ", "
                    }
                }
            }
        }
        authorsLabel.font = .getFont(ofSize: CGFloat(UserSettings.fontSize))
        authorsLabel.text = text
        
        lyricsTextView.attributedText = prepareLyrics()
        
        lyricsTextView.translatesAutoresizingMaskIntoConstraints = true
        lyricsTextView.sizeToFit()
        lyricsTextView.translatesAutoresizingMaskIntoConstraints = false
        
        lyricsTextView.isScrollEnabled = false
        
        let starIcon = songLyric.favoriteOrder > -1 ? "starIconFilled": "starIcon"
        starButton.image = UIImage(named: starIcon)
    }
    
    // MARK: - Handlers
    
    @objc func changeSongLyric(gestureRecognizer: UISwipeGestureRecognizer) {
        if gestureRecognizer.direction == .right {
            delegate?.changeSongLyric(self, change: -1)
        } else if gestureRecognizer.direction == .left {
            delegate?.changeSongLyric(self, change: 1)
        }
    }
    
    @objc func toggleFullDisplay() {
        if let hidden = navigationController?.navigationBar.isHidden {
            hideBars(!hidden, animated: true)
            if showingMore {
                toggleMore()
            }
        }
    }
    
    @objc func changeFontSize(gestureRecognizer: UIPinchGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            UserSettings.fontSize *= Float(gestureRecognizer.scale)
            updateSongLyrics()
            gestureRecognizer.scale = 1.0
        }
    }
    
    @objc func starSelected() {
        if songLyric.favoriteOrder > -1 {
            songLyric.favoriteOrder = -1
            starButton.image = UIImage(named: "starIcon")
        } else {
            let defaults = UserDefaults.standard
            let favoriteOrder = defaults.integer(forKey: "favoriteOrder")
            
            songLyric.favoriteOrder = Int16(favoriteOrder)
            
            defaults.set(favoriteOrder + 1, forKey: "favoriteOrder")
            PersistenceService.saveContext()
            starButton.image = UIImage(named: "starIconFilled")
        }
    }
    
    @objc func toggleMore() {
        showingMore = !showingMore
        UIView.animate(withDuration: 0.3) {
            self.moreOptionsView.frame.origin.y += self.moreOptionsView.frame.height * (self.showingMore ? 1 : -1)
        }
    }
    
    // MARK: - Lyrics Preparation
    
    struct Chord {
        var text: String
        let start: String.Index
    }
    
    private func extractChords(_ lyrics: String?) throws -> (String?, [Chord]?) {
        guard let tmpLyrics = lyrics else { return (nil, nil) }
        var lyrics = tmpLyrics.replacingOccurrences(of: "\r", with: "")
        var chords: [Chord] = []
        
        var firstVerseChords: [Chord] = []
        var firstVerseChordsIndex = 0
        
        let regex = try NSRegularExpression(pattern: #"\[([^\]]+)\]"#, options: [])
        let nsrange = NSRange(lyrics.startIndex..<lyrics.endIndex, in: lyrics)
        var removed = 0
        
        regex.enumerateMatches(in: lyrics, options: [], range: nsrange) { (match, _, _) in
            guard let match = match else { return }
            
            let range = match.range(at: 0)
            let start = range.lowerBound - removed
            let length = range.upperBound - range.lowerBound
            
            if let range = Range(NSRange(location: start, length: length), in: lyrics), let chordRange = Range(NSRange(location: start + 1, length: length - 2), in: lyrics) {
                var chord = Chord(text: String(lyrics[chordRange]), start: range.lowerBound)
                
                let chorusVerseBegin = lyrics.range(of: "R:")?.lowerBound ?? lyrics.startIndex
                let firstVerseBegin = lyrics.range(of: "1.")?.lowerBound ?? lyrics.startIndex
                
                let distanceFromChorus = lyrics.distance(from: chorusVerseBegin, to: chord.start)
                let distanceFromFirstVerse = lyrics.distance(from: firstVerseBegin, to: chord.start)
                if chord.text != "%" && (distanceFromChorus < 0 || (distanceFromFirstVerse > 0 && distanceFromChorus >= distanceFromFirstVerse)) {
                    firstVerseChords.append(chord)
                }
                
                if chord.text == "%" {
                    chord.text = firstVerseChords[firstVerseChordsIndex % firstVerseChords.count].text
                    firstVerseChordsIndex += 1
                }
                
                chords.append(chord)
                
                lyrics.removeSubrange(range)
            }
            
            removed += length
        }
        
        return (lyrics, chords)
    }
    
    private func prepareLyrics() -> NSAttributedString {
        //        let (lyrics, chords) = try extractChords(lyrics.replacingOccurrences(of: "\r", with: ""))
        guard let lyrics = lyrics, let chords = chords else { return NSAttributedString() }
        let showChords = UserSettings.showChords
        let fontSize = CGFloat(UserSettings.fontSize)
        let textColor = UserSettings.darkMode ? UIColor.white : UIColor.black
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = (showChords && chords.count > 0) ? fontSize : 0
        lyricsTextView.textContainerInset = UIEdgeInsets(top: (showChords && chords.count > 0) ? fontSize : 0, left: 0, bottom: 10, right: 0)
        lyricsTextView.layoutIfNeeded()
        let attributes: [NSAttributedString.Key: Any] = [.paragraphStyle: style, .font : UIFont.getFont(ofSize: fontSize), .foregroundColor: textColor]
        var chordAttributes = attributes
        chordAttributes[.foregroundColor] = UIColor(red: 0, green: 122, blue: 255)
        let parsedString = NSMutableAttributedString(string: lyrics, attributes: attributes)
        
        lyricsTextView.attributedText = parsedString
        lyricsTextView.layoutManager.ensureLayout(for: lyricsTextView.textContainer)
        
        var previous: CGRect?
        
        if showChords {
            for chord in chords {
                let chordText = NSMutableAttributedString(string: chord.text, attributes: chordAttributes)
                
                let location = lyrics.distance(from: lyrics.startIndex, to: chord.start)
                
                let start = lyricsTextView.position(from: lyricsTextView.beginningOfDocument, offset: location)!
                let end = lyricsTextView.position(from: start, offset: 0)!
                
                let tRange = lyricsTextView.textRange(from: start, to: end)!
                let rect = lyricsTextView.firstRect(for: tRange)
                
                let x = rect.origin.x
                let y = rect.origin.y - 0.75 * chordText.size().height
                
                let minSpacing: CGFloat = 8
                
                var frame = CGRect(origin: CGPoint(x: x, y: y), size: chordText.size())
                if let previous = previous, frame.origin.y == previous.origin.y && frame.origin.x < previous.origin.x + previous.width + minSpacing {
                    let diff = minSpacing - (frame.origin.x - (previous.origin.x + previous.width))
                    frame.origin.x = previous.origin.x + previous.width + minSpacing
                    if location > 0 {
                        if location < lyrics.count {
                            let start = lyricsTextView.position(from: lyricsTextView.beginningOfDocument, offset: location)!
                            let end = lyricsTextView.position(from: start, offset: 1)!
                            
                            let tRange = lyricsTextView.textRange(from: start, to: end)!
                            let rect2 = lyricsTextView.firstRect(for: tRange)
                            if rect.height == rect2.height {
                                parsedString.addAttribute(.kern, value: diff, range: NSRange(location: location - 1, length: 1))
                            }
                        } else {
                            parsedString.addAttribute(.kern, value: diff, range: NSRange(location: location - 1, length: 1))
                        }
                    }
                    lyricsTextView.attributedText = parsedString
                    lyricsTextView.layoutManager.ensureLayout(for: lyricsTextView.textContainer)
                }
                
                previous = frame
            }
            
            previous = nil
            
            for chord in chords {
                let chordText = NSMutableAttributedString(string: chord.text, attributes: chordAttributes)
                
                let layer = CATextLayer()
                layer.string = chordText
                
                let location = lyrics.distance(from: lyrics.startIndex, to: chord.start)
                
                let start = lyricsTextView.position(from: lyricsTextView.beginningOfDocument, offset: location)!
                let end = lyricsTextView.position(from: start, offset: 0)!
                
                let tRange = lyricsTextView.textRange(from: start, to: end)!
                let rect = lyricsTextView.firstRect(for: tRange)
                
                let x = rect.origin.x
                let y = rect.origin.y - 0.75 * chordText.size().height
                
                let minSpacing: CGFloat = 8
                
                var frame = CGRect(origin: CGPoint(x: x, y: y), size: chordText.size())
                if let previous = previous, frame.origin.y == previous.origin.y && frame.origin.x < previous.origin.x + previous.width + minSpacing {
                    frame.origin.x = previous.origin.x + previous.width + minSpacing
                }
                
                layer.frame = frame
                layer.contentsScale = UIScreen.main.scale
                lyricsTextView.layer.addSublayer(layer)
                
                previous = frame
            }
        }
        
//        let middleY = scrollView.contentOffset.y + scrollView.frame.height / 2
//        let middleX = scrollView.frame.width / 2
//        
//        middle = lyricsTextView.characterRange(at: CGPoint(x: middleX, y: middleY))?.start
        
        return parsedString
    }
    
    // MARK: - Debug
    
    func next() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(20), execute: {
            self.delegate?.changeSongLyric(self, change: 1)
            self.next()
        })
    }
}

extension SongLyricVC {
    
    func hideBars(_ hidden: Bool, animated: Bool) {
        guard let tabBarController = tabBarController else { return }
        guard let navigationController = navigationController else { return }
        
        if !hidden {
            tabBarController.tabBar.isHidden = hidden
            navigationController.navigationBar.isHidden = hidden
        }
        
        let duration = animated ? 0.3 : 0
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        
        scrollViewTopConstraint.constant += statusBarHeight * (hidden ? 1 : -1)
        
        UIView.animate(withDuration: duration, animations: {
            tabBarController.tabBar.frame.origin.y += tabBarController.tabBar.frame.height * (hidden ? 1 : -1)
            navigationController.navigationBar.frame.origin.y -= (navigationController.navigationBar.frame.height + statusBarHeight) * (hidden ? 1 : -1)
            
            self.view.frame.origin.y -= (navigationController.navigationBar.frame.height + statusBarHeight) * (hidden ? 1 : -1)
            if hidden {
                self.view.frame.size.height += tabBarController.tabBar.frame.height + statusBarHeight
            }
            
            self.view.layoutIfNeeded()
        }) { _ in
            if !hidden {
                self.view.frame.size.height -= (tabBarController.tabBar.frame.height + statusBarHeight)
            }
            
            tabBarController.tabBar.isHidden = hidden
            navigationController.navigationBar.isHidden = hidden
        }
    }
}

extension SongLyricVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        
        cell.textLabel?.text = ["Sdílet", "Otevřít na webu", "Nahlásit"][indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            let textToShare = ["https://zpevnik.proscholy.cz/pisen/" + songLyric.id!]
            
            UserSettings.darkMode = !UserSettings.darkMode
            UICollectionViewCell.appearance().backgroundColor = nil
            
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = view
            
            self.present(activityViewController, animated: true) {
                UserSettings.darkMode = !UserSettings.darkMode
                self.toggleMore()
            }
            break
        case 1:
            guard let url = URL(string: "https://zpevnik.proscholy.cz/pisen/" + songLyric.id!) else { return }
            UIApplication.shared.open(url)
            toggleMore()
            break
        case 2:
            guard let encodedUrl = ("https://docs.google.com/forms/d/e/1FAIpQLSdTaOCzzlfZmyoCB0I_S2kSPiSZVGwDhDovyxkWB7w2LfH0IA/viewform?entry.2038741493=" + songLyric.name!).addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let url = URL(string: encodedUrl) else { return }
            UIApplication.shared.open(url)
            toggleMore()
            break
        default:
            break
        }
    }
}

extension SongLyricVC: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view, view.isDescendant(of: moreOptionsView) {
            return false
        }
        
        return true
    }
}
