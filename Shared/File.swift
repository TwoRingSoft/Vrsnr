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

    public static func allFileTypes() -> [FileType] {
        return [
            FileType.Plist,
            FileType.XCConfig
        ]
    }

    public static func typeOfFileAtPath(path: String) throws -> FileType {
        let workspace = NSWorkspace.sharedWorkspace()
        let type = try! workspace.typeOfFile(path)

        if UTTypeConformsTo(type, FileType.Plist.rawValue as CFString) {
            return .Plist
        } else if UTTypeConformsTo(type, FileType.XCConfig.rawValue as CFString) {
            return .XCConfig
        } else {
            throw NSError(domain: errorDomain, code: Int(ErrorCode.UnsupportedFileType.rawValue), userInfo: [ NSLocalizedDescriptionKey: "Unsupported file type." ])
        }
    }

    public func extensionString() -> String {
        switch(self) {
        case .Plist:
            return "plist"
        case .XCConfig:
            return "xcconfig"
        }
    }

    public func defaultKey(versionType: VersionType) -> String {
        switch self {
        case .Plist:
            return PlistFile.defaultKeyForVersionType(versionType)
        case .XCConfig:
            return XcconfigFile.defaultKeyForVersionType(versionType)
        }
    }

}

public protocol File {

    func defaultKeyForVersionType(type: VersionType) -> String
    static func defaultKeyForVersionType(type: VersionType) -> String
    
    func versionStringForKey(key: String?, versionType: VersionType) -> String?
    func replaceVersionString(original: Version, new: Version, key: String?) throws

}

public func createFileForPath(path: String) throws -> File {
    let type: FileType = try! FileType.typeOfFileAtPath(path)
    switch(type) {
    case .Plist:
        return PlistFile(path: path)
    case .XCConfig:
        return XcconfigFile(path: path)
    }
}
