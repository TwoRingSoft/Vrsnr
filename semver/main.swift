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
let dryRun = isDryRun()

// get path to file containing source definition if we are reading or writing files
var path: String?
var file: File?
var key: String?
if !(dryRun && versionString != nil) {
    path = getValue(SemVerFlags.File)
    file = try! File(path: path!)
    key = getValue(SemVerFlags.Key)
}

var identifier = getVersionSuffix(.PrereleaseIdentifier)
var metadata = getVersionSuffix(.BuildMetadata)

var original: String
var new: String
if isNumeric() {
    let originalVersion: NumericVersion
    if let providedFile = file, let providedKey = key {
        originalVersion = try! providedFile.getNumericVersionForKey(providedFile, key: providedKey)
    } else {
        originalVersion = try! NumericVersion.parseFromString(versionString!)
    }
    original = originalVersion.description
    new = originalVersion.nextVersion(0, prereleaseIdentifier: identifier, buildMetadata: metadata).description
} else {
    let originalVersion: SemanticVersion
    if let providedFile = file, let providedKey = key {
        originalVersion = try! providedFile.getSemanticVersionForKey(providedFile, key: providedKey)
    } else {
        originalVersion = try! SemanticVersion.parseFromString(versionString!)
    }
    original = originalVersion.description
    new = originalVersion.nextVersion(getRevType(), prereleaseIdentifier: identifier, buildMetadata: metadata).description
}

if isDryRun() {
    print("\(new)")
} else {
    try! replaceVersionString(original, new: new, key: key!, file: file!)
    print("Updated \(key) from \(original) to \(new) in \(path)")
}
