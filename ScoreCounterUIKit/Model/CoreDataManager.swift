//
//  CoreDataManager.swift
//  ScoreCounterUIKit
//
//  Created by Jaroslaw Trojanowicz on 12/04/2022.
//

import Foundation
import CoreData

enum Team {
    case teamA, teamB
}

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    var moc: NSManagedObjectContext
    
    init() {
        let container = NSPersistentContainer(name: AppProperties.coreDataModelName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("loading persistent store - unresolved error \(error), \(error.userInfo)")
            }
        })
        self.moc = container.viewContext
    }
    
    func saveToPersistentStore() {
        if moc.hasChanges {
            do {
                try moc.save() //"How the NSPersistentContainer class handles this internally is difficult to say. (...) Chances are that the NSPersistentContainer class ... make sure a save operation performed by the managed object context doesn't block the main thread." https://cocoacasts.com/building-the-perfect-core-data-stack-with-nspersistentcontainer/
            } catch {
                let nserror = error as NSError
                fatalError("Saving to persistent store - unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //===============================================================================
    // MARK:       **************
    //===============================================================================
    func areThereAnyPointsStored(for setNumber: Int? = nil) -> Bool {
        let fetchRequest: NSFetchRequest<OneGainedPoint> = OneGainedPoint.fetchRequest()
        if let setNumber = setNumber {
            fetchRequest.predicate = NSPredicate(format: "setNumber == %i", setNumber) //filter out all the scores gained at different sets
        }
        
        do {
            let allGainedPoints = try moc.fetch(fetchRequest) // Execute Fetch Request
            return allGainedPoints.count > 0
        } catch(let fetchError) {
            print("⛔️ Error: \(fetchError), \(fetchError.localizedDescription)")
        }
        
        return false
    }
    
    func isMakingNewSetAllowed(setNumber: Int) -> Bool {
        let score = getScore(of: setNumber, with: Date.now)
        if score.teamA >= AppProperties.newSetAllowedFromScore || score.teamB >= AppProperties.newSetAllowedFromScore {
            return true
        }
        return false
    }
    
    func fetchGainedPointsOfAllSets() -> [OneGainedPoint] {
        return fetchGainedPoints(of: nil, oldestFirst: true) // the oldest will be the first
    }
    
    func fetchGainedPoints(of setNumber: Int?, oldestFirst: Bool) -> [OneGainedPoint] {
        
        let fetchRequest: NSFetchRequest<OneGainedPoint> = OneGainedPoint.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(OneGainedPoint.timeStamp), ascending: oldestFirst)]
        if let setNumber = setNumber {
            fetchRequest.predicate = NSPredicate(format: "setNumber == %i", setNumber) //filter out all the scores gained at different sets
        }
        
        do {
            let allGainedPoints = try moc.fetch(fetchRequest) // Execute Fetch Request
            return allGainedPoints
        } catch(let fetchError) {
            print("⛔️ Error: \(fetchError), \(fetchError.localizedDescription)")
        }
        
        return []
    }
    
    func getScore(of setNumber: Int16, with timeStampMax: Date?) -> (teamA: Int, teamB: Int) { //method overloading
        return getScore(of: Int(setNumber), with: timeStampMax)
    }
    
    func getScore(of setNumber: Int, with timeStampMax: Date?) -> (teamA: Int, teamB: Int) {
        
        var score: (teamA: Int, teamB: Int) = (0, 0)
        
        let fetchedGainedPoints = fetchGainedPoints(of: setNumber, oldestFirst: true)
        
        for fetchedPoint in fetchedGainedPoints {
            if let timeStampOfFetchedPoint = fetchedPoint.timeStamp, let timeStampMax = timeStampMax {
                if timeStampOfFetchedPoint <= timeStampMax {
                    if fetchedPoint.isIcrementingTeamA {
                        score.teamA += 1
                    }
                    
                    if fetchedPoint.isIcrementingTeamB {
                        score.teamB += 1
                    }
                }
            }
        }
        
        return score
    }
    
    func getGainedSets() -> (teamA: Int, teamB: Int) {
        var gainedSets: (teamA: Int, teamB: Int) = (0, 0)
        var pointsOfTeamA = 0, pointsOfTeamB = 0
        var previousSetNumber: Int16 = 0
        
        let fetchedGainedPoints = fetchGainedPointsOfAllSets() //sorted: the first is the oldest
        
        if let firstSetNumber = fetchedGainedPoints.first?.setNumber {
            previousSetNumber = firstSetNumber
        } else {
            return gainedSets // (0, 0)
        }
        
        print("Number of ALL fetched points: \(fetchedGainedPoints.count)")
        
        for fetchedPoint in fetchedGainedPoints {
            
            if previousSetNumber == fetchedPoint.setNumber {
                
                if fetchedPoint.isIcrementingTeamA {
                    pointsOfTeamA += 1
                } else if fetchedPoint.isIcrementingTeamB {
                    pointsOfTeamB += 1
                }
                print("fetchedPoint -> A: \(fetchedPoint.isIcrementingTeamA ? "+1" : "0"), B: \(fetchedPoint.isIcrementingTeamB ? "+1" : "0"), setNumber: \(fetchedPoint.setNumber)")
                
            } else { //the set number increased
                
                if pointsOfTeamA > pointsOfTeamB {
                    gainedSets.teamA += 1
                } else if pointsOfTeamB > pointsOfTeamA {
                    gainedSets.teamB += 1
                } //ignore situations when pointsOfTeamA == pointsOfTeamB
                
                print("Set no. \(previousSetNumber) was completed. The score: (A) \(pointsOfTeamA):\(pointsOfTeamB) (B). Gained sets up to now: (A) \(gainedSets.teamA):\(gainedSets.teamB) (B)")
                
                //start counting points for the next set:
                
                pointsOfTeamA = 0 //reset
                pointsOfTeamB = 0 //reset
                previousSetNumber = fetchedPoint.setNumber //update
                // count the points for appropriate team:
                if fetchedPoint.isIcrementingTeamA {
                    pointsOfTeamA += 1
                } else if fetchedPoint.isIcrementingTeamB {
                    pointsOfTeamB += 1
                }
                print("fetchedPoint -> A: \(fetchedPoint.isIcrementingTeamA ? "+1" : "0"), B: \(fetchedPoint.isIcrementingTeamB ? "+1" : "0"), setNumber: \(fetchedPoint.setNumber)")
            }
            
        }
        
        if previousSetNumber < UserDefaults.currentSetNumber { // the set was now completed (the new set was created) there are no gained points for this set yet (but the previous one is
            
            if pointsOfTeamA > pointsOfTeamB {
                gainedSets.teamA += 1
            } else if pointsOfTeamB > pointsOfTeamA {
                gainedSets.teamB += 1
            } //ignore situations when pointsOfTeamA == pointsOfTeamB
            
            print("Set no. \(previousSetNumber) was completed. The score: (A) \(pointsOfTeamA):\(pointsOfTeamB) (B). Gained sets up to now: (A) \(gainedSets.teamA):\(gainedSets.teamB) (B)")
        }
        
        return gainedSets
    }
    
    func eraseEverything() {
        
        let fetchRequest: NSFetchRequest<OneGainedPoint> = OneGainedPoint.fetchRequest()
        fetchRequest.includesPropertyValues = false //This option tells Core Data that no property data should be fetched from the persistent store. Only the object identifier is returned.
        do {
            // Execute Fetch Request
            let fetchedItems = try moc.fetch(fetchRequest)
            
            for fetchedItem in fetchedItems {
                moc.delete(fetchedItem)
            }
            
            saveToPersistentStore()
            
            UserDefaults.currentSetNumber = 1 //default
            
        } catch(let fetchError) {
            print("⛔️ Error: \(fetchError), \(fetchError.localizedDescription)")
        }
    }
    
    func removeLastScore(of setNumber: Int? = nil) {
        
        let fetchRequest: NSFetchRequest<OneGainedPoint> = OneGainedPoint.fetchRequest()
        fetchRequest.includesPropertyValues = false //This option tells Core Data that no property data should be fetched from the persistent store. Only the object identifier is returned.
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(OneGainedPoint.timeStamp), ascending: false)] //last item will come first
        if let setNumber = setNumber {
            fetchRequest.predicate = NSPredicate(format: "setNumber == %i", setNumber) //filter out the items other than for the selected set
        } else {
            let curSet = UserDefaults.currentSetNumber
            fetchRequest.predicate = NSPredicate(format: "setNumber == %i", curSet) //filter out the items other than for the currentSet
        }
        fetchRequest.fetchLimit = 1
        
        do {
            let fetchedItems = try moc.fetch(fetchRequest) // Execute Fetch Request
            
            if let lastItem = fetchedItems.first { //there will only one item or none
                moc.delete(lastItem)
                saveToPersistentStore()
            }
            
        } catch(let fetchError) {
            print("⛔️ Error: \(fetchError), \(fetchError.localizedDescription)")
        }
    }
    
    func onePointIncrement(of team: Team) {
        
        let onePoint = OneGainedPoint(context: moc)
        if team == .teamA {
            onePoint.isIcrementingTeamA = true
        } else {
            onePoint.isIcrementingTeamB = true
        }
        
        onePoint.setNumber = Int16(UserDefaults.currentSetNumber)
        onePoint.timeStamp = Date.now
        
        saveToPersistentStore()
    }
}
