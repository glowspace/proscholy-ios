//
//  SongLyricsParser.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 16/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import Foundation

struct Chord {
    let text: String
    let index: Int
    let inline: Bool
}

struct Verse {
    let number: String
    let text: String
    let chords: [Chord]
}

class SongLyricsParser {
    
    static func parseVerses(_ lyrics: String?) -> [Verse]? {
        guard var lyrics = lyrics else { return nil }
        
        lyrics = substituteChordsPlaceholders(lyrics.replacingOccurrences(of: "\r", with: "").replacingOccurrences(of: "@", with: ""))
        
        let regex = NSRegularExpression(#"\s*(\d\.|\(?[BCR]\d?[:.]\)?)\s*((?:=\s*(\d\.)|.|\n)*?)\n*(?=$|[^=]?\d\.|\(?[BCR]\d?[:.]\)?)"#)
        let range = NSRange(location: 0, length: lyrics.count)
        
        var verses = [Verse]()
        var substitutes = [String: Substring]()
        
        var firstIndex: String.Index?
        
        regex.enumerateMatches(in: lyrics, options: [], range: range) { (match, _, _) in
            guard let match = match else { return }
            
            if let verseNumberRange = Range(match.range(at: 1), in: lyrics), let verseRange = Range(match.range(at: 2), in: lyrics) {
                let verseNumber = lyrics[verseNumberRange].replacingOccurrences(of: #"\(|\)"#, with: "", options: .regularExpression).replacingOccurrences(of: #"([BCR]\d?)."#, with: "$1:", options: .regularExpression)
                var verseText = lyrics[verseRange]
                if firstIndex == nil {
                    firstIndex = verseNumberRange.lowerBound
                }
                
                if match.range(at: 2).length != 0 {
                    if match.range(at: 3).length != 0, let replaceRange = Range(match.range(at: 3), in: lyrics) {
                        let replaceWithVerse = String(lyrics[replaceRange])
                        verseText = substitutes[replaceWithVerse] ?? ""
                    } else {
                        substitutes[verseNumber] = verseText
                    }
                } else {
                    verseText = substitutes[verseNumber] ?? ""
                }
                
                if match.range.upperBound != lyrics.count {
                    verseText += "\n\n"
                }
                
                verses.append(createVerse(verseNumber, String(verseText)))
            }
        }
        
        if firstIndex != lyrics.startIndex {
            verses.insert(createVerse("", String(lyrics.prefix(upTo: firstIndex ?? lyrics.endIndex))), at: 0)
        }
        
        return verses
    }
    
    private static func createVerse(_ number: String, _ text: String) -> Verse {
        let regex = NSRegularExpression(#"\[[^\]]+\]"#)
        let text = text.replacingOccurrences(of: #" (\[[^\]]+\]) "#, with: " $1", options: .regularExpression).replacingOccurrences(of: "][", with: "] [")
        let range = NSRange(location: 0, length: text.count)
        
        var offset = 0
        var chords = [Chord]()
        
        regex.enumerateMatches(in: text, options: [], range: range) { (match, _, _) in
            guard let match = match else { return }
            
            if let range = Range(match.range, in: text) {
                let chord = text[range].replacingOccurrences(of: #"[\[\]]"#, with: "", options: .regularExpression)
                
                chords.append(Chord(text: chord, index: match.range.location - offset, inline: false))
                
                offset += match.range.length
            }
        }
        
        return Verse(number: number, text: text.replacingOccurrences(of: #"\[[^\]]+\]"#, with: "", options: .regularExpression), chords: chords)
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
        let regex = NSRegularExpression(#"1\.(?:.|\n)+?(?=\n+\d\.|\n+\(?[BCR][:.]\)?)"#)
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
