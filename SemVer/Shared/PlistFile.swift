//
//  PlistFile.swift
//  SemVer
//
//  Created by Andrew McKnight on 7/9/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import Foundation

public struct PlistFile {

    public let path: String

}

extension PlistFile: File {

    public func getPath() -> String {
        return path
    }

    public static func defaultKeyForVersionType(_ type: VersionType) -> String {
        switch(type) {
        case .Numeric:
            return "CFBundleVersion"
        case .Semantic:
            return "CFBundleShortVersionString"
        }
    }

    public func defaultKeyForVersionType(_ type: VersionType) -> String {
        return PlistFile.defaultKeyForVersionType(type)
    }

    public func versionStringForKey(_ key: String?, versionType: VersionType) -> String? {
        guard let data = NSDictionary(contentsOfFile: self.path) else {
            return nil
        }

        if key == nil {
            return data[defaultKeyForVersionType(versionType)] as? String
        } else {
            return data[key!] as? String
        }
    }

    public func replaceVersionString<V>(_ original: V, new: V, key: String?) throws where V: Version {
        guard let dictionary = NSDictionary(contentsOfFile: self.path) else {
            throw NSError(domain: errorDomain, code: Int(ErrorCode.couldNotReadFile.rawValue), userInfo: [ NSLocalizedDescriptionKey: "Failed to read current state of file for updating." ])
        }

        if key == nil {
            dictionary.setValue(new.description, forKey: defaultKeyForVersionType(new.type))
        } else {
            dictionary.setValue(new.description, forKey: key!)
        }

        if !dictionary.write(toFile: self.path, atomically: true) {
            throw NSError(domain: errorDomain, code: Int(ErrorCode.unwritableFile.rawValue), userInfo: [ NSLocalizedDescriptionKey: "Failed to write updated version to file" ])
        }
    }

}
