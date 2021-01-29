//
//  Command.swift
//  ASC
//
//  Created by Stefan Herold on 19.11.20.
//

import Foundation

/// Concurrent operation queue
private let serialQueue: OperationQueue = {
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 1
    return queue
}()

/// Contains the general logic for execution of commands.
///
/// A command is defined as protocol on top of `Operation` which is important for it's execution which is done using
/// a OperationQueue.
public protocol Command: Operation {

}

public extension Operation {

    func executeSync() {
        serialQueue.addOperations([self], waitUntilFinished: true)
    }

    func executeAsync(completion: @escaping () -> Void) {

        serialQueue.addOperation(self)
        serialQueue.addBarrierBlock { completion() }
    }
}

public extension Array where Element == Command {

    func executeSync() {
        serialQueue.addOperations(self, waitUntilFinished: true)
    }

    func executeAsync(completion: @escaping () -> Void) {

        serialQueue.addOperations(self, waitUntilFinished: false)
        serialQueue.addBarrierBlock { completion() }
    }
}
