//
//  Protocols.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 25/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

protocol FilterDelegate {
    
    func activeFiltersChanged()
}

protocol SongLyricDelegate {
    
    func changeSongLyric(_ controller: SongLyricVC, change: Int)
}

protocol SlideViewDelegate {
    
    func songLyricHasSupportedExternals() -> Bool
    
    func canScroll() -> Bool
    
    func showTuneOptions()
    
    func showExternals()
    
    func toggleSlideView(animations: @escaping () -> Void, completionHandler: @escaping () -> Void)
    
    func toggleAutoScroll(completionHandler: @escaping (Bool) -> Void)
}

protocol TranslationDelegate {
    
    func songLyricTranslationChanged(_ songLyric: SongLyric)
}

protocol UserMenuDelegate {
    func presentViewController(_ viewController: UIViewController, animated: Bool)
}

protocol UserCellDelegate {
    func showUserMenu()
}
