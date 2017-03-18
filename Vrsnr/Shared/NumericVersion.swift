//
//  NumericVersion.swift
//  Vrsnr
//
//  Created by Andrew McKnight on 6/29/16.
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


public struct NumericVersion {

    let version: UInt
    let prereleaseIdentifier: String?
    let buildMetadata: String?

    public init(version: UInt, prereleaseIdentifier: String? = nil, buildMetadata: String? = nil) {
        self.version = version
        self.prereleaseIdentifier = prereleaseIdentifier
        self.buildMetadata = buildMetadata
    }

}

extension NumericVersion: Version {

    public static var statictype: VersionType {
        get {
            return .Numeric
        }
    }

    public var type: VersionType {
        get {
            return .Numeric
        }
    }

    public func nextVersion(_ options: VersionBumpOptions, prereleaseIdentifier: String?, buildMetadata: String?) -> NumericVersion {
        return NumericVersion(version: self.version + 1, prereleaseIdentifier: prereleaseIdentifier, buildMetadata: buildMetadata)
    }

    public static func parseFromString(_ string: String) throws -> NumericVersion {
        if string == "$(DYLIB_CURRENT_VERSION)" {
            throw NSError(domain: errorDomain, code: ErrorCode.dynamicVersionFound.valueAsInt(), userInfo: [NSLocalizedDescriptionKey:"Dynamic value found: \(string). Rerun this script pointed at the file that defines DYLIB_CURRENT_VERSION."])
        } else if string == "" {
            throw NSError(domain: errorDomain, code: ErrorCode.malformedVersionValue.valueAsInt(), userInfo: [NSLocalizedDescriptionKey: "Key was found but definition is blank."])
        }

        let definitionComponents = string.components(separatedBy: CharacterSet(charactersIn: "-+"))
        if definitionComponents.count < 1 || definitionComponents.count > 3 {
            throw NSError(domain: errorDomain, code: ErrorCode.malformedVersionValue.valueAsInt(), userInfo: [NSLocalizedDescriptionKey: "Malformed definition (“\(string)”). Expecting <build-umber>[-<prereleaseID>[+<metadata>]]. <build-number> may only contain numberals, and neither <prereleaseID> nor <metadata> may contain '-' or '+' characters."])
        }

        let numberFormatter = NumberFormatter()
        guard let versionNumber = numberFormatter.number(from: definitionComponents[0]) else {
            throw NSError(domain: errorDomain, code: ErrorCode.nsNumberFormatterCouldNotParse.valueAsInt(), userInfo: [NSLocalizedDescriptionKey: "Could not parse number from string."])
        }

        let suffixes = getPrereleaseIdentifierAndBuildMetadata(string)

        return NumericVersion(version: versionNumber.uintValue, prereleaseIdentifier: suffixes.prereleaseIdentifier, buildMetadata: suffixes.buildMetadata)
    }
    
}

extension NumericVersion: Comparable {}

public func <(lhs: NumericVersion, rhs: NumericVersion) -> Bool {
    return lhs.version < rhs.version && lhs.prereleaseIdentifier < rhs.prereleaseIdentifier && lhs.buildMetadata < rhs.buildMetadata
}

extension NumericVersion: Equatable {}

public func ==(lhs: NumericVersion, rhs: NumericVersion) -> Bool {
    return lhs.version == rhs.version && lhs.prereleaseIdentifier == rhs.prereleaseIdentifier && lhs.buildMetadata == rhs.buildMetadata
}

extension NumericVersion: CustomStringConvertible {

    public var description: String {
        var string = "\(version)"
        if let prereleaseID = prereleaseIdentifier {
            string.append("-\(prereleaseID)")
        }
        if let metadata = buildMetadata {
            string.append("+\(metadata)")
        }
        return string
    }

}
