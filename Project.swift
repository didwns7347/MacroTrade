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
                    // .xcconfig 변수를 Info.plist에서 참조
                    "ALPHAVANTAGE_API_KEY": "$(ALPHAVANTAGE_API_KEY)",
                    "APP_KEY": "$(APP_KEY)",
                    "APP_SECRET": "$(APP_SECRET)",
                    "CANO": "$(CANO)",
                    "ACNT_PRDT_CD": "$(ACNT_PRDT_CD)",
                    "URL_BASE": "$(URL_BASE)",
                ]
            ),
            sources: ["JSMacroChart/Sources/**"],
            resources: ["JSMacroChart/Resources/**"],
            scripts: [
                .pre(
                    script: """
                    # Apple Silicon Homebrew 경로 추가
                    if test -d "/opt/homebrew/bin/"; then
                        PATH="/opt/homebrew/bin/:${PATH}"
                    fi

                    # SwiftLint 설치 여부 확인 및 실행
                    if which swiftlint > /dev/null; then
                        swiftlint
                    else
                        echo "warning: SwiftLint not installed, skipping."
                    fi
                    """,
                    name: "SwiftLint"
                ),
            ],
            dependencies: [],
            // XCConfig 파일을 사용하도록 설정 추가
            settings: .settings(
                base: [:],
                configurations: [
                    .debug(name: "Debug", xcconfig: "Config/Config.xcconfig"),
                    .release(name: "Release", xcconfig: "Config/Config.xcconfig")
                ]
            )
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
