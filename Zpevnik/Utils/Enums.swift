//
//  Enums.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 26/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import Foundation

enum AboutState {
    case aboutSongBook, aboutApp
}

enum HalfViewState {
    case normal, expanded
}

enum OptionsType {
    case songLyric, songList, songListArchived, settings
}

enum SongLyricType: Int {
    case original, translation, authorizedTranslation
}

enum SupportedExternals: String {
    case youtube = "youtube"
    case spotify = "spotify URI"
}
