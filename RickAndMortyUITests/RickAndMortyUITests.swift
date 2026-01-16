//
//  RickAndMortyUITests.swift
//  RickAndMortyUITests
//
//  Created by ashim Dahal on 1/15/26.
//

import XCTest

final class RickAndMortyUITests: XCTestCase {

    func testSearchDisplaysResults() {
        let app = XCUIApplication()
        app.launch()

        let searchField = app.textFields.firstMatch
        searchField.tap()
        searchField.typeText("rick")

        XCTAssertTrue(app.staticTexts["Rick Sanchez"].waitForExistence(timeout: 3))
    }
}
