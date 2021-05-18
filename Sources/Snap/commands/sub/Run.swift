//
//  Run.swift
//  
//
//  Created by Stefan Herold on 21.09.20.
//

import Foundation
import ArgumentParser
import Core
import Engine
import SwiftShell

/// This script runs your screenshot UNIT tests with the goal to automatically generate as many screenshot varaints
/// as possible in as less time as possible.
///
/// These variants are:
///
/// - all supported device classes
/// - all supported languages
/// - dark | light mode
/// - normal | high contrast mode
/// - selected dynamic font sizes (smallest, normal, largest)
///
/// To speed up this process we do the following:
///
/// - run only one unit test: our screenshot test
/// - first builds the app using `build-for-testing` and then runs tests in parallel using `test-without-building`
///   with all variants.
///
/// To finish things up we create a nice static webpage from the results which can cycle through the screenshots
/// automatically so they can be viewed on a big screen. This way bugs can be detected early.
///
/// The generated screens will also be automatically put into nice device mockups so the output will actually look
/// like a real phone.
///
extension Snap {

    struct Run: ParsableCommand {

        static var configuration = CommandConfiguration(
            abstract: "Runs snapshotting using the specified parameters."
        )

        // The `@OptionGroup` attribute includes the flags, options, and arguments defined by another
        // `ParsableArguments` type.
        @OptionGroup()
        var options: Options

        @Option(help: "The workspace used to make the screenshots.")
        var workspace: String

        @Option(help: "A list of schemes to run the screenshot tests on.")
        var schemes: [String]

        @Option(help: "The mode the tool should run in.")
        var mode: ExecutionMode

        @Option(help: "The destination directory where the screenshots and the zip archive should be stored.")
        var destinationDir: String?

        @Option(help: "The zip file name that should be used.")
        var zipFileName: String

        @Option(help: "An optional platform to be used. Omit to use the latest. Currently only iOS is supported.")
        var platform: Simctl.Platform?

        func validate() throws {
            guard FileManager.default.fileExists(atPath: workspace) else {
                throw ValidationError("\(workspace) not found.")
            }

            guard !schemes.isEmpty else {
                throw ValidationError("No target specified.")
            }

            if let destinationDir = self.destinationDir {
                var isDir: ObjCBool = false
                guard FileManager.default.fileExists(atPath: destinationDir, isDirectory: &isDir), isDir.boolValue else {
                    throw ValidationError("\(destinationDir) does not exist or is no directory.")
                }
            }

            if let platform = self.platform {
                guard try Simctl.isPlatformValid(platform.rawValue) else {
                    throw ValidationError("\(platform) not installed on your system. Run `xcrun simctl list` to find available ones.")
                }
            }
        }

        func run() throws {
            let outURL: URL

            if let destinationDir = destinationDir {
                outURL = URL(fileURLWithPath: destinationDir, isDirectory: true)
            } else {
                outURL = try FileManager.createTemporaryDirectory()
            }

            do {
                let platform = try self.platform?.rawValue ?? Simctl.latestAvailableIOS()

                let configMessage = """
                Using the following config:
                    mode: \(mode.name)
                    styles: \(mode.styles.map { $0.name })
                    devices: \(mode.devices.map { $0.name })
                    platform: \(platform)
                    destination: \(outURL.path.appendPathComponent(zipFileName))
                """
                print(configMessage)

                print("➡️  Killing all open simulators")
                SwiftShell.run("killall", ["simulator"])

                print("➡️  Finding runtime for platform \(platform)")
                let runtime = try Simctl.runtimeForPlatform(platform)
                print("✅  Runtime found \(runtime)")

                print("➡️  Find IDs of preferred device IDs")
                let deviceIds = try Simctl.deviceIdsFor(deviceTypes: mode.devices, runtime: runtime)
                print("✅  \(deviceIds)")

                print("➡️  Building all requested schemes for testing")
                try Xcodebuild.execute(cmd: .buildForTesting,
                                       workspace: workspace,
                                       schemes: schemes,
                                       deviceIds: deviceIds)

                print("➡️  Taking screenshots for all requested configs")
                try Simctl.snap(styles: mode.styles,
                                workspace: workspace,
                                schemes: schemes,
                                deviceIds: deviceIds,
                                outURL: outURL,
                                zipFileName: zipFileName)

                print("✅  Find your screens in \(outURL.path)")

            } catch {
                // Do not remove the destination directory when it came from outside.
                // The responsibility of removal lies there.
                if self.destinationDir == nil {
                    try FileManager.default.removeItem(at: outURL)
                }
                throw error
            }
        }
    }
}

extension Simctl.Style: ExpressibleByArgument {}
extension Simctl.Platform: ExpressibleByArgument {}

extension Snap.Run {

    enum ExecutionMode: String, ExpressibleByArgument, CaseIterable {
        case fast
        case full

        var defaultValueDescription: String {
            switch self {
            case .fast: return "Generates screenshots on a single device / language / appearance only."
            case .full: return "Generates all the combinations of screenshots. Takes significantly longer."
            }
        }

        var styles: [Simctl.Style] {
            switch self {
            case .fast: return [.light]
            case .full: return [.light, .dark]
            }
        }

        var devices: [Simctl.DeviceType] {
            switch self {
            case .fast: return [.iPhone11Pro]
            case .full: return [.iPhoneSE, .iPhone11Pro, .iPhone11ProMax]
            }
        }

        var name: String { "\(self)" }
    }
}
