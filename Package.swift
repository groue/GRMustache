// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GRMustache",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "GRMustache",
            targets: ["GRMustache"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "GRMustache",
            dependencies: [],
            path: "./GRMustache",
            publicHeadersPath: "./include",
            cSettings: [
                .headerSearchPath("Compiling"),
                .headerSearchPath("Compiling/Expressions"),
                .headerSearchPath("Compiling/TemplateAST"),
                .headerSearchPath("Configuration"),
                .headerSearchPath("Parsing"),
                .headerSearchPath("Rendering"),
                .headerSearchPath("Services"),
                .headerSearchPath("Services/StandardLibrary"),
                .headerSearchPath("Shared"),
                .headerSearchPath("Templates"),
                .headerSearchPath(".")
            ]),
        // .testTarget(
        //     name: "GRMustacheTests",
        //     dependencies: ["GRMustache"]),
    ]
)