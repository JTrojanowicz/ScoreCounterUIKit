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
    
    class ViewModel: NSObject {
        
        weak var delegate: ViewModelDelegate?
        
        func setVersionLabel() -> String {
            return "v" + (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
        }
        
        //===============================================================================
        // MARK:       ******* Loading the properties from Persistent Store *******
        //===============================================================================
        func loadNamesOfTeams() -> (nameOfTeamLeft: String, nameOfTeamRight: String) {
            let nameOfTeamLeft = UserDefaults.isTeamAonTheLeft ? UserDefaults.nameOfTeamA : UserDefaults.nameOfTeamB
            let nameOfTeamRight = UserDefaults.isTeamAonTheLeft ? UserDefaults.nameOfTeamB : UserDefaults.nameOfTeamA
            return (nameOfTeamLeft: nameOfTeamLeft, nameOfTeamRight: nameOfTeamRight)
        }
        
        func loadCurScoreAndSetNumber() -> (pointsOfTeamLeft: String, pointsOfTeamRight: String, setNumber: String) {
            
            let curSetNumber = UserDefaults.currentSetNumber
            let curScore = CoreDataManager.shared.getScore(of: curSetNumber, with: Date.now)
            let pointsOfTeamLeft = UserDefaults.isTeamAonTheLeft ? String(curScore.teamA) : String(curScore.teamB)
            let pointsOfTeamRight = UserDefaults.isTeamAonTheLeft ? String(curScore.teamB) : String(curScore.teamA)
            
            return (pointsOfTeamLeft: pointsOfTeamLeft, pointsOfTeamRight: pointsOfTeamRight, setNumber: String(curSetNumber))
        }
        
        func loadGainedSets() -> (gainedSetsOfTeamLeft: String, gainedSetsOfTeamRight: String) {
            
            let gainedSets = CoreDataManager.shared.getGainedSets()
            let gainedSetsOfTeamLeft = UserDefaults.isTeamAonTheLeft ? "(\(gainedSets.teamA))" : "(\(gainedSets.teamB))"
            let gainedSetsOfTeamRight = UserDefaults.isTeamAonTheLeft ? "(\(gainedSets.teamB))" : "(\(gainedSets.teamA))"
            
            return (gainedSetsOfTeamLeft: gainedSetsOfTeamLeft, gainedSetsOfTeamRight: gainedSetsOfTeamRight)
        }
        
        //===============================================================================
        // MARK:       ******* UI COMPONETS  - navigationBarButtonsRIGHT *******
        //===============================================================================
        func navigationBarButtonsRight(mainVC: MainVC) -> [UIBarButtonItem] {
            var buttonItems = [UIBarButtonItem]()
            
            buttonItems.append(moreButton(mainVC: mainVC))
            if CoreDataManager.shared.areThereAnyPointsStored() {
                buttonItems.append(trashButton(mainVC: mainVC))
            }
            
            return buttonItems
        }
        
        func trashButton(mainVC: MainVC) -> UIBarButtonItem {
            let largeConfig = UIImage.SymbolConfiguration(textStyle: .title2)
            
            let trashButton = UIButton()
            trashButton.setImage(UIImage(systemName: "trash", withConfiguration: largeConfig), for: .normal)
            trashButton.addTarget(mainVC, action: #selector(mainVC.trashButtonPressed), for: .touchUpInside)
                        
            return UIBarButtonItem(customView: trashButton)
        }
        
        func moreButton(mainVC: MainVC) -> UIBarButtonItem {
            let largeConfig = UIImage.SymbolConfiguration(textStyle: .title2)
            
            let moreButton = UIButton()
            moreButton.setImage(UIImage(systemName: "ellipsis", withConfiguration: largeConfig), for: .normal)
            moreButton.addTarget(mainVC, action: #selector(mainVC.moreButtonPressed), for: .touchUpInside)
            
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
            
            // store one point:
            if courtSide == .left {
                let team: Team = UserDefaults.isTeamAonTheLeft ? .teamA : .teamB
                CoreDataManager.shared.onePointIncrement(of: team)
                
                let score = CoreDataManager.shared.getScore(of: UserDefaults.currentSetNumber, with: Date.now)
                print("+ 1pt for team \(team == .teamA ? "A" : "B") -- score: (A) \(score.teamA):\(score.teamB) (B) @ setNumber = \(UserDefaults.currentSetNumber)")
            } else {
                let team: Team = UserDefaults.isTeamAonTheLeft ? .teamB : .teamA
                CoreDataManager.shared.onePointIncrement(of: team)
                
                let score = CoreDataManager.shared.getScore(of: UserDefaults.currentSetNumber, with: Date.now)
                print("+ 1pt for team \(team == .teamA ? "A" : "B") -- score: (A) \(score.teamA):\(score.teamB) (B) @ setNumber = \(UserDefaults.currentSetNumber)")
            }
            
            delegate?.reloadCurScoreAndSetNumber()
            delegate?.reloadNavigationBarButtons()
        }
    }
}


