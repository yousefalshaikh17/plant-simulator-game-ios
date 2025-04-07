//
//  FileManager.swift
//  plantSim
//
//  Created by user208467 on 5/8/23.
//

import Foundation

class GameFileManager {
    
    private static func getDocFile(fileName: String)-> URL
    {
        let docDirUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return docDirUrl.appendingPathComponent(fileName).appendingPathExtension("txt")
    }
    
    static func loadFile(fileName: String)-> String
    {
        let fileUrl = getDocFile(fileName: fileName)
        
        var scoresStr = ""
        do {
            scoresStr = try String(contentsOf: fileUrl)
        } catch let error as NSError {
            print("file \(fileName) not found")
            print(error)
        }
        return scoresStr
    }
    
    static func saveFile(fileName: String, contents: String)-> Bool
    {
        let fileUrl = getDocFile(fileName: fileName)
        do {
            try contents.write(to: fileUrl, atomically: true, encoding: String.Encoding.utf8)
            return true
        } catch let error as NSError {
            print("Failed to write to file.")
            print(error)
        }
        return false
    }
}
