//
//  File.swift
//  SemVer
//
//  Created by Andrew McKnight on 6/28/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import Cocoa
import Foundation

public enum FileType: String {
    case Plist = "com.apple.property-list"
    case XCConfig = "com.apple.xcode.configsettings"
}

public struct File {
    let path: String
    let type: FileType

    init(path: String) throws {
        if !NSFileManager.defaultManager().fileExistsAtPath(path) {
            throw NSError(domain: errorDomain, code: 9, userInfo: [NSLocalizedDescriptionKey: "warning: path does not exist: \(path)"])
        }

        self.path = path

        let error: ErrorPointer = nil
        let type = File.computeTypeOfFileAtPath(path, errorPtr: error)
        if type == nil {
            if let underlyingError = error.memory {
                throw underlyingError
            } else {
                throw NSError(domain: errorDomain, code: 10, userInfo: [NSLocalizedDescriptionKey: "Unknown error."])
            }
        }
        self.type = type!
    }

    private static func computeTypeOfFileAtPath(path: String, errorPtr: ErrorPointer) -> FileType? {
        var fileType: FileType
        let error: ErrorPointer = nil
        if File.isFileAtPath(path, ofType: .Plist, errorPtr: error) {
            fileType = .Plist
        } else if File.isFileAtPath(path, ofType: .XCConfig, errorPtr: error) {
            fileType = .XCConfig
        } else if (error.memory != nil) {
            errorPtr.memory = error.memory
            return nil
        } else {
            errorPtr.memory = NSError(domain: errorDomain, code: 8, userInfo: [NSLocalizedDescriptionKey: "Encountered unsupported file type: \(file)"])
            return nil
        }

        return fileType
    }

    private static func isFileAtPath(path: String, ofType testType: FileType, errorPtr: NSErrorPointer) -> Bool {
        let workspace = NSWorkspace.sharedWorkspace()
        var matchesFileType = false
        do {
            let type = try workspace.typeOfFile(path)
            matchesFileType = UTTypeConformsTo(type, testType.rawValue as CFString)
        } catch {
            errorPtr.memory = error as NSError
        }
        return matchesFileType
    }
}

extension File {

    // MARK: extracting version value strings from files, both semver and numeric

    public func getSemanticVersionForKey(key: String) throws -> SemanticVersion {

        let versionString = try! getVersionStringForKey(key)
        return try! SemanticVersion.parseFromString(versionString)
    }

    public func getNumericVersionForKey(key: String) throws -> NumericVersion {

        let versionString = try! getVersionStringForKey(key)
        return try! NumericVersion.parseFromString(versionString)
    }

}

extension File {

    // MARK: filetype specific version string extraction methods

    private func getVersionStringForKey(key: String) throws -> String {

        var valueStringLineOpt: String?
        switch(file.type) {
        case FileType.Plist:
            valueStringLineOpt = versionStringForKey_Plist(key)
        case FileType.XCConfig:
            valueStringLineOpt = versionStringForKey_Xcconfig(key)
        }

        guard let valueStringLine = valueStringLineOpt else {
            throw NSError(domain: errorDomain, code: ExitCode.CouldNotReadFile.valueAsInt(), userInfo: [NSLocalizedDescriptionKey: "Could not read data from \(file)."])
        }

        return valueStringLine
    }

    private func versionStringForKey_Plist(key: String) -> String? {

        let data = NSDictionary(contentsOfFile: self.path)
        return data?[key] as? String
    }

    private func versionStringForKey_Xcconfig(key: String) -> String? {

        let data = try! NSString(contentsOfFile: file.path, encoding: NSUTF8StringEncoding)

        // get each line that contains the key
        let versionDefinitions = data.componentsSeparatedByString("\n").filter() { line in
            line.containsString("\(key) = ")
        }

        if versionDefinitions.count == 0 {
            return nil
        }

        // if more than one line has the key on it, we just pick the first automatically for now (we only expect the key to appear once in xcconfigs and plists, but this may change when adding more support, e.g. xcodeprojs
        if versionDefinitions.count > 1 {
            print("More than one possible version definition: \(versionDefinitions), will pick first.")
        }
        let line = versionDefinitions.first!

        // discard key assignment portion and any trailing comments, then trim whitespace
        return line.componentsSeparatedByString("=").last!.componentsSeparatedByString("//").first!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }

}
