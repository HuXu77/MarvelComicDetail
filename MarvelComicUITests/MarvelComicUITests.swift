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
        XCTAssertTrue(title.exists)
        let description = app.staticTexts["WILL THE PUNISHER’S WAR END? Born of tragedy. Devoted to war. Unstoppable in his rage. As the Punisher, Frank Castle has become the most accomplished killer the world has ever seen. Now it’s time for him to face his true destiny. What shocking secret from Frank’s past will convince him to take the reins of the Marvel Universe’s most notorious clan of assassins? And once Frank becomes the warlord of the deadly ninjas of the Hand, will it also mean an end for the Punisher? Or a whole new bloody beginning? Join the superstar team of writer Jason Aaron and artists Jesْs Saiz and Paul Azaceta for an epic exploration of the dark and violent past and inevitable future of one of Marvel’s most iconic characters."]
        XCTAssertTrue(description.exists)
    }
    
    func testImageUI() throws {
        let image = app.images["Comic image"]
        XCTAssertTrue(image.exists)
    }
}
