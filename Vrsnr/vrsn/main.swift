//
//  main.swift
//  vrsn
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
// precedence: --read > --try == --current-version
let readOnlyFromFile = isRead()
var versionString: String?
var dryRun = false
if !readOnlyFromFile {
    versionString = Flags.value(forOptionalFlag: Flag.currentVersion)
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
    path = Flags.value(forNonoptionalFlag: Flag.file)
    file = try! createFileForPath(path!)
    key = Flags.value(forOptionalFlag: Flag.key)
}

// not required
var identifier = Flags.value(forOptionalFlag: Flag.prereleaseIdentifier)
var metadata = Flags.value(forOptionalFlag: Flag.buildMetadata)

// if no version override was specified with --current-version, get it from the file now
let versionType = getVersionType()
if versionString == nil {
    guard let specifiedFile = file else {
        print("Need to specify either a file containing version info or a value for \(Flag.currentVersion.short)/\(Flag.currentVersion.long).")
        exit(ErrorCode.noVersionInformationSource.rawValue)
    }

    versionString = try! specifiedFile.versionStringForKey(key, versionType: versionType)
}

// FIXME: generics abuses incoming!

func doWork<V>() -> V where V: Version {

    // extract the version from the file, optionally calculating the next version according to arguments
    let original = try! V.parseFromString(versionString!)

    var new: V?
    if !readOnlyFromFile {
        switch(versionType) {
        case .Numeric:
            new = original.nextVersion(0, prereleaseIdentifier: identifier, buildMetadata: metadata)
        case .Semantic:
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

    return original
}

//
// FIXME: vv generics abuses vv
//
// We have some generic functions that need to infer the template type, but I guess I haven't done so correctly yet, maybe using associatedType in the protocols with typealiases here? Will probably involve generic-izing the remainder of the protocol/shared functions etc
//
// So, for now we assign the result to a specific version type instead of something of type Version. This way the compiler infers the right type to use, and passes it back via the doWork()'s templated return type, which propogates to everything else from there.
//
switch versionType {
case .Numeric:
    let _: NumericVersion = doWork()
case .Semantic:
    let _: SemanticVersion = doWork()
}

//
// FIXME: ^^ generics abuses ^^
//
