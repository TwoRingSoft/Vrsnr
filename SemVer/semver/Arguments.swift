//
//  Arguments.swift
//  SemVer
//
//  Created by Andrew McKnight on 1/9/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Foundation

struct Arguments {

    static func contains(flag: CommandLineOption) -> Bool {
        return self.contains("-\(flag.short)") || self.contains("--\(flag.long)")
    }

    static func contains(string: String) -> Bool {
        return NSProcessInfo.processInfo().arguments.contains(string)
    }

}

struct Flags {

    static func value(forOptionalFlag flag: CommandLineOption) -> String? {
        var value = NSUserDefaults.standardUserDefaults().stringForKey(flag.long)
        if value == nil {
            value = NSUserDefaults.standardUserDefaults().stringForKey(flag.short)
        }
        return value
    }

    func value(forNonoptionalFlag flag: CommandLineOption) -> String {
        var optional = NSUserDefaults.standardUserDefaults().stringForKey(flag.long)
        if optional == nil {
            optional = NSUserDefaults.standardUserDefaults().stringForKey(flag.short)
        }
        guard let value = optional else {
            printUsage()
            exit(ErrorCode.MissingFlag.rawValue)
        }
        return value
    }
}
