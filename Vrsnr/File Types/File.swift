//
//  File.swift
//  Vrsnr
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
    case Gemspec = "gemspec"
    case Homebrew_Spec = "homebrewspec"

    public static func allFileTypes() -> [FileType] { return [.Plist, .XCConfig, .Podspec, .Gemspec, .Homebrew_Spec] }

    public static func typeOfFileAtPath(_ path: String) throws -> FileType {
        let workspace = NSWorkspace.shared
        let type = try workspace.type(ofFile: path)

        if UTTypeConformsTo(type as CFString, FileType.Plist.rawValue as CFString) {
            return .Plist
        } else if UTTypeConformsTo(type as CFString, FileType.XCConfig.rawValue as CFString) {
            return .XCConfig
        } else {

            // there is no UTI for podspec files, so just look at the extension
            if let extensionString = path.components(separatedBy: ".").last, extensionString == FileType.Podspec.extensionString() {
                return .Podspec
            } else if let extensionString = path.components(separatedBy: ".").last, extensionString == FileType.Gemspec.extensionString() {
                return .Gemspec
            }

            throw NSError(domain: errorDomain, code: Int(ErrorCode.unsupportedFileType.rawValue), userInfo: [ NSLocalizedDescriptionKey: "Unsupported file type." ])
        }
    }

    public func extensionString() -> String {
        switch(self) {
        case .Plist: return "plist"
        case .XCConfig: return "xcconfig"
        case .Podspec: return "podspec"
        case .Gemspec: return "gemspec"
        case .Homebrew_Spec: return "rb"
        }
    }

    public func defaultKey(_ versionType: VersionType) -> String {
        switch self {
        case .Plist: return PlistFile.defaultKeyForVersionType(versionType)
        case .XCConfig: return XcconfigFile.defaultKeyForVersionType(versionType)
        case .Podspec: return PodspecFile.defaultKeyForVersionType(versionType)
        case .Gemspec: return GemspecFile.defaultKeyForVersionType(versionType)
        case .Homebrew_Spec: return HomebrewSpec.defaultKeyForVersionType(versionType)
        }
    }

}

public protocol File {

    func getPath() -> String

    func defaultKeyForVersionType(_ type: VersionType) -> String
    static func defaultKeyForVersionType(_ type: VersionType) -> String
    
    func versionStringForKey(_ key: String?, versionType: VersionType) throws -> String?
    func replaceVersionString<V>(_ original: V, new: V, key: String?) throws where V: Version
    
}

public protocol TextFile {
    static func versionStringFromLine(_ line: String) throws -> String
}

public func createFileForPath(_ path: String) throws -> File {
    let type: FileType = try FileType.typeOfFileAtPath(path)
    switch(type) {
    case .Plist: return PlistFile(path: path)
    case .XCConfig: return XcconfigFile(path: path)
    case .Podspec: return PodspecFile(path: path)
    case .Gemspec: return GemspecFile(path: path)
    case .Homebrew_Spec: return HomebrewSpec(path: path)
    }
}

extension String {
    func contains(key: String) -> Bool {
        // tokenize the line into words, and compare those words == key
        let splitCharacters = CharacterSet(charactersIn: ". ") // podspecs use ruby, so also separate by dot operator
        return components(separatedBy: splitCharacters).filter({$0 == key}).count > 0
    }
}

public func extractVersionStringFromTextFile<T>(_ file: T, versionType: VersionType, key: String) throws -> String where T: File, T: TextFile {
    let data = try NSString(contentsOfFile: file.getPath(), encoding: String.Encoding.utf8.rawValue)

    // get each line that contains the key
    let versionDefinitions = data.components(separatedBy: "\n").filter() { $0.contains(key: key) }

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
            print("More than one possible version definition: \n\n\t\(validLines.joined(separator: "\n\t"))\n\nWill pick first valid one found (\(first)).")
            return first
        } else if validLines.count == 1 {
            return validVersions.first!
        } else {
            throw NSError(domain: errorDomain, code: Int(ErrorCode.noVersionFoundInFile.rawValue), userInfo: [ NSLocalizedDescriptionKey: "Did not find any valid versions defined for key \(key).\n\nFound:\n\(versionDefinitions)" ])
        }
    } else if versionDefinitions.count == 1 {
        return try T.versionStringFromLine(versionDefinitions.first!)
    } else {
        throw NSError(domain: errorDomain, code: Int(ErrorCode.noVersionFoundInFile.rawValue), userInfo: [ NSLocalizedDescriptionKey: "Did not find any occurences of a version defined for key \(key)" ])
    }
}

public func replaceVersionStringInTextFile<T, V>(_ file: T, originalVersion: V, newVersion: V, versionOverride: Bool, key: String) throws where T: File, T: TextFile, V: Version {
    let contents = try NSString(contentsOfFile: file.getPath(), encoding: String.Encoding.utf8.rawValue)

    let newContents = ((contents.components(separatedBy: "\n").map() { line in
        if line.contains(key: key) {
            do {
                let versionString = try T.versionStringFromLine(line)
                let version = try V.parseFromString(versionString)
                if versionOverride { // FIXME: currently for version overrides with --current-version, we replace the first valid instance of the working versionType
                    return line.replacingOccurrences(of: version.description, with: newVersion.description)
                } else {
                    if version == originalVersion {
                        return line.replacingOccurrences(of: originalVersion.description, with: newVersion.description)
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
    } as [String]) as NSArray).componentsJoined(by: "\n")

    try newContents.write(toFile: file.getPath(), atomically: true, encoding: String.Encoding.utf8)

}
