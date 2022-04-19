//
//  HistoryTVC-ViewModel.swift
//  ScoreCounterUIKit
//
//  Created by Jaroslaw Trojanowicz on 14/04/2022.
//

import CoreData

struct Score {
    var pointsOfTeamA: Int
    var pointsOfTeamB: Int
    var timeStamp: Date
}

protocol HistoryTVC_ViewModelDelegate: AnyObject {
    func tableViewBeginUpdates()
    func tableViewEndUpdates()
    func tableViewInsertRow(at indexPath: IndexPath)
    func tableViewDeleteRow(at indexPath: IndexPath)
    func reloadTableView()
}

extension HistoryTVC  {
    class ViewModel: NSObject, NSFetchedResultsControllerDelegate {
        
        var scoresOfCurrentSet = [Score]()
        
        lazy var frc: NSFetchedResultsController<OneGainedPoint> = {
            let fetchRequest: NSFetchRequest<OneGainedPoint> = OneGainedPoint.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(OneGainedPoint.timeStamp), ascending: false)]
            fetchRequest.predicate = NSPredicate(format: "setNumber == %i", UserDefaults.currentSetNumber) //filter out all the scores gained at different sets
            let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                 managedObjectContext: CoreDataManager.shared.moc,
                                                 sectionNameKeyPath: nil,
                                                 cacheName: nil)
            return frc
        }()
        
        weak var delegate: HistoryTVC_ViewModelDelegate?
        
        override init() {
            super.init()
            loadPropertiesOfCurrentSet()
            frc.delegate = self // so that the delegate functions can be used in this object
            
            NotificationCenter.default.addObserver(self, selector: #selector(onDidSetNumberChanged(notification:)), name: .newSetNumber, object: nil)
        }
        
        //===============================================================================
        // MARK:       ******* Internal Processing *******
        //===============================================================================
        private func loadPropertiesOfCurrentSet() {
            let curSetNumber = UserDefaults.currentSetNumber
            let pointsOfTheSet = CoreDataManager.shared.fetchGainedPoints(of: curSetNumber, oldestFirst: true)
            
            scoresOfCurrentSet.removeAll() //fresh start
            
            var pointsOfTeamA = 0
            var pointsOfTeamB = 0
            
            for onePoint in pointsOfTheSet {
                if onePoint.isIcrementingTeamA {
                    pointsOfTeamA += 1
                }
                if onePoint.isIcrementingTeamB {
                    pointsOfTeamB += 1
                }
                
                if let timeStamp = onePoint.timeStamp {
                    let scoreAtThisPoint = Score(pointsOfTeamA: pointsOfTeamA, pointsOfTeamB: pointsOfTeamB, timeStamp: timeStamp)
                    scoresOfCurrentSet.append(scoreAtThisPoint)
                }
            }
            
            scoresOfCurrentSet.reverse() //must be reversed because we want the youngest on the top
        }
        
        //===============================================================================
        // MARK:       ******* Fetched Results Controller *******
        //===============================================================================
        func performFetchOnFrc() {
            
            frc.fetchRequest.predicate = NSPredicate(format: "setNumber == %i", UserDefaults.currentSetNumber) //update predicate
            
            do {
                try frc.performFetch()
            } catch {
                print("ERROR: Unable to Perform Fetch Request: \(error), \(error.localizedDescription)")
                return
            }
        }
        
        func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            delegate?.tableViewBeginUpdates()
        }
        
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            delegate?.tableViewEndUpdates()
        }
        
        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
            
            switch (type) {
            case .insert:
                guard let indexPath = newIndexPath else { return }
                
                loadPropertiesOfCurrentSet() // inserting is always on the top but for now we calculate everything from stretch
                delegate?.tableViewInsertRow(at: indexPath)
            case .delete:
                guard let indexPath = indexPath else { return }
                
                loadPropertiesOfCurrentSet() // deleting is always from the top but for now we calculate everything from stretch
                delegate?.tableViewDeleteRow(at: indexPath)
            case .update:
                print("ERROR: update on the FRC controller shouldn't happen")
                break
            case .move:
                print("ERROR: move on the FRC controller shouldn't happen")
                break
            @unknown default: //this should not happen (added to silence the warning)
                break
            }
        }
        
        //===============================================================================
        // MARK:       ******* Methods used by the Cell *******
        //===============================================================================
        
        func getNumberOfFetchedObjects() -> Int {
            return scoresOfCurrentSet.count
        }
        
        func getTimeStamp(of index: Int) -> String {
            guard index < scoresOfCurrentSet.count else {
                print("ERROR: index out of range")
                return "error"
            }
            
            let timeStamp = scoresOfCurrentSet[index].timeStamp
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            return dateFormatter.string(from: timeStamp)
        }
        
        func getPointsOnTheLeft(of index: Int) -> String {
            guard index < scoresOfCurrentSet.count else {
                print("ERROR: index out of range")
                return "error"
            }
            
            let pointsOnTheLeft = UserDefaults.isTeamAonTheRight ? scoresOfCurrentSet[index].pointsOfTeamB : scoresOfCurrentSet[index].pointsOfTeamA
            
            return String(pointsOnTheLeft)
        }
        
        func getPointsOnTheRight(of index: Int) -> String {
            guard index < scoresOfCurrentSet.count else {
                print("ERROR: index out of range")
                return "error"
            }
            
            let pointsOnTheRight = UserDefaults.isTeamAonTheRight ? scoresOfCurrentSet[index].pointsOfTeamA : scoresOfCurrentSet[index].pointsOfTeamB
            
            return String(pointsOnTheRight)
        }
        
        //===============================================================================
        // MARK:       ******* Notifications *******
        //===============================================================================
        @objc func onDidSetNumberChanged(notification: NSNotification) {
            loadPropertiesOfCurrentSet()
            performFetchOnFrc() // perform fetch on FRC when set number changes
            delegate?.reloadTableView()
        }
    }
}
