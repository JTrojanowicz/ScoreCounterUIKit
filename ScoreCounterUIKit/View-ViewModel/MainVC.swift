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
    
    lazy var viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        versionLabel.text = viewModel.setVersionLabel()
        buildNavigationItems()
        buildPanelView()
        loadProperties()
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
        navItem.setRightBarButtonItems([viewModel.moreButton(), viewModel.trashButton()], animated: true)
        navItem.setLeftBarButtonItems([viewModel.undoButton()], animated: true)
    }
    
    private func loadProperties() {
        let properties = viewModel.loadProperties()
        setNumberLabel.text = String(properties.currentSetNumber)
        teamAName.text = UserDefaults.nameOfTeamA
        teamBName.text = UserDefaults.nameOfTeamB
        gainedSetsTeamA.text = String(properties.gainedSetsOfTeamA)
        gainedSetsTeamB.text = String(properties.gainedSetsOfTeamB)
        pointsTeamA.text = String(properties.currentPointsOfTeamA)
        pointsTeamB.text = String(properties.currentPointsOfTeamB)
    }
    
    @IBAction func leftButtonPressed(_ sender: Any) {
        viewModel.leftButtonPressed()
    }
    
    @IBAction func rightButtonPressed(_ sender: Any) {
        viewModel.rightButtonPressed()
    }
    
}

extension MainVC: ViewModelDelegate {
    func reloadView() {
        loadProperties()
    }
}


