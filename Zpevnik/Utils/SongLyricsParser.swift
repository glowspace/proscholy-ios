//
//  SongLyricsParser.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 16/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import Foundation

struct Verse {
    let number: String
    let lyrics: String
}

class SongLyricsParser {
    
    static func parseVerses(_ lyrics: String?) -> [Verse]? {
        guard let lyrics = prepareSongLyrics(lyrics) else { return nil }
        
        let regex = NSRegularExpression(#"(\d\.|[BCR]:)(?:.|\n)+?(?=\n+\d\.|\n+\(?[BCR]:\)?)"#)
        let range = NSRange(location: 0, length: lyrics.count)
        
        var verses = [Verse]()
        
        regex.enumerateMatches(in: lyrics, options: [], range: range) { (match, _, _) in
            guard let match = match else { return }
            
            if let range = Range(match.range, in: lyrics) {
                let subLyrics = String(lyrics[range])
                
                verses.append(Verse(number: String(subLyrics.prefix(2)), lyrics: String(subLyrics.suffix(subLyrics.count - 3)) + "\n\n"))
            }
        }
        
        if verses.count == 0 {
            verses.append(Verse(number: "", lyrics: lyrics))
        }
        
        return verses
    }
    
    private static func prepareSongLyrics(_ lyrics: String?) -> String? {
        guard let lyrics = lyrics else { return nil }
        
        return substituteChordsPlaceholders(substituteVersesShortcuts(lyrics.replacingOccurrences(of: "\r", with: "")))
    }
    
    private static func substituteVersesShortcuts(_ lyrics: String, _ bridge: String?, _ code: String?, _ chorus: String?) -> String {
        let regex = NSRegularExpression(#"\(?[BCR]:\)?(?=$|\n)"#)
        var range = NSRange(location: 0, length: lyrics.count)
        var lyrics = lyrics
        
        while let match = regex.firstMatch(in: lyrics, options: [], range: range) {
            if let range = Range(match.range, in: lyrics) {
                let subString = lyrics[range]
                if subString.contains("B") {
                    lyrics.replaceSubrange(range, with: bridge ?? "")
                } else if subString.contains("C") {
                    lyrics.replaceSubrange(range, with: code ?? "")
                } else if subString.contains("R") {
                    lyrics.replaceSubrange(range, with: chorus ?? "")
                }
            }
            
            range = NSRange(location: 0, length: lyrics.count)
        }
        
        return lyrics
    }
    
    private static func substituteVersesShortcuts(_ lyrics: String) -> String {
        let regex = NSRegularExpression(#"[BCR]: (?:.|\n)+?(?=\n+\d|\n+\([BCR]:\))"#)
        let range = NSRange(location: 0, length: lyrics.count)
        
        var bridge: String? = nil
        var code: String? = nil
        var chorus: String? = nil
        
        regex.enumerateMatches(in: lyrics, options: [], range: range) { (match, _, _) in
            guard let match = match else { return }
            
            if let range = Range(match.range, in: lyrics) {
                let subString = lyrics[range]
                if subString.starts(with: "B") {
                    bridge = String(subString)
                } else if subString.starts(with: "C") {
                    code = String(subString)
                } else if subString.starts(with: "R") {
                    chorus = String(subString)
                }
            }
        }
        
        return substituteVersesShortcuts(lyrics, bridge, code, chorus)
    }
    
    private static func getChords(_ verse: String) -> [String] {
        let regex = NSRegularExpression(#"\[[^\]]+\]"#)
        let range = NSRange(location: 0, length: verse.count)
        var chords = [String]()
        
        regex.enumerateMatches(in: verse, options: [], range: range) { (match, _, _) in
            guard let match = match else { return }
            
            if let range = Range(match.range, in: verse) {
                chords.append(String(verse[range]))
            }
        }
        
        return chords
    }
    
    private static func parseChords(_ lyrics: String) -> [String]? {
        let regex = NSRegularExpression(#"1\.(?:.|\n)+?(?=\n+\d\.|\n+\(?[BCR]:\)?)"#)
        let nsrange = NSRange(location: 0, length: lyrics.count)
        
        guard let firstVerseMatch = regex.firstMatch(in: lyrics, options: [], range: nsrange), let range = Range(firstVerseMatch.range, in: lyrics) else { return nil }
        
        let chords = getChords(String(lyrics[range]))
        
        return chords
    }
    
    private static func substituteChordsPlaceholders(_ lyrics: String) -> String {
        guard let chords = parseChords(lyrics) else { return lyrics }
        
        let regex = NSRegularExpression(#"\[%\]"#)
        var range = NSRange(location: 0, length: lyrics.count)
        var currentChord = 0
        var lyrics = lyrics
        
        while let match = regex.firstMatch(in: lyrics, options: [], range: range) {
            if let range = Range(match.range, in: lyrics) {
                lyrics.replaceSubrange(range, with: chords[currentChord % chords.count])
                
                currentChord += 1
            }
            
            range = NSRange(location: 0, length: lyrics.count)
        }
        
        return lyrics
    }
}
