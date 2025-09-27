// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "MainOffender",
	platforms: [
		.macOS(.v10_15),
		.macCatalyst(.v13),
		.iOS(.v13),
		.tvOS(.v13),
		.watchOS(.v6),
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
