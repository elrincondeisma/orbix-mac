// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Orbix",
    platforms: [.macOS(.v14)],
    dependencies: [
        // Self-updates from the appcast published with each GitHub release.
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.10.0"),
    ],
    targets: [
        .executableTarget(
            name: "Orbix",
            dependencies: [.product(name: "Sparkle", package: "Sparkle")],
            path: "Sources/Orbix",
            linkerSettings: [
                // Sparkle.framework is embedded in Orbix.app/Contents/Frameworks by build-app.sh.
                .unsafeFlags(["-Xlinker", "-rpath", "-Xlinker", "@executable_path/../Frameworks"]),
            ]
        ),
    ]
)
