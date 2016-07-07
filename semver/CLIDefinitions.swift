//
//  CLIDefinitions.swift
//  SemVer
//
//  Created by Andrew McKnight on 6/27/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import AppKit
import Foundation

enum Flag {
    case Usage
    case Version
    case Debug
    case DryRun

    var short: String {
        switch self {
        case .Usage:
            return "h"
        case .Version:
            return "v"
        case .Debug:
            return "d"
        case .DryRun:
            return "t"
        }
    }

    var long: String {
        switch self {
        case .Usage:
            return "help"
        case .Version:
            return "version"
        case .Debug:
            return "debug"
        case .DryRun:
            return "try"
        }
    }
}
