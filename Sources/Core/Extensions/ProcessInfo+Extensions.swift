//
//  ProcessInfo+Extensions.swift
//  
//
//  Created by Stefan Herold on 17.11.20.
//

import Foundation

public extension ProcessInfo {

    static var processId: String {
        "com.stherold.\(processInfo.processName)"
    }
}
