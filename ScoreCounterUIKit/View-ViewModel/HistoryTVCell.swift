//
//  HistoryTVCell.swift
//  ScoreCounterUIKit
//
//  Created by Jaroslaw Trojanowicz on 14/04/2022.
//

import UIKit

class HistoryTVCell: UITableViewCell {

    static let reuseIdentifier = "HistoryTVCell"
    
    @IBOutlet weak var pointsOfTeamOnTheLeft: UILabel!
    @IBOutlet weak var pointsOfTeamOnTheRight: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
