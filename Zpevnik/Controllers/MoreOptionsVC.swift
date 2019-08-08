//
//  MoreOptionsVC.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 08/08/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

//class MoreOptionsVC: ViewController {
//    
//}
//
//extension MoreOptionsVC: UITableViewDelegate, UITableViewDataSource {
//    
//}

class TableView: UITableView {
    
    override var intrinsicContentSize: CGSize {
        print(contentSize)
        return contentSize
    }
}
