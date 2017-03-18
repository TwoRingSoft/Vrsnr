//
//  CLIDefinitions.swift
//  SemVer
//
//  Created by Andrew McKnight on 6/27/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import AppKit
import Foundation

enum Flag: CommandLineOption {
    case usage
    case version
    case debug
    case dryRun

    var short: String {
        switch self {
        case .usage:
            return "h"
        case .version:
            return "v"
        case .debug:
            return "d"
        case .dryRun:
            return "t"
        }
    }

    var long: String {
        switch self {
        case .usage:
            return "help"
        case .version:
            return "version"
        case .debug:
            return "debug"
        case .dryRun:
            return "try"
        }
    }
}
