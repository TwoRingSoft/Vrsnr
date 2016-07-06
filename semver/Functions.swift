//
//  Functions.swift
//  SemVer
//
//  Created by Andrew McKnight on 6/27/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import Foundation

func printUsage() {
    print("usage: semver COMPONENT FLAGS [OPTIONS]".s.Bold)

    print("\nCOMPONENT".s.Bold)
    print("\n\tThe semantic version component to revision. Either “major”, “minor” or “patch”.")

    print("\nFLAGS".s.Bold)
    print("\n\t-\(SemVerFlags.File.short), --\(SemVerFlags.File.long) <path>")
    print("\t\tPath to the file that contains the version data.")
    print("\t-\(SemVerFlags.Key.short), --\(SemVerFlags.Key.long) <key>")
    print("\t\tThe key that the version info is mapped to.")

    print("\nOPTIONS".s.Bold)
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

    print("\n\nFor questions or suggestions, email two.ring.soft+semver@gmail.com or visit https://github.com/TwoRingSoft/semver.".s.Bold)

    print()
    printVersion()
}

func getVersionSuffix(type: VersionSuffix) -> String? {
    var value = Args.parsed.flags[type.long]
    if value == nil {
        value = Args.parsed.flags[type.short]
    }
    return value
}

func getRevType() -> VersionBumpOptions {
    var revType: VersionBumpOptions
    if Args.parsed.parameters.contains(SemverRevision.Major.name) {
        revType = SemverRevision.Major.rawValue
    } else if Args.parsed.parameters.contains(SemverRevision.Minor.name) {
        revType = SemverRevision.Minor.rawValue
    } else if Args.parsed.parameters.contains(SemverRevision.Patch.name) {
        revType = SemverRevision.Patch.rawValue
    } else {
        printUsage()
        exit(ExitCode.MissingFlag.rawValue)
    }
    return revType
}

func getValue(flag: SemVerFlags) -> String {
    var optional = Args.parsed.flags[flag.long]
    if optional == nil {
        optional = Args.parsed.flags[flag.short]
    }
    guard let value = optional else {
        printUsage()
        exit(ExitCode.MissingFlag.rawValue)
    }
    return value
}

func printVersion() {
    print("semver \(SemVerVersions.displayVersion()) build \(SemVerVersions.buildVersion())")
}

func isNumeric() -> Bool {
    return Args.parsed.flags[SemVerFlags.Numeric.long] != nil || Args.parsed.flags[SemVerFlags.Numeric.short] != nil
}

func getValueForOptionalFlag(flag: Flag) -> String? {
    let flags = Args.parsed.flags
    var optional = flags[flag.long]
    if optional == nil {
        optional = Args.parsed.flags[flag.short]
    }
    return optional
}

func checkForHelp() {
    let flags = Args.parsed.flags

    // see if user wants usage printed by providing -h/--help
    if flags.keys.contains(Flag.Usage.short) || flags.keys.contains(Flag.Usage.long) {
        printUsage()
        exit(ExitCode.Normal.rawValue)
    }
}

func checkForVersion() {
    let flags = Args.parsed.flags

    // see if user wants usage printed by providing -v/--version
    if flags.keys.contains(Flag.Version.short) || flags.keys.contains(Flag.Version.long) {
        printVersion()
        exit(ExitCode.Normal.rawValue)
    }
}

func checkForDebugMode() {
    let flags = Args.parsed.flags

    if flags.keys.contains(Flag.Debug.short) || flags.keys.contains(Flag.Debug.long) {
//        CLSLogging.sharedInstance().logLevel = .Debug

        printVersion()
        print("\nArguments:")
        print("debug mode enabled".s.Bold)
    }
}

func versionFromCommandLine() -> String? {
    var version = Args.parsed.flags[SemVerFlags.CurrentVersion.long]
    if version == nil {
        version = Args.parsed.flags[SemVerFlags.CurrentVersion.short]
    }

    return version
}

func isDryRun() -> Bool {
    return Args.parsed.flags.keys.contains(Flag.DryRun.long) || Args.parsed.flags.keys.contains(Flag.DryRun.short)
}
