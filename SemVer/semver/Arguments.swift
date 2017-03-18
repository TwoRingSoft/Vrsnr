//
//  Arguments.swift
//  SemVer
//
//  Created by Andrew McKnight on 1/9/17.
//  Copyright © 2017 Two Ring Software. All rights reserved.
//

import Foundation

struct Arguments {

    static func contains(_ flag: CommandLineOption) -> Bool {
        return self.contains("-\(flag.short)") || self.contains("--\(flag.long)")
    }

    static func contains(_ string: String) -> Bool {
        return ProcessInfo.processInfo.arguments.contains(string)
    }

}

struct Flags {

    static func value(forOptionalFlag flag: CommandLineOption) -> String? {
        var value = UserDefaults.standard.string(forKey: "-\(flag.long)")
        if value == nil {
            value = UserDefaults.standard.string(forKey: flag.short)
        }
        return value
    }

    static func value(forNonoptionalFlag flag: CommandLineOption) -> String {
        let optional = self.value(forOptionalFlag: flag)
        guard let value = optional else {
            printUsage()
            exit(ErrorCode.missingFlag.rawValue)
        }
        return value
    }
}
