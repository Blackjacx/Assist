import Engine
import Foundation
import SwiftShell

public struct Simctl {}

// MARK: - Public: Simctl Convenience Functions

public extension Simctl {

    static func availableRuntimes() throws -> [Runtime] {
        try Simctl._list().runtimes
    }

    static func latestAvailableIosRuntime() throws -> String {
        guard let runtimeName = try availableRuntimes()
            .sorted(by: { $0.version > $1.version })
            .first(where: { $0.name.starts(with: "iOS") }) else {
            throw Error.latestRuntimeNameNotFound
        }
        return runtimeName.name
    }

    static func isRuntimeNameValid(_ runtimeName: String) throws -> Bool {
        try Simctl._list().runtimes.contains(where: { $0.name == runtimeName })
    }

    static func runtime(for runtimeName: String) throws -> Runtime {
        guard let runtime = try Simctl._list().runtimes.first(where: { $0.name == runtimeName }) else {
            throw Error.runtimeNotFound(name: runtimeName)
        }
        return runtime
    }

    static func devicesForRuntime(_ runtime: Runtime) throws -> [Device] {
        guard let devices = try Simctl._list().devices.first(where: { $0.key == runtime.identifier }).map({ $0.value }) else {
            throw Error.devicesNotFoundForRuntime(runtime)
        }
        return devices
    }

    static func deviceIdsFor(deviceNames: [String], runtime: Runtime) throws -> [String] {
        var deviceIDs: [String] = []

        try deviceNames.forEach { name in
            guard let deviceID = try devicesForRuntime(runtime).first(where: { $0.name == name }) else {
                // Create device if it is not yet available
                let deviceID = try createDevice(name: name, id: name, runtime: runtime)
                deviceIDs.append(deviceID)
                return
            }
            deviceIDs.append(deviceID.udid)
        }
        return deviceIDs
    }

    static func killAllSimulators() {
        Log.simctl.info("Killing all open simulators")

        try? runAndPrint(bash: "killall Simulator")
        try? runAndPrint(bash: "killall iPhone Simulator")
//        try? runAndPrint(bash: "killall -10 com.apple.CoreSimulator.CoreSimulatorService")
    }

    static func createDevice(name: String, id: String, runtime: Runtime) throws -> String {
        Log.simctl.info("Create device \(id) with name \"\(name)\" and runtime \(runtime)")
        return try Simctl._createDevice(name: name, id: id, runtime: runtime)
    }

    static func updateStyle(_ style: Style, deviceIds: [String]) throws {
        try deviceIds.forEach {
            Log.simctl.info("Set style \(style) for device \($0)")
            try _boot(deviceId: $0)
            try _setAppearance(for: $0, style: style)
        }
    }

    static func updateStatusBar(deviceIds: [String]) throws {
        try deviceIds.forEach {
            Log.simctl.info("Set statusbar for device \($0)")

            try _boot(deviceId: $0)
            try _updateStatusBar(deviceId: $0)
        }
    }

    static func snap(styles: [Style],
                     workspace: String,
                     schemes: [String],
                     derivedDataUrl: URL,
                     testPlanName: String,
                     testPlanConfigs: [String],
                     runtime: String,
                     arch: String,
                     platform: String,
                     deviceIds: [String],
                     outUrl: URL,
                     zipFileName: String) throws {
        let fileManager = FileManager.default

        for style in styles {
            // The following generates a long log of all devices (Useful on a CI for debugging)
//            Log.simctl.info("Found devices:", inset: 1)
//            let devicesForRT = try _list().devices
//            devicesForRT.keys.forEach({ runtime in
//                Log.simctl.info("Runtime \(runtime)", inset: 2)
//                devicesForRT[runtime]!.forEach({ device in
//                    Log.simctl.info(device, inset: 3)
//                })
//            })

            try updateStyle(style, deviceIds: deviceIds)
            try updateStatusBar(deviceIds: deviceIds)

            for scheme in schemes {
                let currentUrl = outUrl.appendingPathComponent(scheme).appendingPathComponent(style.rawValue)
                let screensUrl = currentUrl.appendingPathComponent("screens")
                let resultsBundleUrl = currentUrl.appendingPathComponent("result_bundle.xcresult")
                let xcTestRunFileList: [URL]

                let buildProductsUrl = derivedDataUrl.appending(
                    components: "Build",
                    "Products"
                )

                do {
                    // Get all file URLs in the directory
                    xcTestRunFileList = try fileManager.contentsOfDirectory(
                        at: buildProductsUrl,
                        includingPropertiesForKeys: nil
                    )
                } catch {
                    // No files found
                    throw Error.xcTestRunUnexpectedFilesFound(fileNames: [])
                }

                // Filter files by extension (case insensitive) and
                // test-plan name, assuming this directory contains exactly one
                // file for the test plan)
                let filteredFiles = xcTestRunFileList.filter {
                    $0.pathExtension.lowercased() == "xctestrun".lowercased()
                        && $0.lastPathComponent.contains(testPlanName)
                }

                guard let xcTestRunFile = filteredFiles.first, filteredFiles.count == 1 else {
                    throw Error.xcTestRunUnexpectedFilesFound(
                        fileNames: filteredFiles.map(\.lastPathComponent)
                    )
                }

                guard fileManager.fileExists(atPath: xcTestRunFile.path()) else {
                    throw Error.xcTestRunFileNotFound(path: xcTestRunFile.path())
                }

                Log.simctl.info("""
                Running test plan '\(testPlanName) (\(testPlanConfigs.isEmpty ? "all configs" : ListFormatter
                    .localizedString(byJoining: testPlanConfigs)))' for:
                    style '\(style)'
                    scheme '\(scheme)'
                    runtime: '\(runtime)'
                    platform: '\(platform)'
                    architecture: '\(arch)'
                    xctestrun: '\(xcTestRunFile.path())'
                """)

                // This command just needs the binaries and the path to the
                // xctestrun file created before the actual testing. Then
                // everything can be configured to run the tests without
                // needing the source code, i.e. the tests could be performed
                // on different machines.
                try Xcodebuild.execute(
                    subcommand: .testWithoutBuilding(
                        xcTestRunFile: xcTestRunFile,
                        resultsBundleURL: resultsBundleUrl,
                        testPlanConfigs: testPlanConfigs
                    ),
                    deviceIds: deviceIds,
                    derivedDataUrl: derivedDataUrl
                )

                Log.simctl.info(
                    "Extracting screenshots from xcresult bundle '\(resultsBundleUrl.path())' for scheme '\(scheme)' and style '\(style)'"
                )

                try fileManager.createDirectory(at: screensUrl, withIntermediateDirectories: true, attributes: nil)
                try Mint.screenshots(resultsBundleURL: resultsBundleUrl, screensURL: screensUrl)
            }
        }

        for scheme in schemes {
            Log.simctl.info("Package files into one ZIP for scheme '\(scheme)'")

            let originalDirectoryPath = fileManager.currentDirectoryPath

            // Switch into folder to prevent storage of absolute paths
            fileManager.changeCurrentDirectoryPath(outUrl.path)

            try Zip.zip(outFile: zipFileName,
                        relativeTargetFolder: scheme,
                        excludePattern: "*.xcresult*")

            // Switch back to the original directory
            fileManager.changeCurrentDirectoryPath(originalDirectoryPath)
        }
    }
}

// MARK: - Public: Supporting Types

public extension Simctl {

    enum Error: Swift.Error {
        case simctlListFailed
        case latestRuntimeNameNotFound
        case runtimeNotFound(name: String)
        case devicesNotFoundForRuntime(Runtime)
        case deviceIdNotFoundInDevices(id: String)
        case createDeviceFailed(deviceName: String, runtimeID: String)
        case createDeviceFailedInvalidRuntime(deviceName: String, runtimeID: String)
        case xcTestRunFileNotFound(path: String)
        case xcTestRunUnexpectedFilesFound(fileNames: [String])
    }

    enum Style: String, CaseIterable {
        case light
        case dark

        public var parameterName: String { rawValue }
    }

    enum DataNetwork: String {
        case wifi
        case three_g = "3g"
        case four_g = "4g"
        case lte
        case lte_a = "lte-a"
        case ltePlus = "lte+"
    }

    enum WifiMode: String {
        case active
        case searching
        case failed
    }

    enum WifiBars: Int {
        case zero
        case one
        case two
        case three
    }

    enum CellularMode: String {
        case notSupported
        case active
        case searching
        case failed
    }

    enum CellularBars: Int {
        case zero
        case one
        case two
        case three
        case four
    }

    enum BatteryState: String {
        case charged
        case charging
        case discharging
    }

    enum BatteryLevel: Int {
        case empty = 0
        case quater = 25
        case fifty = 50
        case threeQuater = 75
        case full = 100
    }
}

// MARK: - Private: Simctl Low Level Functions

private extension Simctl {

    static func _list() throws -> SimctlList {
        let out = run(bash: "xcrun simctl list --json")

        if let error = out.error {
            Log.simctl.error(out.stderror)
            throw error
        }

        guard let outData = out.stdout.data(using: .utf8) else {
            throw Error.simctlListFailed
        }

        return try Json.decoder.decode(SimctlList.self, from: outData)
    }

    static func deviceForID(_ id: String) throws -> Device {
        guard let id = try _list().devices.flatMap({ $0.value }).first(where: { $0.udid == id }) else {
            throw Error.deviceIdNotFoundInDevices(id: id)
        }
        return id
    }

    static func _boot(deviceId: String) throws {
        Log.simctl.info("Boot device \(deviceId)")

        // Wait while the simulator is booting (https://stackoverflow.com/a/56267933/971329)
        let out = run(bash: "xcrun simctl bootstatus '\(deviceId)' -b")

        if let error = out.error {
            Log.simctl.error(out.stderror)
            throw error
        }
    }

    static func _shutdown(deviceId: String = "all") throws {
        let out = run(bash: "xcrun simctl shutdown '\(deviceId)'")

        if let error = out.error {
            Log.simctl.error(out.stderror)
            throw error
        }
    }

    static func _setAppearance(for deviceId: String, style: Style) throws {
        let out = run(bash: "xcrun simctl ui '\(deviceId)' appearance '\(style.rawValue)'")

        if let error = out.error {
            Log.simctl.error(out.stderror)
            throw error
        }
    }

    /// Creates a new device in the system
    /// - Parameters:
    ///   - name: The device name
    ///   - id: The device id. This is the name of the devices shown in `xcrun simctl list`
    ///   - runtime: The runtime id. One of the ones shown in `xcrun simctl list`
    /// - Returns: The id of the created device
    static func _createDevice(name: String, id: String, runtime: Runtime) throws -> String {
        let out = run(bash: "xcrun simctl create '\(name)' '\(id)' '\(runtime.identifier)'")

        if let error = out.error {
            Log.simctl.error(out.stderror)
            throw error
        }
        return out.stdout
    }

    static func _updateStatusBar(deviceId: String,
                                 time: String = "09:41",
                                 dataNetwork: DataNetwork = .wifi,
                                 wifiMode: WifiMode = .active,
                                 wifiBars: WifiBars = .three,
                                 cellularMode: CellularMode = .active,
                                 cellularBars: CellularBars = .four,
                                 operatorName: String = "T-Mobile",
                                 batteryState: BatteryState = .charged,
                                 batteryLevel: BatteryLevel = .full) throws {
        let args: [Any] = [
            "simctl", "status_bar", deviceId, "override",
            "--time", time,
            "--dataNetwork", dataNetwork.rawValue,
            "--wifiMode", wifiMode.rawValue,
            "--wifiBars", wifiBars.rawValue,
            "--cellularMode", cellularMode.rawValue,
            "--cellularBars", cellularBars.rawValue,
            "--operatorName", operatorName,
            "--batteryState", batteryState.rawValue,
            "--batteryLevel", batteryLevel.rawValue
        ]
        let out = run("xcrun", args)

        if let error = out.error {
            Log.simctl.error(out.stderror)
            throw error
        }
    }
}
