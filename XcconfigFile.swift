//
//  XcconfigFile.swift
//  SemVer
//
//  Created by Andrew McKnight on 7/9/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import Foundation

public struct XcconfigFile {
    public let path: String
}

extension XcconfigFile: File {

    public func defaultKeyForVersionType(type: VersionType) -> String {
        switch(type) {
        case .Numeric:
            return "DYLIB_CURRENT_VERSION"
        case .Semantic:
            return "CURRENT_PROJECT_VERSION"
        }
    }

    public func versionStringForKey(key: String?, versionType: VersionType) -> String? {
        let data = try! NSString(contentsOfFile: self.path, encoding: NSUTF8StringEncoding)

        // get each line that contains the key
        let workingKey = chooseWorkingKey(key, versionType: versionType)
        let versionDefinitions = data.componentsSeparatedByString("\n").filter() { line in
            line.containsString("\(workingKey) = ")
        }

        if versionDefinitions.count == 0 {
            return nil
        }

        // if more than one line has the key on it, we just pick the first automatically for now (we only expect the key to appear once in xcconfigs and plists, but this may change when adding more support, e.g. xcodeprojs
        if versionDefinitions.count > 1 {
            print("More than one possible version definition: \(versionDefinitions), will pick first.")
        }
        let line = versionDefinitions.first!

        // discard key assignment portion and any trailing comments, then trim whitespace
        return line.componentsSeparatedByString("=").last!.componentsSeparatedByString("//").first!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }

    public func replaceVersionString(original: Version, new: Version, key: String?) throws {
        let contents = try! NSString(contentsOfFile: self.path, encoding: NSUTF8StringEncoding)

        let workingKey = chooseWorkingKey(key, versionType: new.type)

        let newContents = ((contents.componentsSeparatedByString("\n").map() { line in
            if line.containsString(workingKey) {
                return line.stringByReplacingOccurrencesOfString(original.description, withString: new.description)
            } else {
                return line
            }
        } as [String]) as NSArray).componentsJoinedByString("\n")

        try! newContents.writeToFile(self.path, atomically: true, encoding: NSUTF8StringEncoding)
    }

}

extension XcconfigFile {

    private func chooseWorkingKey(key: String?, versionType: VersionType) -> String {
        if key == nil {
            return defaultKeyForVersionType(versionType)
        } else {
            return key!
        }
    }

}
