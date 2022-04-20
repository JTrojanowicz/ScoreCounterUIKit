//
//  ConfirmTrashVC.swift
//  ScoreCounterUIKit
//
//  Created by Jaroslaw Trojanowicz on 20/04/2022.
//

import UIKit

protocol ConfirmTrashVC_delegate: AnyObject {
    func reloadTheView()
}

class ConfirmTrashVC: UIViewController {

    weak var delegate: ConfirmTrashVC_delegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
   
    @IBAction func didTappedConfirmRemovingAllScores(_ sender: Any) {
        self.dismiss(animated: true) {
            CoreDataManager.shared.eraseEverything()
            self.delegate?.reloadTheView()
        }
    }
}
