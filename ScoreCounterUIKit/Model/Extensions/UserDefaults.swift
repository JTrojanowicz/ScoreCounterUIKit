//
//  UserDefaults.swift
//  ScoreCounterUIKit
//
//  Created by Jaroslaw Trojanowicz on 12/04/2022.
//

import Foundation

extension UserDefaults {
    private enum Keys {
        static let nameOfTeamA = "nameOfTeamA"
        static let nameOfTeamB = "nameOfTeamB"
        static let isTeamAonTheRight = "isTeamAonTheRight"
        static let currentSetNumber = "currentSetNumber"
    }
    
    class var nameOfTeamA: String {
        get {
            if let name = UserDefaults.standard.string(forKey: Keys.nameOfTeamA) {
                return name
            }
            return "Team A"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.nameOfTeamA)
        }
    }
    
    class var nameOfTeamB: String {
        get {
            if let name = UserDefaults.standard.string(forKey: Keys.nameOfTeamB) {
                return name
            }
            return "Team B"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.nameOfTeamB)
        }
    }
    
    class var isTeamAonTheRight: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.isTeamAonTheRight)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.isTeamAonTheRight)
        }
    }
    
    class var currentSetNumber: Int {
        get {
            let storedSetNumber = UserDefaults.standard.integer(forKey: Keys.currentSetNumber)
            if storedSetNumber < 1 {
                return 1 //set number cannot be smaller than 1
            } else {
                return storedSetNumber
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.currentSetNumber)
            
            NotificationCenter.default.post(name: .newSetNumber, object: self, userInfo: nil)
        }
    }
}
