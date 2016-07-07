//
//  ErrorCodes.swift
//  SemVer
//
//  Created by Andrew McKnight on 7/7/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import Foundation

enum ErrorCode: Int32 {
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
