// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "MainOffender",
	platforms: [
		.macOS(.v15),
		.macCatalyst(.v18),
		.iOS(.v18),
		.tvOS(.v18),
		.watchOS(.v11),
		.visionOS(.v2),
	],
	products: [
		.library(name: "MainOffender", targets: ["MainOffender"]),
	],
	targets: [
		.target(name: "MainOffender"),
		.testTarget(
			name: "MainOffenderTests",
			dependencies: ["MainOffender"]
		),
	]
)
