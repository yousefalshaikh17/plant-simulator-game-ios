//
//  ScoreManager.swift
//  plantSim
//
//  Created by user208467 on 5/5/23.
//

import Foundation


class ScoreManager {
    open var topEntries: [ScoreEntry] = [ScoreEntry]()
    
    private let scoresFileName = "scores"
    
    init() {
        loadScores()
    }

    
    private func loadScores()
    {
        let scoresStr = GameFileManager.loadFile(fileName: scoresFileName)
        if (!scoresStr.isEmpty)
        {
            do {
                topEntries = try JSONDecoder().decode([ScoreEntry].self, from: scoresStr.data(using: .utf8)!)
                sortScores()
            } catch {
                print("Failed to load scores.")
                print(error.localizedDescription)
            }
            
        }
    }
    
    private func saveScores()
    {
        let optionalSerializedScores = getSerializedScores()
        if let serializedScores = optionalSerializedScores
        {
            if (GameFileManager.saveFile(fileName: scoresFileName, contents: serializedScores))
            {
                print("Scores saved successfully.")
            } else {
                print("Scores failed to save.")
            }
        }
    }
    
    func getEntry(name: String)-> ScoreEntry?
    {
        for entry in topEntries {
            // Check if name already exists
            if (entry.name == name.uppercased())
            {
                return entry
            }
        }
        return nil
    }
    
    func getEntryCount()-> Int
    {
        return topEntries.count
    }
    
    func addEntry(name: String, timeScore: TimeInterval)->Bool
    {
        // Trim then limit size
        let allowedCharacterSet = CharacterSet.alphanumerics.union(CharacterSet.whitespaces)
        let trimmedName = String(name.trimmingCharacters(in: .whitespaces).components(separatedBy: allowedCharacterSet.inverted).joined().prefix(12))
        if (!trimmedName.isEmpty)
        {
            if let entry = getEntry(name: trimmedName) {
                if entry.timeScore < timeScore {
                    // Update the previous entry with newer score
                    entry.timeScore = timeScore
                    // Resort array
                    sortScores()
                    
                    // Save scores
                    saveScores()
                }
                return true
            }
            
            // By this point, it is clear that no matching names were found in the entries, so a new entry must be made.
            topEntries.append(ScoreEntry(name: trimmedName, timeScore: timeScore))
            // Resort array
            sortScores()
            
            // Save scores
            saveScores()
            
            return true
        }
        return true
    }
    
    private func sortScores()
    {
        topEntries.sort { $0.timeScore > $1.timeScore }
    }
    
    private func getSerializedScores()->String?
    {
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(topEntries),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        print("Scores failed to serialize.")
        return nil
    }
    
    static func getTimeScoreFormatted(time: TimeInterval)-> String
    {
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 1000)
        let seconds = Int(time) % 60
        let minutes = Int(time) / 60
        
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds/10)
    }
    
    class ScoreEntry : Codable {
        
        let name: String // Read only name
        var timeScore: TimeInterval // Not read only incase record gets updated.
        
        init(name: String, timeScore: TimeInterval) {
            self.name = name.uppercased()
            self.timeScore = timeScore
        }
    }

    
}

