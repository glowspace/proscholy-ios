//
//  FilterTagCell.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 06/08/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class FilterTagCell: UICollectionViewCell {
    
//    override var isSelected: Bool {
//        didSet {
//            print(isSelected)
//            for view in subviews {
//                if view is PaddingLabel {
//                    print((view as! PaddingLabel).text)
//                }
//            }
//            print(1)
//            alpha = isSelected ? 1 : 0.25
//        }
//    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        for view in subviews {
            if view is PaddingLabel {
                view.removeFromSuperview()
            }
        }
    }
}
