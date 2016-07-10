//
//  Version.swift
//  SemVer
//
//  Created by Andrew McKnight on 7/5/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import Foundation

public typealias VersionBumpOptions = UInt8

public enum VersionType {

    case Numeric
    case Semantic
    
}

public enum VersionSuffix: UInt8, CommandLineOption {

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

    static var statictype: VersionType { get }
    var type: VersionType { get }

    /// Return a new version representing the next version after this one, according to any options passed in
    func nextVersion(options: VersionBumpOptions, prereleaseIdentifier: String?, buildMetadata: String?) -> Self

    /// Try to parse a version from a String, or throw an error describing why it can't be done.
    static func parseFromString(string: String) throws -> Self

}

func getPrereleaseIdentifierAndBuildMetadata(string: String) -> (prereleaseIdentifier: String?, buildMetadata: String?) {
    var metadata: String?
    var prereleaseID: String?

    var remainingString = string
    if string.containsString("+") {
        let components = string.componentsSeparatedByString("+")
        metadata = components.last
        remainingString = components.first!
    }

    if remainingString.containsString("-") {
        let firstHyphenIdx = remainingString.rangeOfString("-")!
        prereleaseID = remainingString.substringFromIndex(firstHyphenIdx.startIndex.advancedBy(1))
    }


    return (prereleaseID, metadata)
}
