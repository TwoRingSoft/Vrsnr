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
    var help: String { get }
    var optional: Bool { get }
}
