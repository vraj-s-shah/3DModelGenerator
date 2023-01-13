//
//  FileManager.swift
//  3DModelGenerator
//
//  Created by Vraj Shah on 07/01/23.
//

import Foundation

let fileManagerHelper = FileManagerHelper.shared

/// Helper class for managing files on the device
internal class FileManagerHelper {

    //MARK: -
    //MARK: - Variables
    
    var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    private let fileManager = FileManager.default
    
    //MARK: -
    //MARK: - Singleton object provider
    
    private struct Static {
        static let instance = FileManagerHelper()
    }
    
    class var shared: FileManagerHelper {
        return Static.instance
    }
    
    //MARK: -
    //MARK: - Public functions
    
    func fileExists(url: URL) -> Bool {
        fileManager.fileExists(atPath: url.path)
    }
    
    func createDirectory(url: URL) -> Bool {
        do {
            try fileManager.createDirectory(atPath: url.path, withIntermediateDirectories: true)
        } catch {
            return false
        }
        return true
    }
    
    func removeDirectory(url: URL) -> Bool {
        do {
            try fileManager.removeItem(at: url)
        } catch {
            return false
        }
        return true
    }
    
    func writeDataToFile(data: Data, url: URL) -> Bool {
        do {
            try data.write(to: url)
        } catch {
            return false
        }
        return true
    }
    
}//End of class
