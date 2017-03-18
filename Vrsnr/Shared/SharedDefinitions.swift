//
//  Definitions.swift
//  Vrsnr
//
//  Created by Andrew McKnight on 6/27/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import Foundation

let errorDomain = "com.vrsn.dylib"

public protocol CommandLineOption {
    var long: String { get }
    var short: String { get }
}

public enum VrsnrFlags: UInt8, CommandLineOption {
    case key
    case file
    case numeric
    case currentVersion
    case readFromFile

    public var long: String {
        switch self {
        case .key:
            return "key"
        case .file:
            return "file"
        case .numeric:
            return "numeric"
        case .currentVersion:
            return "current-version"
        case .readFromFile:
            return "read"
        }

    }

    public var short: String {
        switch self {
        case .key:
            return "k"
        case .file:
            return "f"
        case .numeric:
            return "n"
        case .currentVersion:
            return "c"
        case .readFromFile:
            return "r"
        }
    }
}
