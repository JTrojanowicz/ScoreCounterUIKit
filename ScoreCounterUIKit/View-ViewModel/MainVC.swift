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
    @IBOutlet weak var teamLeftName: UILabel!
    @IBOutlet weak var teamRightName: UILabel!
    @IBOutlet weak var gainedSetsTeamLeft: UILabel!
    @IBOutlet weak var gainedSetsTeamRight: UILabel!
    @IBOutlet weak var pointsTeamLeft: UILabel!
    @IBOutlet weak var pointsTeamRight: UILabel!
    
    var viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        versionLabel.text = viewModel.setVersionLabel()
        buildNavigationItems()
        buildPanelView()
        loadAllProperties()
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
        navItem.rightBarButtonItems = viewModel.navigationBarButtonsRight(mainVC: self)
        navItem.leftBarButtonItems = viewModel.navigationBarButtonsLeft()
    }
    
    private func loadAllProperties() {
        loadNamesOfTeams()
        loadCurScoreAndSetNumber()
        loadGainedSets()
    }
    
    private func loadNamesOfTeams() {
        let loadedProperties = viewModel.loadNamesOfTeams()
        teamLeftName.text = loadedProperties.nameOfTeamLeft
        teamRightName.text = loadedProperties.nameOfTeamRight
    }
    
    private func loadCurScoreAndSetNumber() {
        let loadedProperties = viewModel.loadCurScoreAndSetNumber()
        setNumberLabel.text = loadedProperties.setNumber
        pointsTeamLeft.text = loadedProperties.pointsOfTeamLeft
        pointsTeamRight.text = loadedProperties.pointsOfTeamRight
    }
    
    private func loadGainedSets() {
        let loadedProperties = viewModel.loadGainedSets()
        gainedSetsTeamLeft.text = loadedProperties.gainedSetsOfTeamLeft
        gainedSetsTeamRight.text = loadedProperties.gainedSetsOfTeamRight
    }
    
    @IBAction func leftButtonPressed(_ sender: Any) {
        viewModel.bigButtonPressed(courtSide: .left)
    }
    
    @IBAction func rightButtonPressed(_ sender: Any) {
        viewModel.bigButtonPressed(courtSide: .right)
    }
    
    //===============================================================================
    // MARK:       ******* Navigation Bar - Right Buttons pressed *******
    //===============================================================================
    @objc func moreButtonPressed(_ sender: UIButton) {
        print("moreButtonPressed")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let moreSettingsViewController = storyboard.instantiateViewController(withIdentifier: "MoreSettingsVC") as? MoreSettingsVC
            else {
                return
        }
        
        moreSettingsViewController.modalPresentationStyle = .popover
        moreSettingsViewController.popoverPresentationController?.delegate = self
        moreSettingsViewController.popoverPresentationController?.sourceView = sender
        moreSettingsViewController.popoverPresentationController?.sourceRect = sender.bounds
        
        let rowHeight = 55
        moreSettingsViewController.preferredContentSize = CGSize(width: 200, height: 1 * rowHeight)
        
        moreSettingsViewController.delegate = self
        
        self.present(moreSettingsViewController, animated: true, completion: nil)
    }
    
    @objc func trashButtonPressed(_ sender: UIButton) {
        print("trashButtonPressed")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let confirmTrashVC = storyboard.instantiateViewController(withIdentifier: "ConfirmTrashVC") as? ConfirmTrashVC
            else {
                return
        }
        
        confirmTrashVC.modalPresentationStyle = .popover
        confirmTrashVC.popoverPresentationController?.delegate = self
        confirmTrashVC.popoverPresentationController?.sourceView = sender
        confirmTrashVC.popoverPresentationController?.sourceRect = sender.bounds
        
        confirmTrashVC.preferredContentSize = CGSize(width: 275, height: 90)
        
        confirmTrashVC.delegate = self
        
        self.present(confirmTrashVC, animated: true, completion: nil)
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

//===============================================================================
// MARK:       ******* Delegates *******
//===============================================================================
extension MainVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}

extension MainVC: MoreSettingsVC_delegate {
    func reloadThePanel() {
        loadNamesOfTeams()
        loadCurScoreAndSetNumber()
        loadGainedSets()
    }
}

extension MainVC: ConfirmTrashVC_delegate {
    func reloadTheView() {
        loadCurScoreAndSetNumber()
        loadGainedSets()
        buildNavigationItems()
    }
}

