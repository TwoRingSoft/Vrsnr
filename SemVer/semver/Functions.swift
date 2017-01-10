//
//  Functions.swift
//  SemVer
//
//  Created by Andrew McKnight on 6/27/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import Foundation

extension String {
    func padLeftToWidth(width: Int) -> String {
        if self.characters.count < width {
            return String(count: width - self.characters.count, repeatedValue: Character(" ")).stringByAppendingString(self)
        } else {
            return self
        }
    }
}

func printUsage() {
    print("usage: semver COMPONENT FLAGS [OPTIONS]")

    print("\nCOMPONENT")
    print("\n\tThe semantic version component to revision. Either “major”, “minor” or “patch”.")

    print("\nFLAGS")
    print("\n\t-\(SemVerFlags.File.short), --\(SemVerFlags.File.long) <path>")
    print("\t\tPath to the file that contains the version data.")

    print("\nOPTIONS")
    print("\t-\(SemVerFlags.Key.short), --\(SemVerFlags.Key.long) <key>")
    print("\t\tThe key that the version info is mapped to. Each file type has a default value that is used for each version type if this option is omitted:")


    let columnWidth = 30
    var versionTypeHeaders = "\(String(count: columnWidth, repeatedValue: Character(" ")))"
    for versionType in VersionType.allVersionTypes() {
        versionTypeHeaders.appendContentsOf("\(versionType.rawValue.padLeftToWidth(columnWidth))")
    }
    print("\(versionTypeHeaders)")
    print("\(String(count: columnWidth, repeatedValue: Character(" ")))\(String(count: (VersionType.allVersionTypes().count) * columnWidth, repeatedValue: Character("=")))")

    for fileType in FileType.allFileTypes() {
        var string = fileType.extensionString().padLeftToWidth(columnWidth)
        for versionType in VersionType.allVersionTypes() {
            string.appendContentsOf(fileType.defaultKey(versionType).padLeftToWidth(columnWidth))
        }
        print("\(string)")
    }

    print("\t-\(SemVerFlags.ReadFromFile.short), --\(SemVerFlags.ReadFromFile.short)")
    print("\t\tRead the version from the file and print it. Ignores 'major', 'minor', 'patch', and --numeric, as well as --try option.")
    print("\t-\(VersionSuffix.PrereleaseIdentifier.short), --\(VersionSuffix.PrereleaseIdentifier.long)")
    print("\t\tAdd a prerelease identifier. See http://semver.org/#spec-item-9 for more on prerelease identifiers.")
    print("\t-\(VersionSuffix.BuildMetadata.short), --\(VersionSuffix.BuildMetadata.long)")
    print("\t\tAdd build metadata string. See http://semver.org/#spec-item-10 for more on build metadata.")
    print("\t-\(SemVerFlags.Numeric.short), --\(SemVerFlags.Numeric.long)")
    print("\t\tTreat the version as a single integer when revisioning. COMPONENT is ignored")
    print("\t-\(Flag.DryRun.short), --\(Flag.DryRun.long)")
    print("\t\tInstead of modifying the specified file, only output the new version that is computed from the provided options.")
    print("\t-\(SemVerFlags.CurrentVersion.short), --\(SemVerFlags.CurrentVersion.long)")
    print("\t\tThe current version of the project, from which the new version will be computed. Any preexisting value in --file for --key will be ignored.")

    print("\n\t-\(Flag.Usage.short), --\(Flag.Usage.long)")
    print("\t\tPrint this usage information.")
    print("\t-\(Flag.Version.short), --\(Flag.Version.long)")
    print("\t\tPrint version information for this application.")

    print("\n\nFor questions or suggestions, email two.ring.soft+semver@gmail.com or visit https://github.com/TwoRingSoft/semver.")

    print()
    printVersion()
}

func getRevType() -> VersionBumpOptions {
    var revType: VersionBumpOptions
    if Arguments.contains(SemverRevision.Major.name) {
        revType = SemverRevision.Major.rawValue
    } else if Arguments.contains(SemverRevision.Minor.name) {
        revType = SemverRevision.Minor.rawValue
    } else if Arguments.contains(SemverRevision.Patch.name) {
        revType = SemverRevision.Patch.rawValue
    } else {
        print("")
        exit(ErrorCode.MissingFlag.rawValue)
    }
    return revType
}

func printVersion() {
    print("semver \(SemVerVersions.displayVersion()) build \(SemVerVersions.buildVersion())")
}

func getVersionType() -> VersionType {
    if Arguments.contains(SemVerFlags.Numeric) {
        return .Numeric
    } else {
        return .Semantic
    }
}

func checkForHelp() {
    // see if user wants usage printed by providing -h/--help
    if Arguments.contains(Flag.Usage) {
        printUsage()
        exit(ErrorCode.Normal.rawValue)
    }
}

func checkForVersion() {
    // see if user wants usage printed by providing -v/--version
    if Arguments.contains(Flag.Version) {
        printVersion()
        exit(ErrorCode.Normal.rawValue)
    }
}

func checkForDebugMode() {
    if Arguments.contains(Flag.Debug) {
        printVersion()
        print("\nArguments:")
        print("debug mode enabled")
    }
}

func isRead() -> Bool {
    return Arguments.contains(SemVerFlags.ReadFromFile)
}

func isDryRun() -> Bool {
    return Arguments.contains(Flag.DryRun)
}
