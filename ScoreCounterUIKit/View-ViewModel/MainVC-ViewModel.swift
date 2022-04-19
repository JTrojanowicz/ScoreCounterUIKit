//
//  MainVC-ViewModel.swift
//  ScoreCounterUIKit
//
//  Created by Jaroslaw Trojanowicz on 07/04/2022.
//

import UIKit

protocol ViewModelDelegate: AnyObject {
    func reloadCurScoreAndSetNumber()
    func reloadGainedSets()
    func reloadNavigationBarButtons()
}

enum CourtSide {
    case left, right
}

extension MainVC {
    
    class ViewModel {
        
        weak var delegate: ViewModelDelegate?
        
        func setVersionLabel() -> String {
            return "v" + (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
        }
        
        //===============================================================================
        // MARK:       ******* Loading the properties from Persistent Store *******
        //===============================================================================
        func loadCurScoreAndSetNumber() -> (teamA: Int, teamB: Int, setNumber: Int) {
            let curSetNumber = UserDefaults.currentSetNumber
            let curScore = CoreDataManager.shared.getScore(of: curSetNumber, with: Date.now)
            return (teamA: curScore.teamA, teamB: curScore.teamB, setNumber: curSetNumber)
        }
        
        func loadGainedSets() -> (gainedSetsOfTeamA: Int, gainedSetsOfTeamB: Int) {
            let gainedSets = CoreDataManager.shared.getGainedSets()
            return (gainedSetsOfTeamA: gainedSets.teamA, gainedSetsOfTeamB: gainedSets.teamB)
        }
        
        //===============================================================================
        // MARK:       ******* UI COMPONETS  - navigationBarButtonsRIGHT *******
        //===============================================================================
        func navigationBarButtonsRight() -> [UIBarButtonItem] {
            var buttonItems = [UIBarButtonItem]()
            
            buttonItems.append(moreButton())
            if CoreDataManager.shared.areThereAnyPointsStored() {
                buttonItems.append(trashButton())
            }
            
            return buttonItems
        }
        
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
        
        //===============================================================================
        // MARK:       ******* UI COMPONETS  - navigationBarButtonsLEFT *******
        //===============================================================================
        func navigationBarButtonsLeft() -> [UIBarButtonItem] {
            var buttonItems = [UIBarButtonItem]()
            
            let currentSet = UserDefaults.currentSetNumber
            if currentSet == 1 {
                if CoreDataManager.shared.areThereAnyPointsStored(for: currentSet) {
                    buttonItems.append(undoButton())
                }
            } else { // currentSet > 1
                if CoreDataManager.shared.areThereAnyPointsStored(for: currentSet) {
                    buttonItems.append(undoButton())
                } else {
                    buttonItems.append(backButton())
                }
            }
            
            if CoreDataManager.shared.isMakingNewSetAllowed(setNumber: currentSet) {
                buttonItems.append(newSetButton())
            }
            
            return buttonItems
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
            return UIBarButtonItem(title: "New Set", style: .plain, target: self, action: #selector(newSetButtonPressed))
        }
        
        //===============================================================================
        // MARK:       ******* BUTTONS PRESSED ACTIONS *******
        //===============================================================================
        @objc func trashButtonPressed() {
            print("trashButtonPressed")
            CoreDataManager.shared.eraseEverything()
            delegate?.reloadCurScoreAndSetNumber()
            delegate?.reloadGainedSets()
            delegate?.reloadNavigationBarButtons()
        }
        
        @objc func moreButtonPressed() {
            print("moreButtonPressed")
        }
        
        @objc func undoButtonPressed() {
            print("undoButtonPressed")
            CoreDataManager.shared.removeLastScore()
            delegate?.reloadCurScoreAndSetNumber()
            delegate?.reloadNavigationBarButtons()
        }
     
        @objc func backButtonPressed() {
            print("backButtonPressed")
            if UserDefaults.currentSetNumber > 1 {
                UserDefaults.currentSetNumber -= 1
                delegate?.reloadCurScoreAndSetNumber()
                delegate?.reloadGainedSets()
                delegate?.reloadNavigationBarButtons()
            }
        }
        
        @objc func newSetButtonPressed() {
            print("newSetButtonPressed")
            UserDefaults.currentSetNumber += 1
            delegate?.reloadCurScoreAndSetNumber()
            delegate?.reloadGainedSets()
            delegate?.reloadNavigationBarButtons()
        }
        
        func bigButtonPressed(courtSide: CourtSide) {
            // check if there are any points stored
            var initiallyNoPointsWereStored = false
            if !CoreDataManager.shared.areThereAnyPointsStored() {
                initiallyNoPointsWereStored = true
            }
            
            // store one point:
            if courtSide == .left {
                let team: Team = UserDefaults.isTeamAonTheRight ? .teamB : .teamA
                CoreDataManager.shared.onePointIncrement(of: team)
                
                let score = CoreDataManager.shared.getScore(of: UserDefaults.currentSetNumber, with: Date.now)
                print("+ 1pt for team \(team == .teamA ? "A" : "B") -- score: (A) \(score.teamA):\(score.teamB) (B) @ setNumber = \(UserDefaults.currentSetNumber)")
            } else {
                let team: Team = UserDefaults.isTeamAonTheRight ? .teamA : .teamB
                CoreDataManager.shared.onePointIncrement(of: team)
                
                let score = CoreDataManager.shared.getScore(of: UserDefaults.currentSetNumber, with: Date.now)
                print("+ 1pt for team \(team == .teamA ? "A" : "B") -- score: (A) \(score.teamA):\(score.teamB) (B) @ setNumber = \(UserDefaults.currentSetNumber)")
            }
            delegate?.reloadCurScoreAndSetNumber()
            
            // check if reloading of navigation bar is needed
            if initiallyNoPointsWereStored {
                delegate?.reloadNavigationBarButtons()
            }
            
            // Check again if the New Set button should be shown
            let currentSet = UserDefaults.currentSetNumber
            let score = CoreDataManager.shared.getScore(of: currentSet, with: Date.now)
            if (score.teamA == AppProperties.newSetAllowedFromScore && score.teamB < AppProperties.newSetAllowedFromScore)
                || (score.teamB == AppProperties.newSetAllowedFromScore && score.teamA < AppProperties.newSetAllowedFromScore) {
                
                // yes, the New Set button should be shown, because one of the teams reached the AppProperties.newSetAllowedFromScore points
                delegate?.reloadNavigationBarButtons()
            }
        }
    }
}
