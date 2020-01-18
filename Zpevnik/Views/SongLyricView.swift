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
    
//    private var lyricsTextViewHeightConstraint: NSLayoutConstraint?
    
    private var verses: [Verse]?
    
    var songLyric: SongLyric? {
        didSet {
            verses = SongLyricsParser.parseVerses(songLyric?.lyrics)
            update()
        }
    }
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 1.5 * spacing, right: 0)
        
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
        authorsLabel.topAnchor.constraint(equalToSystemSpacingBelow: lyricsTextView.bottomAnchor, multiplier: 1).isActive = true
        
        authorsLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        
        songLyricNameLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -2 * spacing).isActive = true
        lyricsTextView.widthAnchor.constraint(equalTo: songLyricNameLabel.widthAnchor).isActive = true
        authorsLabel.widthAnchor.constraint(equalTo: songLyricNameLabel.widthAnchor).isActive = true
        
        
//        lyricsTextViewHeightConstraint = lyricsTextView.heightAnchor.constraint(equalToConstant: 0)
//        lyricsTextViewHeightConstraint?.isActive = true
    }
    
    func update() {
        guard let songLyric = songLyric else { return }
        
        songLyricNameLabel.text = songLyric.name
        authorsLabel.text = "Autor: TESST"
        
        songLyricNameLabel.font = .boldSystemFont(ofSize: UserSettings.fontSize * 4 / 3)
        authorsLabel.font = .systemFont(ofSize: UserSettings.fontSize)
        
        updateLyricsText()
    }
    
    func updateLyricsText() {
        guard let verses = verses else { return }
        
        if let sublayers = lyricsTextView.layer.sublayers {
            for layer in sublayers {
                if layer is CATextLayer {
                    layer.removeFromSuperlayer()
                }
            }
        }
                
        var attributes = [NSAttributedString.Key : Any]()
        attributes[.font] = UIFont.systemFont(ofSize: UserSettings.fontSize)
        if #available(iOS 13, *) {
            attributes[.foregroundColor] = UIColor.label
        }
        
        let attributedString = NSMutableAttributedString(string: "", attributes: attributes)
        
        var layers = [CATextLayer]()
        var leftOffset: CGFloat = 0
        
        for verse in verses {
            let numberLabel = createLayer(NSAttributedString(string: verse.number, attributes: attributes))
            layers.append(numberLabel)
            leftOffset = max(leftOffset, numberLabel.frame.width)
            attributedString.append(NSAttributedString(string: verse.lyrics, attributes: attributes))
        }
        
        if leftOffset > 0 {
            leftOffset += UserSettings.fontSize
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = leftOffset
        paragraphStyle.headIndent = leftOffset
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.string.count))
        
        let textStorage = NSTextStorage(attributedString: attributedString)
        let layoutManager = NSLayoutManager()

        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer(size: lyricsTextView.textContainer.size)
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = .byWordWrapping

        layoutManager.addTextContainer(textContainer)
        
        var index = 0
        
        for i in 0..<verses.count {
            if let rect = rect(for: index, textContainer: textContainer, layoutManager: layoutManager, offset: 1) {
                layers[i].frame.origin.x = 0
                layers[i].frame.origin.y = rect.origin.y
            }
            lyricsTextView.layer.addSublayer(layers[i])

            index += verses[i].lyrics.count
        }
        
//        lyricsTextViewHeightConstraint?.constant = y
        lyricsTextView.attributedText = textStorage
    }
    
    private func createLayer(_ attributedString: NSAttributedString) -> CATextLayer {
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
