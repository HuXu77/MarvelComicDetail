//
//  MarvelComicUITests.swift
//  MarvelComicUITests
//
//  Created by Mitchell Clay on 3/15/22.
//

import XCTest

class MarvelComicUITests: XCTestCase {

    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testTextUI() throws {
        let title = app.staticTexts["Punisher (2022) #1"]
        XCTAssertTrue(title.waitForExistence(timeout: 0.5))
    }
    
    func testImageUI() throws {
        let image = app.images["Comic image"]
        XCTAssertTrue(image.waitForExistence(timeout: 0.5))
    }
}
