// swift-tools-version: 6.0
import PackageDescription

// The WellSpent Extension Kit: what an extension to WellSpent Budget builds
// on. The app's colours, a place to keep a secret, and the contract for what
// an extension may read from and write to a person's budget. The app and
// every extension depend on this package, and on nothing of each other's.
let package = Package(
    name: "WellSpentExtensionKit",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(name: "WellSpentExtensionKit", targets: ["WellSpentExtensionKit"]),
    ],
    targets: [
        .target(name: "WellSpentExtensionKit"),
        .testTarget(name: "WellSpentExtensionKitTests", dependencies: ["WellSpentExtensionKit"]),
    ]
)
