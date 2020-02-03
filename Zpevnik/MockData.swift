//
//  MockData.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 26/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import Foundation

let user: User? = {
    let user = User.createFromDict(["id": "1", "name": "Patrik Dobiáš", "email": "patrikdobidobias@gmail.com"], PersistenceService.backgroundContext)
    
    if user?.playlists?.count == 0 {
        for i in 0..<100 {
            if let user = user {
                _ = Playlist.create("\(i)", "Test \(i)", user)
            }
        }
    }
    
    return user
}()
