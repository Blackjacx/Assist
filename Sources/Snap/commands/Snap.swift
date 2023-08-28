//
//  Snap.swift
//  
//
//  Created by Stefan Herold on 21.09.20.
//

import Foundation
import Engine
import ArgumentParser
import Core

@main
public final class Snap: ParsableCommand {

    public static var configuration = CommandConfiguration(
        abstract: "Make your mobile screenshot automation a breeze and blazingly fast.",
        discussion: """
            This script runs your screenshot UNIT tests with the goal to
            automatically generate as many screenshot variants as possible in
            as less time as possible.

            These variants are:

            - all supported device classes
            - all supported languages
            - dark | light mode
            - normal | high contrast mode
            - selected dynamic font sizes (smallest, normal, largest)

            To speed up this process we do the following:
            - run only one unit test: our screenshot test
            - first builds the app using `build-for-testing` and then runs
              tests in parallel using `test-without-building` with all variants.

            To finish things up we create a nice static webpage from the
            results which can cycle through the screenshots automatically so
            they can be viewed on a big screen. This way bugs can be detected
            early.

            The generated screens will also be automatically put into nice
            device mockups so the output will actually look like a real phone.
            """,

        // Commands can define a version for automatic '--version' support.
        version: Constants.version
    )

    // The `@OptionGroup` attribute includes the flags, options, and arguments defined by another
    // `ParsableArguments` type.
    @OptionGroup()
    var options: Options

    @Option(help: "The path to the workspace used to make the screenshots.")
    var workspace: String

    @Option(name: [.short, .customLong("scheme")], help: "A scheme to run the screenshot tests on. Can be specified multiple times to generate screenshots for multiple schemes.")
    var schemes: [String]

    @Option(help: "The name of the TestPlan running the screenshot tests.")
    var testPlanName: String

    @Option(name: .shortAndLong, parsing: .upToNextOption, help: "An optional list of test plan configurations. They must match exactly the name of the config from the test plan.")
    var testPlanConfigs: [String] = []

    @Option(parsing: .upToNextOption, help: "The appearances the screenshots should be made for, e.g. --appearances \(Simctl.Style.allCases.map({"\"\($0.parameterName)\""}).joined(separator: " "))")
    var appearances: [Simctl.Style] = [.light]

    @Option(parsing: .upToNextOption, help: "Devices you want to generate screenshots for (run `xcrun simctl list` to list all possible devices)")
    var devices: [String] = ["iPhone 14 Pro"]

    @Option(help: "The destination directory where the screenshots and the zip archive should be stored.")
    var destinationDir: String?

    @Option(help: "The zip file name that should be used.")
    var zipFileName: String

    @Option(help: "An optional runtime to be used. Omit to use the latest.")
    var runtime: String?

    public init() {
        
    }

    public func validate() throws {
        let fileManager = FileManager.default

        guard fileManager.fileExists(atPath: workspace) else {
            throw ValidationError("\(workspace) not found.")
        }

        guard !schemes.isEmpty else {
            throw ValidationError("No target specified.")
        }

        if let destinationDir {
            var isDir: ObjCBool = false
            guard fileManager.fileExists(atPath: destinationDir, isDirectory: &isDir), isDir.boolValue else {
                throw ValidationError("\(destinationDir) does not exist or is no directory.")
            }
        }

        if let runtime {
            guard try Simctl.isRuntimeNameValid(runtime) else {
                let availableRuntimes = ListFormatter.localizedString(byJoining: try Simctl.availableRuntimes().map(\.name))
                throw ValidationError("\(runtime) not installed on your system. Valid runtimes: \(availableRuntimes).")
            }
        }
    }

    public func run() throws {
        let outURL: URL
        let derivedDataUrl = try FileManager.createTemporaryDirectory()

        if let destinationDir {
            outURL = URL(fileURLWithPath: destinationDir, isDirectory: true)
        } else {
            outURL = try FileManager.createTemporaryDirectory()
        }

        do {
            let runtimeName = try self.runtime ?? Simctl.latestAvailableIosRuntime()

            let configMessage = """
                Using the following config:
                    styles: \(ListFormatter.localizedString(byJoining: appearances.map { $0.parameterName }))
                    devices: \(ListFormatter.localizedString(byJoining: devices))
                    platform: \(runtimeName)
                    schemes: \(ListFormatter.localizedString(byJoining: schemes))
                    test plan: \(testPlanName) (\(testPlanConfigs.isEmpty ? "all configs" : ListFormatter.localizedString(byJoining: testPlanConfigs)))
                    destination: \(outURL.path.appendPathComponent(zipFileName))
                """
            Logger.shared.info(configMessage)

            Simctl.killAllSimulators()

            Logger.shared.info("Finding runtime for platform \(runtimeName)")
            let runtime = try Simctl.runtime(for: runtimeName)
            Logger.shared.info("Runtime found \(runtime)")

            Logger.shared.info("Find IDs of preferred device IDs")
            let deviceIds = try Simctl.deviceIdsFor(deviceNames: devices, runtime: runtime)
            Logger.shared.info("Device IDs Found: \(deviceIds)")

            Logger.shared.info("Building all requested schemes for testing")
            try Xcodebuild.execute(subcommand: .buildForTesting(workspace: workspace, schemes: schemes),
                                   deviceIds: deviceIds,
                                   derivedDataUrl: derivedDataUrl)

            Logger.shared.info("Taking screenshots for all requested configurations")
            try Simctl.snap(styles: appearances,
                            workspace: workspace,
                            schemes: schemes,
                            derivedDataUrl: derivedDataUrl,
                            testPlanName: testPlanName,
                            testPlanConfigs: testPlanConfigs,
                            runtime: runtimeName.components(separatedBy: " ").last!, // grab the version number of the provided runtime
                            arch: ProcessInfo.machineHardwareName,
                            platform: "iphonesimulator", // we're always generating on a simulator
                            deviceIds: deviceIds,
                            outUrl: outURL,
                            zipFileName: zipFileName)

            Logger.shared.info("Find your screens in \(outURL.path)")

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

/// Here you can specify parameters valid for all sub commands.
struct Options: ParsableArguments {

    @Flag(name: .shortAndLong, help: "Activate verbose logging.")
    var verbose: Int

    mutating func validate() throws {
        // Misusing validate to set the received flag globally
        Network.verbosityLevel = verbose
    }
}

extension Simctl.Style: ExpressibleByArgument {}
