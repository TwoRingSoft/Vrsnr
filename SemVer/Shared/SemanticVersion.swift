//
//  SemanticVersion.swift
//  SemVer
//
//  Created by Andrew McKnight on 6/28/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


public typealias SemverBumpOptions = VersionBumpOptions

public enum SemverRevision: SemverBumpOptions {

    case major
    case minor
    case patch

    public var name: String {
        switch self {
        case .major:
            return "major"
        case .minor:
            return "minor"
        case .patch:
            return "patch"
        }
    }

}

public struct SemanticVersion {

    let major: UInt
    let minor: UInt
    let patch: UInt

    let buildMetadata: String?
    let prereleaseIdentifier: String?

    public init(major: UInt, minor: UInt, patch: UInt, buildMetadata: String?, prereleaseIdentifier: String?) {
        self.major = major
        self.minor = minor
        self.patch = patch
        self.buildMetadata = buildMetadata
        self.prereleaseIdentifier = prereleaseIdentifier
    }

}

extension SemanticVersion: Equatable {}

public func ==(lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
    return lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch == rhs.patch && lhs.buildMetadata == rhs.buildMetadata && lhs.prereleaseIdentifier == rhs.prereleaseIdentifier
}

extension SemanticVersion: Comparable {}

public func <(lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
    return lhs.major < rhs.major && lhs.minor < rhs.minor && lhs.patch < rhs.patch && lhs.prereleaseIdentifier < rhs.buildMetadata && lhs.buildMetadata < rhs.buildMetadata
}

extension SemanticVersion: Version {

    public static var statictype: VersionType {
        get {
            return .Semantic
        }
    }

    public var type: VersionType {
        get {
            return .Semantic
        }
    }

    public func nextVersion(_ options: VersionBumpOptions, prereleaseIdentifier: String?, buildMetadata: String?) -> SemanticVersion {
        let major = self.major + (options == SemverRevision.major.rawValue ? 1 : 0)
        let minor = self.minor + (options == SemverRevision.minor.rawValue ? 1 : 0)
        let patch = self.patch + (options == SemverRevision.patch.rawValue ? 1 : 0)
        return SemanticVersion(major: major, minor: minor, patch: patch, buildMetadata: buildMetadata, prereleaseIdentifier: prereleaseIdentifier)
    }

    public static func parseFromString(_ string: String) throws -> SemanticVersion {
        if string == "$(CURRENT_PROJECT_VERSION)" {
            throw NSError(domain: errorDomain, code: Int(ErrorCode.dynamicVersionFound.rawValue), userInfo: [NSLocalizedDescriptionKey: "Dynamic value found: \(string). Rerun this script pointed at the file that defines CURRENT_PROJECT_VERSION, with the appropriate --key."])
        }

        let definitionComponents = string.components(separatedBy: CharacterSet(charactersIn: "-+"))
        if definitionComponents.count < 1 || definitionComponents.count > 3 {
            throw NSError(domain: errorDomain, code: ErrorCode.malformedVersionValue.valueAsInt(), userInfo: [NSLocalizedDescriptionKey: "Malformed definition (“\(string)”). Expecting M.m.p[-<prereleaseID>[+<metadata>]]. M, m and p may only contain numerals, and neither <prereleaseID> nor <metadata> may  contain '-' or '+' characters."])
        }

        let versionComponents = definitionComponents[0].components(separatedBy: ".")
        if versionComponents.count != 3 {
            throw NSError(domain: errorDomain, code: Int(ErrorCode.malformedVersionValue.rawValue), userInfo: [NSLocalizedDescriptionKey: "Malformed definition (“\(string)”). Expecting M.m.p[-<prereleaseID>[+<metadata>]]. <prereleaseID> and <metadata> may not contain '-' or '+' characters."])
        }

        let numberFormatter = NumberFormatter()

        guard
            let major = numberFormatter.number(from: versionComponents[0])?.uintValue,
            let minor = numberFormatter.number(from: versionComponents[1])?.uintValue,
            let patch = numberFormatter.number(from: versionComponents[2])?.uintValue
            else {
                throw NSError(domain: errorDomain, code: ErrorCode.nsNumberFormatterCouldNotParse.valueAsInt(), userInfo: [NSLocalizedDescriptionKey: "Could not parse number from string."])
        }

        let suffixes = getPrereleaseIdentifierAndBuildMetadata(string)

        return SemanticVersion(major: major, minor: minor, patch: patch, buildMetadata: suffixes.buildMetadata, prereleaseIdentifier: suffixes.prereleaseIdentifier)
    }

}

extension SemanticVersion: CustomStringConvertible {

    public var description: String {
        var string = "\(major).\(minor).\(patch)"
        if let prereleaseID = self.prereleaseIdentifier {
            string.append("-\(prereleaseID)")
        }
        if let metadata = self.buildMetadata {
            string.append("+\(metadata)")
        }
        return string
    }
    
}
