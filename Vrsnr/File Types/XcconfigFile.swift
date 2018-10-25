//
//  XcconfigFile.swift
//  Vrsnr
//
//  Created by Andrew McKnight on 7/9/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import Foundation

public struct XcconfigFile {
    public let path: String
}

extension XcconfigFile: File {

    public func getPath() -> String {
        return path
    }

    public static func defaultKeyForVersionType(_ type: VersionType) -> String {
        switch(type) {
        case .Numeric:
            return "DYLIB_CURRENT_VERSION"
        case .Semantic:
            return "CURRENT_PROJECT_VERSION"
        }
    }

    public func defaultKeyForVersionType(_ type: VersionType) -> String {
        return XcconfigFile.defaultKeyForVersionType(type)
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

extension XcconfigFile: TextFile {

    public static func versionStringFromLine(_ line: String) throws -> String {
        let assignentExpressionComponents = line.components(separatedBy: "=")
        if assignentExpressionComponents.count != 2 {
            throw NSError(domain: errorDomain, code: Int(ErrorCode.couldNotParseVersion.rawValue), userInfo: [ NSLocalizedDescriptionKey: "Could not find an assignment using ‘=’: \(line)" ])
        }

        return assignentExpressionComponents.last! // take right-hand side from assignment expression
            .components(separatedBy: "//").first! // strip away any comments
            .trimmingCharacters(in: CharacterSet.whitespaces) // trim whitespace
    }

}

extension XcconfigFile {

    fileprivate func chooseWorkingKey(_ key: String?, versionType: VersionType) -> String {
        if key == nil {
            return defaultKeyForVersionType(versionType)
        } else {
            return key!
        }
    }

}
