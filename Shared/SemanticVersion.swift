//
//  SemanticVersion.swift
//  SemVer
//
//  Created by Andrew McKnight on 6/28/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import Foundation

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

public enum SemverRevision {

    case Major
    case Minor
    case Patch

    public var name: String {
        switch self {
        case .Major:
            return "major"
        case .Minor:
            return "minor"
        case .Patch:
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

    public init(originalVersion: SemanticVersion, incrementing revisionComponent: SemverRevision, buildMetadata: String? = nil, prereleaseIdentifier: String? = nil) {
        major = originalVersion.major + (revisionComponent == SemverRevision.Major ? 1 : 0)
        minor = originalVersion.minor + (revisionComponent == SemverRevision.Minor ? 1 : 0)
        patch = originalVersion.patch + (revisionComponent == SemverRevision.Patch ? 1 : 0)

        if buildMetadata == nil {
            self.buildMetadata = originalVersion.buildMetadata
        } else {
            self.buildMetadata = buildMetadata
        }

        if prereleaseIdentifier == nil {
            self.prereleaseIdentifier = originalVersion.prereleaseIdentifier
        } else {
            self.prereleaseIdentifier = prereleaseIdentifier
        }
    }

}

extension SemanticVersion {

    public static func parseFromString(string: String) throws -> SemanticVersion {

        if string == "$(CURRENT_PROJECT_VERSION)" {
            throw NSError(domain: errorDomain, code: Int(ExitCode.DynamicVersionFound.rawValue), userInfo: [NSLocalizedDescriptionKey: "Dynamic value found in \(file). Rerun this script pointed at the file that defines CURRENT_PROJECT_VERSION, with the appropriate --key."])
        }

        let definitionComponents = string.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "-+"))
        if definitionComponents.count < 1 || definitionComponents.count > 3 {
            throw NSError(domain: errorDomain, code: ExitCode.MalformedVersionValue.valueAsInt(), userInfo: [NSLocalizedDescriptionKey: "Malformed definition (“\(string)”). Expecting M.m.p[-<prereleaseID>[+<metadata>]]. M, m and p may only contain numerals, and neither <prereleaseID> nor <metadata> may  contain '-' or '+' characters."])
        }

        let versionComponents = definitionComponents[0].componentsSeparatedByString(".")
        if versionComponents.count != 3 {
            throw NSError(domain: errorDomain, code: Int(ExitCode.MalformedVersionValue.rawValue), userInfo: [NSLocalizedDescriptionKey: "Malformed definition (“\(string)”). Expecting M.m.p[-<prereleaseID>[+<metadata>]]. <prereleaseID> and <metadata> may not contain '-' or '+' characters."])
        }

        let numberFormatter = NSNumberFormatter()

        guard
            let major = numberFormatter.numberFromString(versionComponents[0])?.unsignedIntegerValue,
            let minor = numberFormatter.numberFromString(versionComponents[1])?.unsignedIntegerValue,
            let patch = numberFormatter.numberFromString(versionComponents[2])?.unsignedIntegerValue
            else {
                throw NSError(domain: errorDomain, code: ExitCode.NSNumberFormatterCouldNotParse.valueAsInt(), userInfo: [NSLocalizedDescriptionKey: "Could not parse number from string."])
        }

        let suffixes = getPrereleaseIdentifierAndBuildMetadata(string)

        return SemanticVersion(major: major, minor: minor, patch: patch, buildMetadata: suffixes.buildMetadata, prereleaseIdentifier: suffixes.prereleaseIdentifier)
    }

}

extension SemanticVersion: CustomStringConvertible {

    public var description: String {
        var string = "\(major).\(minor).\(patch)"
        if let prereleaseID = self.prereleaseIdentifier {
            string.appendContentsOf("-\(prereleaseID)")
        }
        if let metadata = self.buildMetadata {
            string.appendContentsOf("+\(metadata)")
        }
        return string
    }
    
}
