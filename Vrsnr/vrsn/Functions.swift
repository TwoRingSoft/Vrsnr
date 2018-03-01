//
//  Functions.swift
//  Vrsnr
//
//  Created by Andrew McKnight on 6/27/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import Foundation

extension String {
    func padLeftToWidth(_ width: Int) -> String {
        if self.count < width {
            return String(repeating: " ", count: width - self.count) + self
        } else {
            return self
        }
    }
}

func printUsage() {
    print("usage: vrsn COMPONENT FLAGS [OPTIONS]")

    print("\nCOMPONENT")
    print("\n\tThe semantic version component to revision. Either “major”, “minor” or “patch”.")

    print("\nFLAGS")
    print("\n\t-\(VrsnrFlags.file.short), --\(VrsnrFlags.file.long) <path>")
    print("\t\tPath to the file that contains the version data.")

    print("\nOPTIONS")
    print("\t-\(VrsnrFlags.key.short), --\(VrsnrFlags.key.long) <key>")
    print("\t\tThe key that the version info is mapped to. Each file type has a default value that is used for each version type if this option is omitted:")


    let columnWidth = 30
    var versionTypeHeaders = "\(String(repeating: " ", count: columnWidth))"
    for versionType in VersionType.allVersionTypes() {
        versionTypeHeaders.append("\(versionType.rawValue.padLeftToWidth(columnWidth))")
    }
    print("\(versionTypeHeaders)")
    print("\(String(repeating: " ", count: columnWidth))\(String(repeating: "=", count: (VersionType.allVersionTypes().count) * columnWidth))")

    for fileType in FileType.allFileTypes() {
        var string = fileType.extensionString().padLeftToWidth(columnWidth)
        for versionType in VersionType.allVersionTypes() {
            string.append(fileType.defaultKey(versionType).padLeftToWidth(columnWidth))
        }
        print("\(string)")
    }

    print("\t-\(VrsnrFlags.readFromFile.short), --\(VrsnrFlags.readFromFile.short)")
    print("\t\tRead the version from the file and print it. Ignores 'major', 'minor', 'patch', and --numeric, as well as --try option.")
    print("\t-\(VersionSuffix.prereleaseIdentifier.short), --\(VersionSuffix.prereleaseIdentifier.long)")
    print("\t\tAdd a prerelease identifier. See http://semver.org/#spec-item-9 for more on prerelease identifiers.")
    print("\t-\(VersionSuffix.buildMetadata.short), --\(VersionSuffix.buildMetadata.long)")
    print("\t\tAdd build metadata string. See http://semver.org/#spec-item-10 for more on build metadata.")
    print("\t-\(VrsnrFlags.numeric.short), --\(VrsnrFlags.numeric.long)")
    print("\t\tTreat the version as a single integer when revisioning. COMPONENT is ignored")
    print("\t-\(Flag.dryRun.short), --\(Flag.dryRun.long)")
    print("\t\tInstead of modifying the specified file, only output the new version that is computed from the provided options.")
    print("\t-\(VrsnrFlags.currentVersion.short), --\(VrsnrFlags.currentVersion.long)")
    print("\t\tThe current version of the project, from which the new version will be computed. Any preexisting value in --file for --key will be ignored.")

    print("\n\t-\(Flag.usage.short), --\(Flag.usage.long)")
    print("\t\tPrint this usage information.")
    print("\t-\(Flag.version.short), --\(Flag.version.long)")
    print("\t\tPrint version information for this application.")

    print("\n\nFor questions or suggestions, email two.ring.soft+vrsnr@gmail.com or visit https://github.com/TwoRingSoft/Vrsnr.")

    print()
    printVersion()
}

func getRevType() -> VersionBumpOptions {
    var revType: VersionBumpOptions
    if Arguments.contains(SemanticVersionRevision.major.name) {
        revType = SemanticVersionRevision.major.rawValue
    } else if Arguments.contains(SemanticVersionRevision.minor.name) {
        revType = SemanticVersionRevision.minor.rawValue
    } else if Arguments.contains(SemanticVersionRevision.patch.name) {
        revType = SemanticVersionRevision.patch.rawValue
    } else {
        print("")
        exit(ErrorCode.missingFlag.rawValue)
    }
    return revType
}

func printVersion() {
    print("vrsn \(VrsnrVersions.displayVersion()) build \(VrsnrVersions.buildVersion())")
}

func getVersionType() -> VersionType {
    if Arguments.contains(VrsnrFlags.numeric) {
        return .Numeric
    } else {
        return .Semantic
    }
}

func checkForHelp() {
    // see if user wants usage printed by providing -h/--help
    if Arguments.contains(Flag.usage) {
        printUsage()
        exit(ErrorCode.normal.rawValue)
    }
}

func checkForVersion() {
    // see if user wants usage printed by providing -v/--version
    if Arguments.contains(Flag.version) {
        printVersion()
        exit(ErrorCode.normal.rawValue)
    }
}

func checkForDebugMode() {
    if Arguments.contains(Flag.debug) {
        printVersion()
        print("\nArguments:")
        print("debug mode enabled")
    }
}

func isRead() -> Bool {
    return Arguments.contains(VrsnrFlags.readFromFile)
}

func isDryRun() -> Bool {
    return Arguments.contains(Flag.dryRun)
}
