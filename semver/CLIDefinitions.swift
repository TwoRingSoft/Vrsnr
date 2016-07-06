//
//  CLIDefinitions.swift
//  SemVer
//
//  Created by Andrew McKnight on 6/27/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import AppKit
import Foundation

enum ExitCode: Int32 {
    case Normal = 0

    case MissingFlag

    case CouldNotParseVersion
    case CouldNotReadFile
    case UnwritableFile
    case UnsupportedFileType
    case MalformedVersionValue
    case NoVersionFoundInFile
    case DynamicVersionFound
    case NSNumberFormatterCouldNotParse

    case UnknownError

    func valueAsInt() -> Int {
        return Int(self.rawValue)
    }
}

enum Flag {
    case Usage
    case Version
    case Debug

    var short: String {
        switch self {
        case .Usage:
            return "h"
        case .Version:
            return "v"
        case .Debug:
            return "d"
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
        }
    }
}