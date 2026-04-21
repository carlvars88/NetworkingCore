// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NetworkingCore",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(name: "NetworkingCore",              targets: ["NetworkingCore"]),
        .library(name: "NetworkingCoreTestUtilities", targets: ["NetworkingCoreTestUtilities"]),
    ],
    targets: [
        .target(name: "NetworkingCore"),
        .target(
            name: "NetworkingCoreTestUtilities",
            dependencies: ["NetworkingCore"]
        ),
        .testTarget(
            name: "NetworkingCoreTests",
            dependencies: ["NetworkingCore", "NetworkingCoreTestUtilities"]
        ),
    ]
)
