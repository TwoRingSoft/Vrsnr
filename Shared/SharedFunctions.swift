//
//  Functions.swift
//  SemVer
//
//  Created by Andrew McKnight on 6/27/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import Foundation

func replaceVersionString(original: String, new: String, key: String, file: File) throws {
    if file.type == .XCConfig {
        let contents = try! NSString(contentsOfFile: file.path, encoding: NSUTF8StringEncoding)
        let newContents = ((contents.componentsSeparatedByString("\n").map() { line in
                if line.containsString(key) {
                    return line.stringByReplacingOccurrencesOfString(original, withString: new)
                } else {
                    return line
                }
            } as [String]) as NSArray).componentsJoinedByString("\n")

        try! newContents.writeToFile(file.path, atomically: true, encoding: NSUTF8StringEncoding)
    } else if file.type == .Plist {
        guard let dictionary = NSDictionary(contentsOfFile: file.path) else {
            return
        }
        dictionary.setValue(new, forKey: key)
        dictionary.writeToFile(file.path, atomically: true)
    }
}

func getPrereleaseIdentifierAndBuildMetadata(string: String) -> (prereleaseIdentifier: String?, buildMetadata: String?) {

    let hasPrereleaseIdentifier = string.containsString("-")
    let hasBuildMetadata = string.containsString("+")

    if !(hasPrereleaseIdentifier || hasBuildMetadata) {
        return (nil, nil)
    }

    let definitionComponents = string.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "-+"))

    var metadata: String?
    if definitionComponents.count > 2 {
        metadata = definitionComponents[2]
    }

    var prereleaseID: String?
    if definitionComponents.count > 1 {
        // check to see if metadata exists with no prerelease identifier
        if hasBuildMetadata && !hasPrereleaseIdentifier {
            metadata = definitionComponents[1]
        } else if hasPrereleaseIdentifier {
            prereleaseID = definitionComponents[1]
        }
    }

    return (prereleaseID, metadata)
}
