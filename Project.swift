import ProjectDescription

let project = Project(
    name: "JSMacroChart",
    targets: [
        .target(
            name: "JSMacroChart",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.JSMacroChart",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["JSMacroChart/Sources/**"],
            resources: ["JSMacroChart/Resources/**"],
            dependencies: []
        ),
        .target(
            name: "JSMacroChartTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.JSMacroChartTests",
            infoPlist: .default,
            sources: ["JSMacroChart/Tests/**"],
            resources: [],
            dependencies: [.target(name: "JSMacroChart")]
        ),
    ]
)
