//
//  Version.swift
//  SemVer
//
//  Created by Andrew McKnight on 7/5/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import Foundation

public typealias VersionBumpOptions = UInt8

public enum VersionType: String {

    case Numeric
    case Semantic

    public static func allVersionTypes() -> [VersionType] {
        return [
            VersionType.Numeric,
            VersionType.Semantic
        ]
    }

    public func parseFromString<V>(_ string: String) throws -> V where V: Version {
        return try V.parseFromString(string)
    }
    
}

public enum VersionSuffix: UInt8, CommandLineOption {

    case buildMetadata
    case prereleaseIdentifier

    public var long: String {
        switch self {
        case .buildMetadata:
            return "metadata"
        case .prereleaseIdentifier:
            return "identifier"
        }
    }

    public var short: String {
        switch self {
        case .buildMetadata:
            return "m"
        case .prereleaseIdentifier:
            return "i"
        }
    }
    
}

public protocol Version: CustomStringConvertible, Comparable {

    static var statictype: VersionType { get }
    var type: VersionType { get }

    /// Return a new version representing the next version after this one, according to any options passed in
    func nextVersion(_ options: VersionBumpOptions, prereleaseIdentifier: String?, buildMetadata: String?) -> Self

    /// Try to parse a version from a String, or throw an error describing why it can't be done.
    static func parseFromString(_ string: String) throws -> Self

}

func getPrereleaseIdentifierAndBuildMetadata(_ string: String) -> (prereleaseIdentifier: String?, buildMetadata: String?) {
    var metadata: String?
    var prereleaseID: String?

    var remainingString = string
    if string.contains("+") {
        let components = string.components(separatedBy: "+")
        metadata = components.last
        remainingString = components.first!
    }

    if remainingString.contains("-") {
        let firstHyphenIdx = remainingString.range(of: "-")!
        prereleaseID = remainingString.substring(from: firstHyphenIdx.lowerBound)
    }


    return (prereleaseID, metadata)
}
