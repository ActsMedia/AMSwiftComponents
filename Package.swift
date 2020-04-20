// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AMSwiftComponents",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(name: "IBViews", targets: ["IBViews"]),
        .library(name: "MediaViewer", targets: ["MediaViewer"]),
        .library(name: "ResourceManager", targets: ["ResourceManager"]),
        .library(name: "GenericTable", targets: ["GenericTable"]),
        .library(name: "EZShare", targets: ["EZShare"]),
        .library(name: "TypeUtilities", targets: ["TypeUtilities"]),
        .library(name: "UIWrappers", targets: ["UIWrappers"]),
        .library(name: "EntityUtilities", targets: ["EntityUtilities"])
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "2.1.0")),
        .package(url: "https://github.com/Quick/Nimble.git", .exact("8.0.2")),
        .package(url: "https://github.com/onevcat/Kingfisher.git", .exact("5.13.2")),
        .package(url: "https://github.com/GottaGetSwifty/SwiftyIB.git", .branch("SPM")),
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "GenericTable",
            dependencies: ["SwiftyIB"],
            path: "ActsLibraries/GenericTable/Sources"),
        .target(
            name: "EZShare",
            dependencies: [],
            path: "ActsLibraries/EZShare/Sources"),
        .testTarget(
            name: "EZShareTests",
            dependencies: ["EZShare", "Quick", "Nimble"],
            path: "ActsLibraries/EZShare/Tests"),
        .target(
            name: "IBViews",
            dependencies: ["UIWrappers"],
            path: "ActsLibraries/IBViews/Sources"),
        .target(
            name: "MediaViewer",
            dependencies: ["UIWrappers"],
            path: "ActsLibraries/MediaViewer/Sources"),
        .target(
            name: "TypeUtilities",
            dependencies: [],
            path: "ActsLibraries/TypeUtilities/Sources"),
        .target(
            name: "ResourceManager",
            dependencies: [],
            path: "ActsLibraries/ResourceManager/Sources"),
        .testTarget(
            name: "ResourceManagerTests",
            dependencies: ["ResourceManager", "Quick", "Nimble"],
            path: "ActsLibraries/ResourceManager/Tests"),
        .target(
            name: "UIWrappers",
            dependencies: ["Kingfisher"],
            path: "ActsLibraries/UIWrappers/Sources"),
        .testTarget(
            name: "UIWrappersTests",
            dependencies: ["Kingfisher", "UIWrappers", "Quick", "Nimble"],
            path: "ActsLibraries/UIWrappers/Tests"),
        .target(
            name: "EntityUtilities",
            dependencies: [],
            path: "ActsLibraries/EntityUtilities/Sources"),
    ]
)
