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
    file = try! createFileForPath(path!)
    key = getValueForOptionalFlag(SemVerFlags.Key)
}

// not required
var identifier = getVersionSuffix(.PrereleaseIdentifier)
var metadata = getVersionSuffix(.BuildMetadata)

// if no version override was specified with --current-version, get it from the file now
let versionType = getVersionType()
if versionString == nil {
    guard let specifiedFile = file else {
        print("Need to specify either a file containing version info or a value for \(SemVerFlags.CurrentVersion.short)/\(SemVerFlags.CurrentVersion.long).".f.Red)
        exit(ErrorCode.NoVersionInformationSource.rawValue)
    }

    versionString = specifiedFile.versionStringForKey(key, versionType: versionType)
}

// extract the version from the file, optionally calculating the next version according to arguments
var original: Version
var new: Version?
switch(versionType) {
case .Numeric:
    original = try! NumericVersion.parseFromString(versionString!)
    if !readOnlyFromFile {
        new = original.nextVersion(0, prereleaseIdentifier: identifier, buildMetadata: metadata)
    }
case .Semantic:
    original = try! SemanticVersion.parseFromString(versionString!)
    if !readOnlyFromFile {
        new = original.nextVersion(getRevType(), prereleaseIdentifier: identifier, buildMetadata: metadata)
    }
}

// output or replace new version in file
if dryRun {
    print(NSString(format: "%@", new!.description))
} else if readOnlyFromFile {
    print(NSString(format: "%@", original.description))
} else {

    try! file!.replaceVersionString(original, new: new!, key: key)
    if key == nil {
        key = file?.defaultKeyForVersionType(versionType)
    }
    print(NSString(format: "Updated %@ from %@ to %@ in %@", key!, original.description, new!.description, path!))
}
