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
        var value = NSUserDefaults.standardUserDefaults().stringForKey("-\(flag.long)")
        if value == nil {
            value = NSUserDefaults.standardUserDefaults().stringForKey(flag.short)
        }
        return value
    }

    static func value(forNonoptionalFlag flag: CommandLineOption) -> String {
        let optional = self.value(forOptionalFlag: flag)
        guard let value = optional else {
            printUsage()
            exit(ErrorCode.MissingFlag.rawValue)
        }
        return value
    }
}
