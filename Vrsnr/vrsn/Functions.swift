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
    print("usage: vrsn COMPONENT FLAGS [OPTIONS]\n")

    print("COMPONENT\n")
    print("\tThe semantic version component to revision. Either “major”, “minor” or “patch”.\n")

    print("FLAGS\n")

    Flag.allCases.forEach { flag in
        print("\t-\(flag.short)/--\(flag.long): \(flag.help)\(flag.optional ? " (Optional)" : "")")
    }

    print("\nFor questions or suggestions, email two.ring.soft+vrsnr@gmail.com or visit https://github.com/TwoRingSoft/Vrsnr.")

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
    if Arguments.contains(Flag.numeric) {
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
    return Arguments.contains(Flag.readFromFile)
}

func isDryRun() -> Bool {
    return Arguments.contains(Flag.dryRun)
}
