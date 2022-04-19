//
//  ViewController.swift
//  ScoreCounterUIKit
//
//  Created by Jaroslaw Trojanowicz on 07/04/2022.
//

import UIKit

class MainVC: UIViewController {

    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var panelView: UIView!
    
    @IBOutlet weak var setNumberLabel: UILabel!
    @IBOutlet weak var teamAName: UILabel!
    @IBOutlet weak var teamBName: UILabel!
    @IBOutlet weak var gainedSetsTeamA: UILabel!
    @IBOutlet weak var gainedSetsTeamB: UILabel!
    @IBOutlet weak var pointsTeamA: UILabel!
    @IBOutlet weak var pointsTeamB: UILabel!
    
    var viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        versionLabel.text = viewModel.setVersionLabel()
        buildNavigationItems()
        buildPanelView()
        loadAllProperties()
    }

    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    private func buildPanelView() {
        
        panelView.backgroundColor = UIColor.white
        
        //corner radius
        panelView.layer.cornerRadius = 8
        
        // shadow
        panelView.layer.shadowColor = UIColor.black.cgColor
        panelView.layer.shadowOffset = CGSize(width: 3, height: 3)
        panelView.layer.shadowOpacity = 0.7
        panelView.layer.shadowRadius = 8
    }
    
    private func buildNavigationItems() {
        navItem.rightBarButtonItems = viewModel.navigationBarButtonsRight()
        navItem.leftBarButtonItems = viewModel.navigationBarButtonsLeft()
    }
    
    private func loadAllProperties() {
        loadNamesOfTeams()
        loadCurScoreAndSetNumber()
        loadGainedSets()
    }
    
    private func loadNamesOfTeams() {
        teamAName.text = UserDefaults.nameOfTeamA
        teamBName.text = UserDefaults.nameOfTeamB
    }
    
    private func loadCurScoreAndSetNumber() {
        let loadedProperties = viewModel.loadCurScoreAndSetNumber()
        setNumberLabel.text = String(loadedProperties.setNumber)
        pointsTeamA.text = String(loadedProperties.teamA)
        pointsTeamB.text = String(loadedProperties.teamB)
    }
    
    private func loadGainedSets() {
        let loadedProperties = viewModel.loadGainedSets()
        gainedSetsTeamA.text = "(\(loadedProperties.gainedSetsOfTeamA))"
        gainedSetsTeamB.text = "(\(loadedProperties.gainedSetsOfTeamB))"
    }
    
    @IBAction func leftButtonPressed(_ sender: Any) {
        viewModel.bigButtonPressed(courtSide: .left)
    }
    
    @IBAction func rightButtonPressed(_ sender: Any) {
        viewModel.bigButtonPressed(courtSide: .right)
    }
    
}
//===============================================================================
// MARK:       ******* ViewModelDelegate *******
//===============================================================================
extension MainVC: ViewModelDelegate {
    func reloadCurScoreAndSetNumber() {
        loadCurScoreAndSetNumber()
    }
    
    func reloadGainedSets() {
        loadGainedSets()
    }
    
    func reloadNavigationBarButtons() {
        buildNavigationItems()
    }
}


