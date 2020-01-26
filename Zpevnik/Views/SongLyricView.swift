//
//  SongLyricView.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 16/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit

class SongLyricView: UIView {
    
    let spacing: CGFloat = 16
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 1.5 * spacing, right: 0)
        
        scrollView.contentInsetAdjustmentBehavior = .never
        
        return scrollView
    }()
    
    private let songLyricNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.numberOfLines = 0
        
        return label
    }()
    
    private let lyricsTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false

        textView.isEditable = false
        textView.isSelectable = false
        textView.isScrollEnabled = false
        
        textView.textContainer.lineFragmentPadding = 0

        return textView
    }()

    private let authorsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        label.numberOfLines = 0

        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if #available(iOS 13, *) {
            backgroundColor = .systemBackground
        }
        
        setViews()
    }
    
    private func setViews() {
        addSubview(scrollView)

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|", metrics: nil, views: ["scrollView": scrollView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|", metrics: nil, views: ["scrollView": scrollView]))

        setScrollView()
    }

    private func setScrollView() {
        scrollView.addSubview(songLyricNameLabel)
        scrollView.addSubview(lyricsTextView)
        scrollView.addSubview(authorsLabel)
        
        songLyricNameLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: spacing).isActive = true
        lyricsTextView.leadingAnchor.constraint(equalTo: songLyricNameLabel.leadingAnchor).isActive = true
        authorsLabel.leadingAnchor.constraint(equalTo: songLyricNameLabel.leadingAnchor).isActive = true
        
        songLyricNameLabel.topAnchor.constraint(equalToSystemSpacingBelow: scrollView.topAnchor, multiplier: 1.5).isActive = true
        lyricsTextView.topAnchor.constraint(equalToSystemSpacingBelow: songLyricNameLabel.bottomAnchor, multiplier: 1).isActive = true
        authorsLabel.topAnchor.constraint(equalToSystemSpacingBelow: lyricsTextView.bottomAnchor, multiplier: 3).isActive = true
        
        authorsLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        
        songLyricNameLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -2 * spacing).isActive = true
        lyricsTextView.widthAnchor.constraint(equalTo: songLyricNameLabel.widthAnchor).isActive = true
        authorsLabel.widthAnchor.constraint(equalTo: songLyricNameLabel.widthAnchor).isActive = true
    }
    
    func updateSongLyric(_ songLyric: SongLyric!, _ verses: [Verse]?) {        
        layoutIfNeeded()

        scrollView.showsVerticalScrollIndicator = false
        scrollView.setContentOffset(CGPoint(x: 0, y: -scrollView.adjustedContentInset.top), animated: false)
        scrollView.showsVerticalScrollIndicator = true
                
        songLyricNameLabel.text = songLyric.name
        updateAuthorsText(songLyric)
        
        fontSizeChanged(verses)
    }
    
    func fontSizeChanged(_ verses: [Verse]?) {
        guard let verses = verses else { return }
        
        songLyricNameLabel.font = .boldSystemFont(ofSize: UserSettings.fontSize * 4 / 3)
        authorsLabel.font = .systemFont(ofSize: UserSettings.fontSize)
        
        removeOldTextLayers()
        
        var attributes = [NSAttributedString.Key : Any]()
        attributes[.font] = UIFont.systemFont(ofSize: UserSettings.fontSize)
        if #available(iOS 13, *) {
            attributes[.foregroundColor] = UIColor.label
        }
        
        let attributedString = NSMutableAttributedString(string: "", attributes: attributes)
        
        var layers = [CATextLayer]()
        var leftOffset: CGFloat = 0
        var showChords = false
        
        for verse in verses {
            let numberLabel = createTextLayer(NSAttributedString(string: verse.number, attributes: attributes))
            layers.append(numberLabel)
            
            attributedString.append(NSAttributedString(string: verse.text, attributes: attributes))
            
            leftOffset = max(leftOffset, numberLabel.frame.width)
            
            showChords = showChords || (verse.chords.count > 0)
        }
        showChords = showChords && UserSettings.showChords
        
        if leftOffset > 0 {
            leftOffset += UserSettings.fontSize / 2
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = leftOffset
        paragraphStyle.headIndent = leftOffset
        paragraphStyle.lineBreakMode = .byWordWrapping
        if showChords {
            paragraphStyle.lineSpacing = UserSettings.fontSize * 1.2
            lyricsTextView.textContainerInset.top = UserSettings.fontSize
        }
        
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.string.count))
        
        let textStorage = NSTextStorage(attributedString: attributedString)
        let layoutManager = NSLayoutManager()

        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer(size: CGSize(width: lyricsTextView.textContainer.size.width, height: .infinity))
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = .byWordWrapping

        layoutManager.addTextContainer(textContainer)
        
        var chordAttributes = attributes
        chordAttributes[.foregroundColor] = UIColor.blue
        
        var index = 0
        let minSpacing: CGFloat = 8
        
        for verse in verses {
            var previous: CGRect?
            
            for chord in verse.chords {
                let layer = createTextLayer(NSAttributedString(string: chord.text, attributes: chordAttributes))
                if let chordRect = rect(for: chord.index + index, textContainer: textContainer, layoutManager: layoutManager, offset: 0) {
                    if let previous = previous, Int(chordRect.minY) == Int(previous.minY) {
                        let diff = previous.minX + previous.width + minSpacing - chordRect.minX
                        if diff > 0 {
                            textStorage.addAttribute(.kern, value: diff, range: NSRange(location: chord.index + index - 1, length: 1))
                        }
                    }
                    
//                    if chord.index + index > 0, rect.origin.x + rect.width > lyricsTextView.textContainer.size.width {
//                        textStorage.insert(NSAttributedString(string: "\n", attributes: chordAttributes), at: chord.index + index - 1)
//
//                        rect.origin.x = 0
//                        rect.origin.y += 1
//
//                        index += 1
//                    }
                    
                    if let chordRect = rect(for: chord.index + index, textContainer: textContainer, layoutManager: layoutManager, offset: 0) {
                        previous = CGRect(origin: chordRect.origin, size: layer.frame.size)
                    }
                }
            }
            
            index += verse.text.count
        }
        
        index = 0
        
        for (i, verse) in verses.enumerated() {
            if let rect = rect(for: index, textContainer: textContainer, layoutManager: layoutManager, offset: 0) {
                layers[i].frame.origin.x = 0
                layers[i].frame.origin.y = rect.origin.y
            }
            lyricsTextView.layer.addSublayer(layers[i])
            
            var previous: CGRect?
            
            for chord in verse.chords {
                let layer = createTextLayer(NSAttributedString(string: chord.text, attributes: chordAttributes))
                if var rect = rect(for: chord.index + index, textContainer: textContainer, layoutManager: layoutManager, offset: 0) {
                    rect.size = layer.frame.size
                    
                    if let previous = previous, rect.minY == previous.minY {
                        let diff = previous.minX + previous.width + minSpacing - rect.minX
                        if diff > 0 {
                            rect.origin.x += diff
                        }
                    }
                    
//                    if rect.origin.x + rect.width > lyricsTextView.textContainer.size.width {
//                        index += 1
//                    }
                    
                    previous = rect
                    
                    layer.frame.origin.x = rect.origin.x
                    layer.frame.origin.y = rect.origin.y - UserSettings.fontSize
                }
                
                if UserSettings.showChords {
                    lyricsTextView.layer.addSublayer(layer)
                }
            }

            index += verses[i].text.count
        }
        
        lyricsTextView.attributedText = textStorage
    }
    
    private func updateAuthorsText(_ songLyric: SongLyric) {
        let songLyricType = SongLyricType(rawValue: Int(songLyric.type))
        var text = ""
        
        if songLyricType != .original {
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
                text += "Autor" + (songLyricType == .original ? ": " : " překladu: ") + authors[0].name!
            } else if authors.count > 0 {
                text += "Autoři" + (songLyricType == .original ? ": " : " překladu: ")

                for (i, author) in authors.enumerated() {
                    text += author.name!
                    if i != authors.count - 1 {
                        text += ", "
                    }
                }
            }
        }
        authorsLabel.text = text

    }
    
    private func removeOldTextLayers() {
        guard let sublayers = lyricsTextView.layer.sublayers else { return }
        
        for layer in sublayers {
            if layer is CATextLayer {
                layer.removeFromSuperlayer()
            }
        }
    }
    
    private func createTextLayer(_ attributedString: NSAttributedString) -> CATextLayer {
        let layer = CATextLayer()
        layer.contentsScale = UIScreen.main.scale
        layer.string = attributedString
        
        layer.frame = CGRect(origin: .zero, size: attributedString.size())
        
        return layer
    }
    
    private func rect(for location: Int, textContainer: NSTextContainer, layoutManager: NSLayoutManager, offset: Int) -> CGRect? {
        var glyphRange = NSRange()

        layoutManager.characterRange(forGlyphRange: NSRange(location: location, length: offset), actualGlyphRange: &glyphRange)

        var rect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        rect.origin.y += lyricsTextView.textContainerInset.top

        return rect
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
