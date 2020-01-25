//
//  External.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 25/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit
import CoreData
import YoutubePlayer_in_WKWebView

extension External {
    
    static func createFromDict(_ data: [String: Any], _ context: NSManagedObjectContext) -> External? {
        guard let id = data["id"] as? String else { return nil }
        
        guard let external: External = CoreDataService.createOrGetObject(id: id, context: context) else { return nil }
        
        external.id = id
        external.type = data["type"] as? Int32 ?? 0
        external.typeString = data["type_string"] as? String
        external.mediaId = data["media_id"] as? String
        
        return external
    }
}

extension External {
    
    func createView() -> UIView? {
        guard let typeString = typeString else { return nil }
        
        switch typeString {
        case "youtube":
            return createYoutubeView()
        case "spotify URI":
            return createSpotifyView()
        default: break
        }
        
        return nil
    }
    
    func size(_ maxWidth: CGFloat, _ spacing: CGFloat) -> CGSize {
        guard let typeString = typeString else { return .zero }
        
        var width: CGFloat = 0, height: CGFloat = 0
        
        switch typeString {
        case "youtube":
            width = min(300, maxWidth - 2 * spacing)
            height = width * 3 / 4
        case "spotify URI":
            guard let url = URL(string: "spotify:track:\(mediaId ?? "")") else { return .zero }
           
            if UIApplication.shared.canOpenURL(url) {
                width = min(200, maxWidth - 2 * spacing)
                height = 50
            }
        default: break
        }
        
        return CGSize(width: width, height: height)
    }
    
    private func createYoutubeView() -> UIView? {
        guard let mediaId = mediaId else { return nil }
        
        let view = WKYTPlayerView()
        view.translatesAutoresizingMaskIntoConstraints = false

        view.load(withVideoId: mediaId)
        
        return view
    }
    
    private func createSpotifyView() -> UIView {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(openSpotify), for: .touchUpInside)
        
        button.setTitle("Přehrát na Spotify", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 23)
        button.backgroundColor = .spotifyGreen
        
        button.layer.cornerRadius = 25
        
        return button
    }
}

// MARK: - Handlers

extension External {
    
    @objc func openSpotify() {
        guard let mediaId = mediaId else { return }
        
        guard let url = URL(string: "spotify:track:\(mediaId)") else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
