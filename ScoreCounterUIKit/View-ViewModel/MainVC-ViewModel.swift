//
//  MainVC-ViewModel.swift
//  ScoreCounterUIKit
//
//  Created by Jaroslaw Trojanowicz on 07/04/2022.
//

import UIKit

protocol ViewModelDelegate: AnyObject {
    func reloadView()
}

extension MainVC {
    struct StoredProperties {
        let currentSetNumber: Int
        let gainedSetsOfTeamA: Int
        let gainedSetsOfTeamB: Int
        let currentPointsOfTeamA: Int
        let currentPointsOfTeamB: Int
    }
    
    class ViewModel {
        
        weak var delegate: ViewModelDelegate?
        
        func setVersionLabel() -> String {
            return "v" + (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
        }
        
        //===============================================================================
        // MARK:       ******* Loading the properties from Persistent Store *******
        //===============================================================================
        func loadProperties() -> StoredProperties {
            let curSetNumber = CoreDataManager.shared.getCurrentSet()
            let curScore = CoreDataManager.shared.getScore(of: curSetNumber, with: Date.now)
            let gainedSets = CoreDataManager.shared.getGainedSets()
            return StoredProperties(currentSetNumber: curSetNumber,
                                    gainedSetsOfTeamA: gainedSets.teamA,
                                    gainedSetsOfTeamB: gainedSets.teamB,
                                    currentPointsOfTeamA: curScore.teamA,
                                    currentPointsOfTeamB: curScore.teamB)
           
        }
        
        //===============================================================================
        // MARK:       ******* UI COMPONETS *******
        //===============================================================================
        func trashButton() -> UIBarButtonItem {
            let largeConfig = UIImage.SymbolConfiguration(textStyle: .title2)
            
            let trashButton = UIButton()
            trashButton.setImage(UIImage(systemName: "trash", withConfiguration: largeConfig), for: .normal)
            trashButton.addTarget(self, action: #selector(trashButtonPressed), for: .touchUpInside)
                        
            return UIBarButtonItem(customView: trashButton)
        }
        
        func moreButton() -> UIBarButtonItem {
            let largeConfig = UIImage.SymbolConfiguration(textStyle: .title2)
            
            let moreButton = UIButton()
            moreButton.setImage(UIImage(systemName: "ellipsis", withConfiguration: largeConfig), for: .normal)
            moreButton.addTarget(self, action: #selector(moreButtonPressed), for: .touchUpInside)
            
            return UIBarButtonItem(customView: moreButton)
        }
        
        func undoButton() -> UIBarButtonItem {
            let largeConfig = UIImage.SymbolConfiguration(textStyle: .title2)
            
            let undoButton = UIButton()
            undoButton.setImage(UIImage(systemName: "arrow.uturn.backward.square", withConfiguration: largeConfig), for: .normal)
            undoButton.addTarget(self, action: #selector(undoButtonPressed), for: .touchUpInside)
                        
            return UIBarButtonItem(customView: undoButton)
        }
        
        func backButton() -> UIBarButtonItem {
            let largeConfig = UIImage.SymbolConfiguration(textStyle: .title2)
            
            let undoButton = UIButton()
            undoButton.setImage(UIImage(systemName: "chevron.backward.square", withConfiguration: largeConfig), for: .normal)
            undoButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
                        
            return UIBarButtonItem(customView: undoButton)
        }
        
        func newSetButton() -> UIBarButtonItem {
            let newSetButton = UIButton()
            newSetButton.setTitle("New set", for: .normal)
            newSetButton.addTarget(self, action: #selector(newSetButtonPressed), for: .touchUpInside)
                        
            return UIBarButtonItem(customView: newSetButton)
        }
        
        //===============================================================================
        // MARK:       ******* BUTTONS PRESSED ACTIONS *******
        //===============================================================================
        @objc func trashButtonPressed() {
            print("trashButtonPressed")
            CoreDataManager.shared.eraseEverything()
            delegate?.reloadView()
        }
        
        @objc func moreButtonPressed() {
            print("moreButtonPressed")
        }
        
        @objc func undoButtonPressed() {
            print("undoButtonPressed")
            CoreDataManager.shared.removeLastScore()
            delegate?.reloadView()
        }
     
        @objc func backButtonPressed() {
            print("backButtonPressed")
        }
        
        @objc func newSetButtonPressed() {
            print("newSetButtonPressed")
        }
        
        func leftButtonPressed() {
            let team: Team = UserDefaults.isTeamAonTheRight ? .teamB : .teamA
            CoreDataManager.shared.onePointIncrement(of: team)
            delegate?.reloadView()
        }
        
        func rightButtonPressed() {
            let team: Team = UserDefaults.isTeamAonTheRight ? .teamA : .teamB
            CoreDataManager.shared.onePointIncrement(of: team)
            delegate?.reloadView()
        }
    }
}
