//
//  main.swift
//  semver
//
//  Created by Andrew McKnight on 6/26/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//
//                    `.-:///////:--`  `-::///////:-.`
//                .://-.``      `.-::/:-.`      ``.-:/-.
//              .//.`           `-/:.`-/-`           `./:.
//            `//.     TWO     ./:`    `:/.             ./:`
//           ./:`             -/-        ./-             `:/`
//          `/:              -+-          ./.              :/`
//          :+`              //            //              `+-
//          //              `+-    RING    -+`              //
//          //              `+-            -+`              //
//          :+`              //            :/              `+-
//          `/:              .+-          ./.              :/`
//           ./:`             -/-        ./-             `:/`
//            `:/.             ./:`    `:/.    SOFT     ./:`
//              .//.`           `-/-`.:/-`           `.::.
//                `-/:-.``      `.-:/::-.`      ``.-:/-`
//                   `.-:::////::-.`  `.-::////:::-.`

import Foundation

checkForDebugMode()
checkForHelp()
checkForVersion()

// see if user provided current version via command line argument; if so, ignore file/key later
let versionString = versionFromCommandLine()

// get path to file containing source definition
let path = getValue(SemVerFlags.File)
let file = try! File(path: path)

// get key for version number value (required)
let key = getValue(SemVerFlags.Key)

var identifier = getVersionSuffix(.PrereleaseIdentifier)
var metadata = getVersionSuffix(.BuildMetadata)

var original: String
var new: String
if isNumeric() {
    let originalVersion: NumericVersion
    if versionString == nil {
        originalVersion = try! file.getNumericVersionForKey(key)
    } else {
        originalVersion = try! NumericVersion.parseFromString(versionString!)
    }
    original = originalVersion.description
    new = originalVersion.nextVersion(0, prereleaseIdentifier: identifier, buildMetadata: metadata).description
} else {
    let originalVersion: SemanticVersion
    if versionString == nil {
        originalVersion = try! file.getSemanticVersionForKey(key)
    } else {
        originalVersion = try! SemanticVersion.parseFromString(versionString!)
    }
    original = originalVersion.description
    new = originalVersion.nextVersion(getRevType(), prereleaseIdentifier: identifier, buildMetadata: metadata).description
}

try! replaceVersionString(original, new: new, key: key, file: file)
print("Updated \(key) from \(original) to \(new) in \(path)")



