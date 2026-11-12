// swift-tools-version: 6.0
import PackageDescription

// The WellSpent Extension Kit: what an extension to WellSpent Budget builds
// on. The app's colours, a place to keep a secret, and the contract for what
// an extension may read from and write to a person's budget. The app and
// every extension depend on this package, and on nothing of each other's.
//
// WellSpentExtensionKitLinux is what an extension needs to draw on Linux with
// SwiftCrossUI: the names and states a screen reader hears, set on GTK's own
// widgets. Linux only.
//
// The Linux pieces, and SwiftCrossUI with them, exist only when the package is
// read on Linux. SwiftPM can't make a package dependency platform-specific, so
// a plain declaration would put SwiftCrossUI and its Android packages into
// every Mac and iPhone build that uses this kit, and into their
// Package.resolved. Xcode 26.6 crashes reading that file when Properties is
// linked. Read on a Mac, this package is the kit alone.
var products: [Product] = [
    .library(name: "WellSpentExtensionKit", targets: ["WellSpentExtensionKit"]),
]
var dependencies: [Package.Dependency] = []
var targets: [Target] = [
    .target(name: "WellSpentExtensionKit"),
    .testTarget(name: "WellSpentExtensionKitTests", dependencies: ["WellSpentExtensionKit"]),
]

#if os(Linux)
products.append(.library(name: "WellSpentExtensionKitLinux", targets: ["WellSpentExtensionKitLinux"]))
// Pinned exactly, the same in three places: this kit, the public repo's
// Linux/Package.swift and WellSpent-Properties. SwiftPM resolves one
// version for the whole app, so the three pins move together.
dependencies.append(.package(url: "https://github.com/stackotter/swift-cross-ui.git", exact: "0.10.0"))
targets += [
        .systemLibrary(name: "WellSpentKitGtk", pkgConfig: "gtk4"),
        // The C side: GTK's accessibility calls. Its sources are empty off Linux.
        .target(name: "WellSpentExtensionKitLinuxNative", dependencies: [
            .target(name: "WellSpentKitGtk", condition: .when(platforms: [.linux])),
        ]),
        .target(name: "WellSpentExtensionKitLinux", dependencies: [
            "WellSpentExtensionKitLinuxNative",
            .product(name: "SwiftCrossUI", package: "swift-cross-ui", condition: .when(platforms: [.linux])),
            .product(name: "GtkBackend", package: "swift-cross-ui", condition: .when(platforms: [.linux])),
        ]),
]
#endif

let package = Package(
    name: "WellSpentExtensionKit",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: products,
    dependencies: dependencies,
    targets: targets
)
