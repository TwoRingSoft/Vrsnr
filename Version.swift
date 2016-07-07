//
//  Version.swift
//  SemVer
//
//  Created by Andrew McKnight on 7/5/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import Foundation

public typealias VersionBumpOptions = UInt8

public enum VersionSuffix: UInt8 {

    case BuildMetadata
    case PrereleaseIdentifier

    public var long: String {
        switch self {
        case .BuildMetadata:
            return "metadata"
        case .PrereleaseIdentifier:
            return "identifier"
        }
    }

    public var short: String {
        switch self {
        case .BuildMetadata:
            return "m"
        case .PrereleaseIdentifier:
            return "i"
        }
    }
    
}

public protocol Version: CustomStringConvertible {

    associatedtype T

    /// Return a new version representing the next version after this one, according to any options passed in
    func nextVersion(options: VersionBumpOptions, prereleaseIdentifier: String?, buildMetadata: String?) -> T

    /// Commonly used keys used by different toolchains, e.g. `CURRENT_PROJECT_VERSION` for .xcconfigs or `CFBundleShortVersionString` for .plists
    func commonKeys() -> [String]

    /// Try to parse a version from a String, or throw an error describing why it can't be done.
    static func parseFromString(file: File, string: String) throws -> T

}
