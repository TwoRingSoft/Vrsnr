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
    var metadata: String?
    var prereleaseID: String?

    var remainingString = string
    if string.containsString("+") {
        let components = string.componentsSeparatedByString("+")
        metadata = components.last
        remainingString = components.first!
    }

    if remainingString.containsString("-") {
        let firstHyphenIdx = remainingString.rangeOfString("-")!
        prereleaseID = remainingString.substringFromIndex(firstHyphenIdx.startIndex.advancedBy(1))
    }


    return (prereleaseID, metadata)
}
