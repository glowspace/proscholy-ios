//
//  Author.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 06/08/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import CoreData

extension Author {
    
    static func createFromDict(_ data: [String: Any], _ context: NSManagedObjectContext) -> Author? {
        guard let id = data["id"] as? String else { return nil }
        
        guard let author: Author = CoreDataService.createOrGetObject(id: id, context: context) else { return nil }
        
        author.id = id
        author.name = data["name"] as? String
        
        return author
    }
}
