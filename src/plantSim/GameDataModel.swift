//
//  GameDataModel.swift
//  plantSim
//
//  Created by user208467 on 5/3/23.
//
import Foundation

class GameDataModel {
    open var latestScore: TimeInterval = -1
    open var highestScore: TimeInterval = -1
    open var cachedName: String = ""
    open var cheatsActivated: Bool = false
    
    private var settings: Settings!
    private let settingsFileName = "settings"
    
    open var isUsingGestures: Bool {
        get {
            return settings.useGestures
        }
        set {
            settings.useGestures = newValue
            saveSettings()
        }
    }
    
    open var infiniteWater: Bool {
        get {
            return settings.infiniteWater
        }
        set {
            settings.infiniteWater = newValue
            saveSettings()
        }
    }
    
    //var topEntries = [ScoreEntry]()
    
    init() {
        if (!loadSettings())
        {
            settings = Settings()
        }
    }
    
    private func loadSettings()->Bool
    {
        var settingsStr = GameFileManager.loadFile(fileName: settingsFileName)
        if (!settingsStr.isEmpty)
        {
            if let jsonData = settingsStr.data(using: .utf8),
               let newSettings = try? JSONDecoder().decode(Settings.self, from: jsonData) {
                settings = newSettings
                return true
            }
        }
        // Failed to load settings.
        return false
    }
    
    private func saveSettings()->Bool
    {

        if let jsonData = try? JSONEncoder().encode(settings),
           let serializedSettings = String(data: jsonData, encoding: .utf8) {
            if (GameFileManager.saveFile(fileName: settingsFileName, contents: serializedSettings))
            {
                print("Saved settings successfully.")
            } else {
                print("Failed to write settings to file.")
            }
        }
        return false
    }
    
    private class Settings : Codable {
        // Settings
        open var useGestures: Bool = true
        open var infiniteWater: Bool = false
    }
    
}

