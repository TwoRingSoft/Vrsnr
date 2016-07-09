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

// check for options that should halt the program without computation
checkForHelp()
checkForVersion()

// check for some options that affect requirement to read/write file later.
//
// precedence (high to low): --read, --try/--current-version
let readOnlyFromFile = isRead()
var versionString: String?
var dryRun = false
if !readOnlyFromFile {
    versionString = versionFromCommandLine()
    dryRun = isDryRun()
}

// get path to file containing source definition if we are reading or writing files...
//
// fileReadRequired: if the --read option is specified or there is no --current-version specified, we must read from the file
// fileWriteRequired: if --try is not specified, we must write to the file
//
// if either fileReadRequired or fileWriteRequired are true, --file and --key are required
var path: String?
var file: File?
var key: String?
let fileReadRequired = versionString == nil || readOnlyFromFile
let fileWriteRequired = !dryRun
if fileReadRequired || fileWriteRequired {
    path = getValue(SemVerFlags.File)
    file = try! File(path: path!)
    key = getValue(SemVerFlags.Key)
}

// not required
var identifier = getVersionSuffix(.PrereleaseIdentifier)
var metadata = getVersionSuffix(.BuildMetadata)

var original: String
var new: String?
if isNumeric() {
    let originalVersion: NumericVersion
    if let providedFile = file, let providedKey = key {
        originalVersion = try! providedFile.getNumericVersionForKey(providedFile, key: providedKey)
    } else {
        originalVersion = try! NumericVersion.parseFromString(versionString!)
    }
    original = originalVersion.description
    if !readOnlyFromFile {
        new = originalVersion.nextVersion(0, prereleaseIdentifier: identifier, buildMetadata: metadata).description
    }
} else {
    let originalVersion: SemanticVersion
    if let providedFile = file, let providedKey = key {
        originalVersion = try! providedFile.getSemanticVersionForKey(providedFile, key: providedKey)
    } else {
        originalVersion = try! SemanticVersion.parseFromString(versionString!)
    }
    original = originalVersion.description
    if !readOnlyFromFile {
        new = originalVersion.nextVersion(getRevType(), prereleaseIdentifier: identifier, buildMetadata: metadata).description
    }
}

if dryRun {
    print(NSString(format: "%@", new!))
} else if readOnlyFromFile {
    print(NSString(format: "%@", original))
} else {
    try! replaceVersionString(original, new: new!, key: key!, file: file!)
    print(NSString(format: "Updated %@ from %@ to %@ in %@", key!, original, new!, path!))
}
