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
    
    private var moc: NSManagedObjectContext
    
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
    func fetchGainedPointsOfAllSets() -> [OneGainedPoint] {
        return fetchGainedPoints()
    }
    
    func fetchGainedPoints(of setNumber: Int? = nil) -> [OneGainedPoint] {
        
        let fetchRequest: NSFetchRequest<OneGainedPoint> = OneGainedPoint.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(OneGainedPoint.timeStamp), ascending: true)]
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
        
        let fetchedGainedPoints = fetchGainedPoints(of: setNumber)
        
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
        
        let fetchedGainedPoints = fetchGainedPoints()
        
        for fetchedPoint in fetchedGainedPoints {
            if fetchedPoint.setNumber > previousSetNumber && previousSetNumber > 0 { //if you noticed that the set number has become greater (but ignore the start up situation)
                if pointsOfTeamA > pointsOfTeamB {
                    gainedSets.teamA += 1
                } else if pointsOfTeamB > pointsOfTeamA {
                    gainedSets.teamB += 1
                }
                //ignore situations when pointsOfTeamA == pointsOfTeamB
                
                previousSetNumber = fetchedPoint.setNumber // update set number
            }
            if fetchedPoint.isIcrementingTeamA {
                pointsOfTeamA += 1
            }
            if fetchedPoint.isIcrementingTeamB {
                pointsOfTeamB += 1
            }
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
            let curSet = getCurrentSet()
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
    
    func getCurrentSet() -> Int {
        let fetchRequest: NSFetchRequest<OneGainedPoint> = OneGainedPoint.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(OneGainedPoint.timeStamp), ascending: false)] //last item will come first
        fetchRequest.fetchLimit = 1
        
        do {
            let fetchedItems = try moc.fetch(fetchRequest) // Execute Fetch Request
            if let lastItem = fetchedItems.first { //there will only one item or none
                return Int(lastItem.setNumber)
            }
        } catch(let fetchError) {
            print("⛔️ Error: \(fetchError), \(fetchError.localizedDescription)")
        }
        
        return 1 //if there no items are found, return default set number: 1
    }
    
    func onePointIncrement(of team: Team) {
        let curSetNumber = getCurrentSet()
        
        let onePoint = OneGainedPoint(context: moc)
        if team == .teamA {
            onePoint.isIcrementingTeamA = true
        } else {
            onePoint.isIcrementingTeamB = true
        }
        
        onePoint.setNumber = Int16(curSetNumber)
        onePoint.timeStamp = Date.now
        
        saveToPersistentStore()
    }
}
