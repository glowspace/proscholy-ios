//
//  Protocols.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 25/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit
import CoreData

protocol FilterDelegate {
    
    func activeFiltersChanged()
}





protocol SongLyricDelegate {
    
    func changeSongLyric(_ controller: SongLyricVC, change: Int)
}
