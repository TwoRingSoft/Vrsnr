//
//  HomebrewSpec.swift
//  vrsn
//
//  Created by Andrew Mcknight on 9/23/20.
//  Copyright © 2020 Two Ring Software. All rights reserved.
//

import Foundation

public struct HomebrewSpec {

    public let path: String

}

extension HomebrewSpec: File {

    public func getPath() -> String {
        return path
    }

    public static func defaultKeyForVersionType(_ type: VersionType) -> String {
        switch(type) {
        case .Numeric, .Semantic:
            return "version"
        }
    }

    public func defaultKeyForVersionType(_ type: VersionType) -> String {
        return HomebrewSpec.defaultKeyForVersionType(type)
    }

    public func versionStringForKey(_ key: String?, versionType: VersionType) throws -> String? {
        let workingKey = chooseWorkingKey(key, versionType: versionType)
        return try extractVersionStringFromTextFile(self, versionType: versionType, key: workingKey)
    }

    public func replaceVersionString<V>(_ original: V, new: V, key: String?) throws where V: Version {
        let workingKey = chooseWorkingKey(key, versionType: new.type)
        try replaceVersionStringInTextFile(self, originalVersion: original, newVersion: new, versionOverride: key == nil, key: workingKey)
    }

}

extension HomebrewSpec: TextFile {
    public static func versionStringFromLine(_ line: String) throws -> String {
        return try NSRegularExpression(pattern: "version [\"'](.*)[\"']", options: .init(rawValue: 0)).stringByReplacingMatches(in: line, options: .init(rawValue: 0), range: NSMakeRange(0, line.count), withTemplate: "$1")
    }
}

extension HomebrewSpec {

    fileprivate func chooseWorkingKey(_ key: String?, versionType: VersionType) -> String {
        if key == nil {
            return defaultKeyForVersionType(versionType)
        } else {
            return key!
        }
    }

}
