//
//  Simctl.swift
//  
//
//  Created by Stefan Herold on 24.09.20.
//

import Foundation
import Engine
import SwiftShell

public struct Simctl {

}

// MARK: - Public: Simctl Convenience Functions

public extension Simctl {

    static func latestAvailableIOS() throws -> String {
        guard let platformName = try Simctl
            ._list()
            .runtimes
            .sorted(by: { $0.version > $1.version })
            .first(where: { $0.name.starts(with: "iOS") })?
            .name else {
                throw Error.latestPlatformNameNotFound
        }
        return platformName
    }

    static func isPlatformValid(_ platform: String) throws -> Bool {
        try Simctl._list().runtimes.first { $0.name == platform } != nil
    }

    static func runtimeForPlatform(_ platform: String) throws -> Runtime {
        guard let runtime = try Simctl._list().runtimes.first(where: { $0.name == platform }) else {
            throw Error.runtimeNotFoundForPlatform(platform)
        }
        return runtime
    }

    static func devicesForRuntime(_ runtime: Runtime) throws -> [Device] {
        guard let devices = try Simctl._list().devices.first(where: { $0.key == runtime.identifier }).map({ $0.value }) else {
            throw Error.devicesNotFoundForRuntime(runtime)
        }
        return devices
    }

    static func deviceIdsFor(deviceTypes: [DeviceType], runtime: Runtime) throws -> [String] {
        var deviceIDs: [String] = []

        try deviceTypes.forEach { (deviceType) in
            guard let deviceID = try devicesForRuntime(runtime).first(where: { $0.name == deviceType.simCtlValue }) else {
                // Create device if it is not yet available
                let deviceID = try createDevice(name: deviceType.simCtlValue, id: deviceType.simCtlValue, runtime: runtime)
                deviceIDs.append(deviceID)
                return
            }
            deviceIDs.append(deviceID.udid)
        }
        return deviceIDs
    }

    static func killAllSimulators(logInset: Int = 0) {
        Logger.shared.info("Killing all open simulators", inset: logInset)

        try? runAndPrint(bash: "killall Simulator")
        try? runAndPrint(bash: "killall iPhone Simulator")
//        try? runAndPrint(bash: "killall -10 com.apple.CoreSimulator.CoreSimulatorService")
    }

    static func createDevice(name: String, id: String, runtime: Runtime) throws -> String {
        Logger.shared.info("Create device \(id) with name \"\(name)\" and runtime \(runtime)", inset: 1)
        return try Simctl._createDevice(name: name, id: id, runtime: runtime)
    }

    static func updateStyle(_ style: Style, deviceIds: [String]) throws {
        try deviceIds.forEach {
            Logger.shared.info("Set style \(style) for device \($0)", inset: 1)
            try _boot(deviceId: $0, logInset: 1)
            try _setAppearance(for: $0, style: style)
        }
    }

    static func updateStatusBar(deviceIds: [String]) throws {
        try deviceIds.forEach {
            Logger.shared.info("Set statusbar for device \($0)", inset: 1)

            try _boot(deviceId: $0, logInset: 1)
            try _updateStatusBar(deviceId: $0)
        }
    }

    static func snap(styles: [Style],
                     workspace: String,
                     schemes: [String],
                     testPlanName: String?,
                     deviceIds: [String],
                     outURL: URL,
                     zipFileName: String) throws {

        for style in styles {
            // The following generates a long log of all devices (Useful on a CI for debugging)
//            Logger.shared.info("Found devices:", inset: 1)
//            let devicesForRT = try _list().devices
//            devicesForRT.keys.forEach({ runtime in
//                Logger.shared.info("Runtime \(runtime)", inset: 2)
//                devicesForRT[runtime]!.forEach({ device in
//                    Logger.shared.info(device, inset: 3)
//                })
//            })

            try updateStyle(style, deviceIds: deviceIds)
            try updateStatusBar(deviceIds: deviceIds)

            for scheme in schemes {
                let currentURL = outURL.appendingPathComponent(scheme).appendingPathComponent(style.rawValue)
                let resultsBundleURL = currentURL.appendingPathComponent("result_bundle.xcresult")
                let screensURL = currentURL.appendingPathComponent("screens")

                let testPlanName = testPlanName ?? "\(scheme)-Screenshots"
                Logger.shared.info("Running test plan '\(testPlanName)' for scheme '\(scheme)' and style '\(style)'", inset: 1)

                // This command just needs the binaries and the path to the xctestrun file created before the actual
                // testing. There everything can be configured to run the tests without needing the source code,
                // i.e. the tests could be performed on different machines.
                try Xcodebuild.execute(
                    cmd: .testWithoutBuilding,
                    workspace: workspace,
                    schemes: [scheme],
                    deviceIds: deviceIds,
                    testPlan: testPlanName,
                    resultsBundleURL: resultsBundleURL)

                Logger.shared.info("Extracting screenshots from xcresult bundle '\(resultsBundleURL.path)' for scheme '\(scheme)' and style '\(style)'", inset: 2)

                try FileManager.default.createDirectory(at: screensURL, withIntermediateDirectories: true, attributes: nil)
                try Mint.screenshots(resultsBundleURL: resultsBundleURL, screensURL: screensURL)
            }
        }

        for scheme in schemes {
            Logger.shared.info("Package files into one ZIP for scheme '\(scheme)'", inset: 1)

            let originalDirectoryPath = FileManager.default.currentDirectoryPath

            // Switch into folder to prevent storage of absolute paths
            FileManager.default.changeCurrentDirectoryPath(outURL.path)

            try Zip.zip(outFile: zipFileName,
                        relativeTargetFolder: scheme,
                        excludePattern: "*.xcresult*")

            // Switch back to the original directory
            FileManager.default.changeCurrentDirectoryPath(originalDirectoryPath)
        }
    }
}

// MARK: - Public: Supporting Types

public extension Simctl {

    enum Error: Swift.Error {
        case simctlListFailed
        case latestPlatformNameNotFound
        case runtimeNotFoundForPlatform(String)
        case devicesNotFoundForRuntime(Runtime)
        case deviceIdNotFoundInDevices(id: String)
        case createDeviceFailed(deviceName: String, runtimeID: String)
        case createDeviceFailedInvalidRuntime(deviceName: String, runtimeID: String)
    }

    enum Style: String, CaseIterable {
        case light
        case dark

        public var parameterName: String { rawValue }
    }

//    "Apple TV 4K (2nd generation)"
//    "Apple TV 4K (at 1080p) (2nd generation)"
//    "Apple TV 4K (at 1080p)"
//    "Apple TV 4K"
//    "Apple TV"
//    "Apple Watch SE - 40mm"
//    "Apple Watch SE - 44mm"
//    "Apple Watch Series 3 - 38mm"
//    "Apple Watch Series 3 - 42mm"
//    "Apple Watch Series 4 - 40mm"
//    "Apple Watch Series 4 - 44mm"
//    "Apple Watch Series 5 - 40mm"
//    "Apple Watch Series 5 - 44mm"
//    "Apple Watch Series 6 - 40mm"
//    "Apple Watch Series 6 - 44mm"
//    "iPad (5th generation)"
//    "iPad (6th generation)"
//    "iPad (7th generation)"
//    "iPad (8th generation)"
//    "iPad Air (3rd generation)"
//    "iPad Air (4th generation)"
//    "iPad Air 2"
//    "iPad Air"
//    "iPad Pro (10.5-inch)"
//    "iPad Pro (11-inch) (1st generation)"
//    "iPad Pro (11-inch) (2nd generation)"
//    "iPad Pro (11-inch) (3rd generation)"
//    "iPad Pro (12.9-inch) (1st generation)"
//    "iPad Pro (12.9-inch) (2nd generation)"
//    "iPad Pro (12.9-inch) (3rd generation)"
//    "iPad Pro (12.9-inch) (4th generation)"
//    "iPad Pro (12.9-inch) (5th generation)"
//    "iPad Pro (9.7-inch)"
//    "iPad mini (5th generation)"
//    "iPad mini 2"
//    "iPad mini 3"
//    "iPad mini 4"
//    "iPhone 8 Plus"
//    "iPhone 8"

    enum DeviceType: String, CaseIterable {
        // DEPRECATED: Use `iPhoneSE2` instead
        case iPhoneSE
        case iPhoneSE2
        case iPhoneSE3
        case iPhone11
        case iPhone11Pro
        case iPhone11ProMax
        case iPhone12Mini
        case iPhone12
        case iPhone12Pro
        case iPhone12ProMax
        case iPhone13Mini
        case iPhone13
        case iPhone13Pro
        case iPhone13ProMax

        public var parameterName: String { rawValue }

        public var simCtlValue: String {
            switch self {
            case .iPhoneSE: return "iPhone SE (2nd generation)"
            case .iPhoneSE2: return "iPhone SE (2nd generation)"
            case .iPhoneSE3: return "iPhone SE (3rd generation)"
            case .iPhone11: return "iPhone 11"
            case .iPhone11Pro: return "iPhone 11 Pro"
            case .iPhone11ProMax: return "iPhone 11 Pro Max"
            case .iPhone12Mini: return "iPhone 12 mini"
            case .iPhone12: return "iPhone 12"
            case .iPhone12Pro: return "iPhone 12 Pro"
            case .iPhone12ProMax: return "iPhone 12 Pro Max"
            case .iPhone13Mini: return "iPhone 13 mini"
            case .iPhone13: return "iPhone 13"
            case .iPhone13Pro: return "iPhone 13 Pro"
            case .iPhone13ProMax: return "iPhone 13 Pro Max"
            }
        }
    }

    /// This enum represents only the latest iOS versions from a major version.
    /// Omit the platform parameter to use the latest available version. This
    /// enum is updated after a new version comes out.
    enum Platform: String, CaseIterable {
        case ios12_4 = "iOS 12.4"
        case ios13_7 = "iOS 13.6"
        case ios14_5 = "iOS 14.5"
        case ios15_0 = "iOS 15.0"
        case ios16_0 = "iOS 16.0"

        public var parameterName: String { "\(self)" }
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
        case active, searching, failed
    }

    enum WifiBars: Int {
        case zero, one, two, three
    }

    enum CellularMode: String {
        case notSupported, active, searching, failed
    }

    enum CellularBars: Int {
        case zero, one, two, three, four
    }

    enum BatteryState: String {
        case charged, charging, discharging
    }

    enum BatteryLevel: Int {
        case empty = 0, quater = 25, fifty = 50, threeQuater = 75, full = 100
    }
}

// MARK: - Private: Simctl Low Level Functions

private extension Simctl {

    static func _list() throws -> SimctlList {
        let out = run(bash: "xcrun simctl list --json")

        if let error = out.error {
            Logger.shared.error(out.stderror)
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

    static func _boot(deviceId: String, logInset: Int = 0) throws {
        Logger.shared.info("Boot device \(deviceId)", inset: logInset)

        // Wait while the simulator is booting (https://stackoverflow.com/a/56267933/971329)
        let out = run(bash: "xcrun simctl bootstatus '\(deviceId)' -b")

        if let error = out.error {
            Logger.shared.error(out.stderror)
            throw error
        }
    }

    static func _shutdown(deviceId: String = "all") throws {
        let out = run(bash: "xcrun simctl shutdown '\(deviceId)'")

        if let error = out.error {
            Logger.shared.error(out.stderror)
            throw error
        }
    }

    static func _setAppearance(for deviceId: String, style: Style) throws {
        let out = run(bash: "xcrun simctl ui '\(deviceId)' appearance '\(style.rawValue)'")

        if let error = out.error {
            Logger.shared.error(out.stderror)
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
            Logger.shared.error(out.stderror)
            throw error
        }
        return out.stdout
    }

    static func _updateStatusBar(deviceId: String,
                                time: String = "12:00",
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
            Logger.shared.error(out.stderror)
            throw error
        }
    }
}
