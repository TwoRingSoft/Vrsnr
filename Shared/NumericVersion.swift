//
//  NumericVersion.swift
//  SemVer
//
//  Created by Andrew McKnight on 6/29/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import Foundation

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

    public func nextVersion(options: VersionBumpOptions, prereleaseIdentifier: String?, buildMetadata: String?) -> NumericVersion {
        return NumericVersion(version: self.version + 1, prereleaseIdentifier: prereleaseIdentifier, buildMetadata: buildMetadata)
    }

    public static func parseFromString(string: String) throws -> NumericVersion {
        if string == "$(DYLIB_CURRENT_VERSION)" {
            throw NSError(domain: errorDomain, code: ErrorCode.DynamicVersionFound.valueAsInt(), userInfo: [NSLocalizedDescriptionKey:"Dynamic value found: \(string). Rerun this script pointed at the file that defines DYLIB_CURRENT_VERSION."])
        } else if string == "" {
            throw NSError(domain: errorDomain, code: ErrorCode.MalformedVersionValue.valueAsInt(), userInfo: [NSLocalizedDescriptionKey: "Key was found but definition is blank."])
        }

        let definitionComponents = string.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "-+"))
        if definitionComponents.count < 1 || definitionComponents.count > 3 {
            throw NSError(domain: errorDomain, code: ErrorCode.MalformedVersionValue.valueAsInt(), userInfo: [NSLocalizedDescriptionKey: "Malformed definition (“\(string)”). Expecting <build-umber>[-<prereleaseID>[+<metadata>]]. <build-number> may only contain numberals, and neither <prereleaseID> nor <metadata> may contain '-' or '+' characters."])
        }

        let numberFormatter = NSNumberFormatter()
        guard let versionNumber = numberFormatter.numberFromString(definitionComponents[0]) else {
            throw NSError(domain: errorDomain, code: ErrorCode.NSNumberFormatterCouldNotParse.valueAsInt(), userInfo: [NSLocalizedDescriptionKey: "Could not parse number from string."])
        }

        let suffixes = getPrereleaseIdentifierAndBuildMetadata(string)

        return NumericVersion(version: versionNumber.unsignedIntegerValue, prereleaseIdentifier: suffixes.prereleaseIdentifier, buildMetadata: suffixes.buildMetadata)
    }
    
}

extension NumericVersion: CustomStringConvertible {

    public var description: String {
        var string = "\(version)"
        if let prereleaseID = prereleaseIdentifier {
            string.appendContentsOf("-\(prereleaseID)")
        }
        if let metadata = buildMetadata {
            string.appendContentsOf("+\(metadata)")
        }
        return string
    }

}
