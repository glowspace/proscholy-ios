//
//  LanguageTag.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 08/08/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import Foundation

class LanguageTag: FilterTag {
    
    var title: String {
        get {
            return "Jazyky"
        }
    }
    
    lazy var elements: [FilterAble] = {
        let languages: [Language]? = CoreDataService.fetchData(sortDescriptors: [NSSortDescriptor(key: "count", ascending: false)], context: PersistenceService.context)
        
        return languages ?? []
    }()
    
    private func createLang(_ name: String) -> Language {
        let lang = Language(entity: Language.entity(), insertInto: PersistenceService.context)
        lang.name = name
        
        return lang
    }
}

extension Language: FilterAble {
    
    static var predicateFormat: String {
        get {
            return "language IN %@"
        }
    }
}
