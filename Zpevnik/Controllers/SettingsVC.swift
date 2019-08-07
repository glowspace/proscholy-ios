//
//  SettingsVC.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 04/08/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.allowsSelection = false
        tableView.isScrollEnabled = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        
        return tableView
    }()
    
    var cells: [UITableViewCell]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", metrics: nil, views: ["tableView": tableView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", metrics: nil, views: ["tableView": tableView]))
        
        setTitle("Nastavení")
        
        createCells()
    }
    
    // MARK: - Cells Settings
    
    private func createCells() {
        cells = []
        
        cells.append(createSettingCell(title: "Blokovat zhasínání displeje", isOn: UserSettings.blockAutoLock, action: #selector(blockAutoLockToggle)))
        cells.append(createSettingCell(title: "Patkové písmo", isOn: UserSettings.serif, action: #selector(serifToggle)))
        cells.append(createSettingCell(title: "Posuvky", isOn: UserSettings.showSliders, action: #selector(slidersToggle)))
        cells.append(createSettingCell(title: "Akordy", isOn: UserSettings.showChords, action: #selector(showChordsToggle)))
        cells.append(createFontSizeCell())
        cells.append(createSettingCell(title: "Tmavý mód", isOn: UserSettings.darkMode, action: #selector(darkModeToggle)))
        cells.append(createSettingCell(title: "Zobrazit spodní nabídku", isOn: UserSettings.showBottomOptions, action: #selector(bottomOptionsToggle)))
    }
    
    private func createFontSizeCell() -> UITableViewCell {
        let cell = UITableViewCell()
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Velikost písma"
        
        let slider = Slider(currentValue: UserSettings.fontSize, minimumValue: Constants.minFontSize, maximumValue: Constants.maxFontSize)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(fontSizeChanged(slider:)), for: .valueChanged)
        
        let minFontLabel = UILabel()
        minFontLabel.translatesAutoresizingMaskIntoConstraints = false
        minFontLabel.text = "A"
        minFontLabel.font = UIFont.getFont(ofSize: CGFloat(Constants.minFontSize))
        
        let maxFontLabel = UILabel()
        maxFontLabel.translatesAutoresizingMaskIntoConstraints = false
        maxFontLabel.text = "A"
        maxFontLabel.font = UIFont.getFont(ofSize: CGFloat(Constants.maxFontSize))
        
        cell.addSubview(label)
        cell.addSubview(slider)
        cell.addSubview(minFontLabel)
        cell.addSubview(maxFontLabel)
        
        let views = [
            "label": label,
            "slider": slider,
            "minFontLabel": minFontLabel,
            "maxFontLabel": maxFontLabel
        ]
        
        cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-|", metrics: nil, views: views))
        cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[minFontLabel]-[slider]-[maxFontLabel]-|", options: [.alignAllCenterY], metrics: nil, views: views))
        cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[label]-[slider(==30)]-|", metrics: nil, views: views))
        
        return cell
    }
    
    private func createSettingCell(title: String, isOn: Bool, action: Selector) -> SettingCell {
        let cell = SettingCell()
        
        cell.titleLabel.text = title
        cell.switchButton.isOn = isOn
        cell.switchButton.addTarget(self, action: action, for: .valueChanged)
        
        return cell
    }
    
    // MARK: - Handlers
    
    @objc func blockAutoLockToggle() {
        UserSettings.blockAutoLock = !UserSettings.blockAutoLock
    }
    
    @objc func serifToggle() {
        UserSettings.serif = !UserSettings.serif
    }
    
    @objc func slidersToggle() {
        UserSettings.showSliders = !UserSettings.showSliders
    }
    
    @objc func showChordsToggle() {
        UserSettings.showChords = !UserSettings.showChords
    }
    
    @objc func fontSizeChanged(slider: Slider) {
        UserSettings.fontSize = slider.currentValue
    }
    
    @objc func darkModeToggle() {
        UserSettings.darkMode = !UserSettings.darkMode
        
        for controller in [navigationController, tabBarController] {
            if let view = controller?.view {
                let superview = view.superview
                view.removeFromSuperview()
                superview?.addSubview(view)
            }
        }
    }
    
    @objc func bottomOptionsToggle() {
        UserSettings.showBottomOptions = !UserSettings.showBottomOptions
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SettingsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 5
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["Nastavení zobrazení", "Nastavení písní"][section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = (indexPath.section == 1 ? 2 : 0) + indexPath.row
        
        return cells[index]
    }
}
