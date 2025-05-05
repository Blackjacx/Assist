import ArgumentParser
import Core
import Foundation

@main
public final class Playground: AsyncParsableCommand {
    public static var configuration = CommandConfiguration(
        abstract: "Play around with a Swift command line tool",

        // Commands can define a version for automatic '--version' support.
        version: Constants.version
    )

    public init() {}

    public func run() async throws {
        
    }
}
