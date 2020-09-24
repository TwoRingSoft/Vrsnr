//
//  CLIDefinitions.swift
//  Vrsnr
//
//  Created by Andrew McKnight on 6/27/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
// 

import AppKit
import Foundation

enum Flag: CommandLineOption, CaseIterable {
    case usage
    case version
    case debug
    case dryRun
    case key
    case file
    case numeric
    case currentVersion
    case readFromFile
    case buildMetadata
    case prereleaseIdentifier
    case custom

    var optional: Bool {
        switch self {
        case .usage: return true
        case .version: return true
        case .debug: return true
        case .dryRun: return true
        case .key: return true
        case .file: return false
        case .numeric: return true
        case .currentVersion: return true
        case .readFromFile: return true
        case .buildMetadata: return true
        case .prereleaseIdentifier: return true
        case .custom: return true
        }
    }

    var short: String {
        switch self {
        case .usage: return "h"
        case .version: return "v"
        case .debug: return "d"
        case .dryRun: return "t"
        case .key: return "k"
        case .file: return "f"
        case .numeric: return "n"
        case .currentVersion: return "c"
        case .readFromFile: return "r"
        case .buildMetadata: return "m"
        case .prereleaseIdentifier: return "i"
        case .custom: return "u"
        }
    }

    var long: String {
        switch self {
        case .usage: return "help"
        case .version: return "version"
        case .debug: return "debug"
        case .dryRun: return "try"
        case .key: return "key"
        case .file: return "file"
        case .numeric: return "numeric"
        case .currentVersion: return "current-version"
        case .readFromFile: return "read"
        case .buildMetadata: return "metadata"
        case .prereleaseIdentifier: return "identifier"
        case .custom: return "custom"
        }
    }

    var help: String {
        switch self {
        case .usage: return "Print this usage information."
        case .version: return "Print version information for this application."
        case .debug: return "Output verbose logging."
        case .dryRun: return "Instead of modifying the specified file, only output the new version that is computed from the provided options."
        case .key:
            var str = "The key that the version info is mapped to. Each file type has a default value that is used for each version type if this option is omitted:\n\n"
            let columnWidth = 30
            var versionTypeHeaders = "\(String(repeating: " ", count: columnWidth))"
            for versionType in VersionType.allVersionTypes() {
                versionTypeHeaders.append("\(versionType.rawValue.padLeftToWidth(columnWidth))")
            }
            str.append(versionTypeHeaders)
            str.append("\n")
            str.append("\(String(repeating: " ", count: columnWidth))\(String(repeating: "=", count: (VersionType.allVersionTypes().count) * columnWidth))")

            for fileType in FileType.allFileTypes() {
                var string = fileType.extensionString().padLeftToWidth(columnWidth)
                for versionType in VersionType.allVersionTypes() {
                    string.append(fileType.defaultKey(versionType).padLeftToWidth(columnWidth))
                }
                str.append("\n\(string)")
            }
            return str
        case .file: return "Path to the file that contains the version data."
        case .numeric: return "Treat the version as a single integer when revisioning. COMPONENT is ignored."
        case .currentVersion: return "The current version of the project, from which the new version will be computed. Any preexisting value in --file for --key will be ignored."
        case .readFromFile: return "Read the version from the file and print it. Ignores 'major', 'minor', 'patch', and --numeric, as well as --try option."
        case .buildMetadata: return "Add build metadata string. See http://semver.org/#spec-item-10 for more on build metadata."
        case .prereleaseIdentifier: return "Add a prerelease identifier. See http://semver.org/#spec-item-9 for more on prerelease identifiers."
        case .custom: return "Provide a version to write into the semantic (or build number for --numeric) without modification by any versioning math."
        }
    }
}
