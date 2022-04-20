//
//  MoreSettingsVC.swift
//  ScoreCounterUIKit
//
//  Created by Jaroslaw Trojanowicz on 19/04/2022.
//

import UIKit

protocol MoreSettingsVC_delegate: AnyObject {
    func reloadThePanel()
}

class MoreSettingsVC: UIViewController {

    @IBOutlet weak var swapTheCourtsSV: UIStackView!
    
    weak var delegate: MoreSettingsVC_delegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addGestureRecognizer_swapTheCourts()
    }
    
    private func addGestureRecognizer_swapTheCourts() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOverlay))
        swapTheCourtsSV.addGestureRecognizer(tapGesture)
    }
    
    @objc private func didTapOverlay() {
        UserDefaults.isTeamAonTheLeft.toggle()
        NotificationCenter.default.post(name: .didCourtSwapped, object: self, userInfo: nil)
        delegate?.reloadThePanel()
    }
}
