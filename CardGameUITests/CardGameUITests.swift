//
//  CardGameUITests.swift
//  CardGameUITests
//
//  Created by Russell Leon Bates IV on 5/28/25.
//

import XCTest

final class CardGameUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testMainScreenShowsSelectedCharacterSummaryAndActiveClocksTogether() throws {
        let app = launchApp(state: "pressure")

        XCTAssertTrue(app.descendants(matching: .any)["selectedCharacterSummaryStrip"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["condensedClockPanel"].waitForExistence(timeout: 5))
    }

    func testActionRowsExposeRiskAndImpactBeforeOpeningRollScreen() throws {
        let app = launchApp()

        XCTAssertTrue(app.descendants(matching: .any)["actionForecastRiskChip"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["actionForecastImpactChip"].firstMatch.waitForExistence(timeout: 5))
    }

    func testRollForecastHintDismissalSuppressesRepeatDisplay() throws {
        let app = launchApp()

        openFirstTestAction(in: app)

        XCTAssertTrue(app.descendants(matching: .any)["rollForecastScreen"].waitForExistence(timeout: 5))
        let hint = app.descendants(matching: .any)["guidanceHint_rollForecast"]
        XCTAssertTrue(hint.waitForExistence(timeout: 5))

        let dismissButton = app.buttons["guidanceHintDismiss_rollForecast"]
        XCTAssertTrue(dismissButton.waitForExistence(timeout: 5))
        dismissButton.tap()
        XCTAssertFalse(hint.exists)

        closeDiceRollView(in: app)

        openFirstTestAction(in: app)

        XCTAssertTrue(app.descendants(matching: .any)["rollForecastScreen"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.descendants(matching: .any)["guidanceHint_rollForecast"].waitForExistence(timeout: 1))
    }

    func testResistancePromptShowsHelperCopy() throws {
        let app = launchApp(fixedDice: "1")

        openFirstTestAction(in: app)

        tapRollButton(in: app)

        XCTAssertTrue(app.descendants(matching: .any)["guidanceHint_resistancePrompt"].waitForExistence(timeout: 10))
    }

    func testSplitPartyStateShowsBannerAndSelectedCharacterLocation() throws {
        let app = launchApp(state: "split")

        XCTAssertTrue(app.descendants(matching: .any)["contextualBanner_split"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["selectedCharacterSummaryLocation"].waitForExistence(timeout: 5))
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                let app = XCUIApplication()
                app.launch()
            }
        }
    }

    @discardableResult
    private func launchApp(
        state: String = "fresh",
        fixedDice: String? = nil
    ) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["CODEX_DEBUG_SCREEN"] = "content"
        app.launchEnvironment["CODEX_DEBUG_SCENARIO"] = "temple_of_terror"
        app.launchEnvironment["CODEX_DEBUG_STATE"] = state
        app.launchEnvironment["CODEX_RESET_GUIDANCE_HINTS"] = "1"

        if let fixedDice {
            app.launchEnvironment["CODEX_DEBUG_FIXED_DICE"] = fixedDice
        }

        app.launch()
        return app
    }

    private func openFirstTestAction(in app: XCUIApplication) {
        let actionButton = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Review the sketches")).firstMatch
        XCTAssertTrue(actionButton.waitForExistence(timeout: 5))
        actionButton.tap()
    }

    private func tapRollButton(in app: XCUIApplication) {
        let rollButton = app.buttons["rollDiceButton"]
        XCTAssertTrue(rollButton.waitForExistence(timeout: 5))

        if !rollButton.isHittable {
            app.swipeUp()
        }

        rollButton.tap()
    }

    private func closeDiceRollView(in app: XCUIApplication) {
        let closeButton = app.buttons["closeDiceRollViewButton"]
        XCTAssertTrue(closeButton.waitForExistence(timeout: 5))
        closeButton.tap()
    }
}
