//
//  User.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 25/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit
import CoreData

extension User {
    
    static func createFromDict(_ data: [String: Any], _ context: NSManagedObjectContext) -> User? {
        guard let id = data["id"] as? String else { return nil }
        
        guard let user: User = CoreDataService.createOrGetObject(id: id, context: context) else { return nil }
        
        user.id = id
        user.name = data["name"] as? String
        user.email = data["email"] as? String
        
        return user
    }
}
