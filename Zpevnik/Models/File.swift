//
//  File.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 25/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit
import CoreData

extension File {
    
    static func createFromDict(_ data: [String: Any], _ context: NSManagedObjectContext) -> File? {
        guard let id = data["id"] as? String else { return nil }
        
        guard let file: File = CoreDataService.createOrGetObject(id: id, context: context) else { return nil }
        
        file.id = id
        file.name = data["name"] as? String
        file.typeString = data["type_string"] as? String
        file.url = data["download_url"] as? String
        
        return file
    }
}
