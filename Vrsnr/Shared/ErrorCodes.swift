//
//  ErrorCodes.swift
//  Vrsnr
//
//  Created by Andrew McKnight on 7/7/16.
//  Copyright © 2016 Two Ring Software. All rights reserved.
//

import Foundation

enum ErrorCode: Int32 {
    case normal = 0

    case missingFlag

    case couldNotParseVersion
    case couldNotReadFile
    case unwritableFile
    case unsupportedFileType
    case malformedVersionValue
    case noVersionFoundInFile
    case dynamicVersionFound
    case nsNumberFormatterCouldNotParse
    case noVersionInformationSource

    case unknownError

    func valueAsInt() -> Int {
        return Int(self.rawValue)
    }
}
