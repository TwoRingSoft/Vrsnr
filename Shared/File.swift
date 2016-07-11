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
    case Podspec = "podspec"

    public static func allFileTypes() -> [FileType] {
        return [
            FileType.Plist,
            FileType.XCConfig,
            FileType.Podspec
        ]
    }

    public static func typeOfFileAtPath(path: String) throws -> FileType {
        let workspace = NSWorkspace.sharedWorkspace()
        let type = try workspace.typeOfFile(path)

        if UTTypeConformsTo(type, FileType.Plist.rawValue as CFString) {
            return .Plist
        } else if UTTypeConformsTo(type, FileType.XCConfig.rawValue as CFString) {
            return .XCConfig
        } else {

            // there is no UTI for podspec files, so just look at the extension
            if let extensionString = path.componentsSeparatedByString(".").last where extensionString == FileType.Podspec.extensionString() {
                return .Podspec
            }

            throw NSError(domain: errorDomain, code: Int(ErrorCode.UnsupportedFileType.rawValue), userInfo: [ NSLocalizedDescriptionKey: "Unsupported file type." ])
        }
    }

    public func extensionString() -> String {
        switch(self) {
        case .Plist:
            return "plist"
        case .XCConfig:
            return "xcconfig"
        case .Podspec:
            return "podspec"
        }
    }

    public func defaultKey(versionType: VersionType) -> String {
        switch self {
        case .Plist:
            return PlistFile.defaultKeyForVersionType(versionType)
        case .XCConfig:
            return XcconfigFile.defaultKeyForVersionType(versionType)
        case .Podspec:
            return PodspecFile.defaultKeyForVersionType(versionType)
        }
    }

}

public protocol File {

    func getPath() -> String

    func defaultKeyForVersionType(type: VersionType) -> String
    static func defaultKeyForVersionType(type: VersionType) -> String
    
    func versionStringForKey(key: String?, versionType: VersionType) throws -> String?
    func replaceVersionString<V where V: Version>(original: V, new: V, key: String?) throws
    
}

public protocol TextFile {
    static func versionStringFromLine(line: String) throws -> String
}

public func createFileForPath(path: String) throws -> File {
    let type: FileType = try FileType.typeOfFileAtPath(path)
    switch(type) {
    case .Plist:
        return PlistFile(path: path)
    case .XCConfig:
        return XcconfigFile(path: path)
    case .Podspec:
        return PodspecFile(path: path)
    }
}

public func extractVersionStringFromTextFile<T where T: File, T: TextFile>(file: T, versionType: VersionType, key: String) throws -> String {
    let data = try NSString(contentsOfFile: file.getPath(), encoding: NSUTF8StringEncoding)

    // get each line that contains the key\
    let versionDefinitions = data.componentsSeparatedByString("\n").filter() { line in
        line.containsString("\(key)")
    }

    // if more than one line has the key on it, for now we just automatically pick the first line with a valid version definition
    var validVersions = [String]()
    if versionDefinitions.count > 1 {
        let validLines = versionDefinitions.filter() { line in
            do {
                let versionString = try T.versionStringFromLine(line)

                switch versionType {
                case .Numeric:
                    let _: NumericVersion = try versionType.parseFromString(versionString)
                case .Semantic:
                    let _: SemanticVersion = try versionType.parseFromString(versionString)
                }

                validVersions.append(versionString)
                return true
            } catch {
                return false
            }
        }

        if validVersions.count > 1 {
            let first = validVersions.first!
            print("More than one possible version definition: \(versionDefinitions), will pick first valid one found \(first).")
            return first
        } else if validLines.count == 1 {
            return validVersions.first!
        } else {
            throw NSError(domain: errorDomain, code: Int(ErrorCode.NoVersionFoundInFile.rawValue), userInfo: [ NSLocalizedDescriptionKey: "Did not find any valid versions defined for key \(key).\n\nFound:\n\(versionDefinitions)" ])
        }
    } else if versionDefinitions.count == 1 {
        return try T.versionStringFromLine(versionDefinitions.first!)
    } else {
        throw NSError(domain: errorDomain, code: Int(ErrorCode.NoVersionFoundInFile.rawValue), userInfo: [ NSLocalizedDescriptionKey: "Did not find any occurences of a version defined for key \(key)" ])
    }
}

public func replaceVersionStringInTextFile<T, V where T: File, T: TextFile, V: Version>(file: T, originalVersion: V, newVersion: V, versionOverride: Bool, key: String) throws {
    let contents = try NSString(contentsOfFile: file.getPath(), encoding: NSUTF8StringEncoding)

    let newContents = ((contents.componentsSeparatedByString("\n").map() { line in
        if line.containsString(key) {
            do {
                let versionString = try T.versionStringFromLine(line)
                let version = try V.parseFromString(versionString)
                if versionOverride { // FIXME: currently for version overrides with --current-version, we replace the first valid instance of the working versionType
                    return line.stringByReplacingOccurrencesOfString(version.description, withString: newVersion.description)
                } else {
                    if version == originalVersion {
                        return line.stringByReplacingOccurrencesOfString(originalVersion.description, withString: newVersion.description)
                    } else {
                        return line
                    }
                }
            } catch {
                return line
            }
        } else {
            return line
        }
    } as [String]) as NSArray).componentsJoinedByString("\n")

    try newContents.writeToFile(file.getPath(), atomically: true, encoding: NSUTF8StringEncoding)

}
