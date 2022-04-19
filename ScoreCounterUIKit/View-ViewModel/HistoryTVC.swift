//
//  HistoryTVC.swift
//  ScoreCounterUIKit
//
//  Created by Jaroslaw Trojanowicz on 14/04/2022.
//

import UIKit

class HistoryTVC: UITableViewController, HistoryTVC_ViewModelDelegate {
    
    var viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self
        viewModel.performFetchOnFrc()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfFetchedObjects()
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTVCell", for: indexPath) as? HistoryTVCell else {
            fatalError("Unexpected Index Path or cell type")
        }
        
        let index = indexPath.row
        cell.timeStamp.text = viewModel.getTimeStamp(of: index)
        cell.pointsOfTeamOnTheLeft.text = viewModel.getPointsOnTheLeft(of: index)
        cell.pointsOfTeamOnTheRight.text = viewModel.getPointsOnTheRight(of: index)

        return cell
    }
    
    //===============================================================================
    // MARK:       ******* HistoryTVC_ViewModelDelegate *******
    //===============================================================================
    func tableViewBeginUpdates() {
        tableView.beginUpdates()
        print("tableView.beginUpdates()")
    }
    
    func tableViewEndUpdates() {
        tableView.endUpdates()
        print("tableView.endUpdates()")
    }
    
    func tableViewInsertRow(at indexPath: IndexPath) {
        tableView.insertRows(at: [indexPath], with: .left)
        print("tableView.insertRows(indexPath.row = \(indexPath.row))")
    }
    
    func tableViewDeleteRow(at indexPath: IndexPath) {
        tableView.deleteRows(at: [indexPath], with: .right)
        print("tableView.deleteRows(indexPath.row = \(indexPath.row))")
    }
    
    func reloadTableView() {
        tableView.reloadData()
    }
}
