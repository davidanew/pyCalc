//
//  pyCalcUITests.swift
//  pyCalcUITests
//
//  Created by David New on 28/04/2019.
//  Copyright © 2019 David New. All rights reserved.
//

import XCTest

class pyCalcUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        
        let app = XCUIApplication()
        //test initial conditions
        let correctedTime = app.staticTexts["correctedTime"]
        XCTAssertEqual("", correctedTime.label)
        let outputLabel = app.staticTexts["outputLabel"]
        XCTAssertEqual("Please set Elasped Time", outputLabel.label)
        //XCTAssert(app.pickers["timeHours"].exists)
        //test error texts
        let timeHours = app.pickers["timeHours"]
        timeHours.pickerWheels.element.adjust(toPickerWheelValue: "1")
        Thread.sleep(forTimeInterval: 1.0)
        XCTAssertEqual("Please set PY", outputLabel.label)
        let pyThousands = app.pickers["pyThousands"]
        pyThousands.pickerWheels.element.adjust(toPickerWheelValue: "1")
        Thread.sleep(forTimeInterval: 1.0)
        //XCTAssertEqual("Please set PY", outputLabel.label)
        let laps = app.pickers["laps"]
        laps.pickerWheels.element.adjust(toPickerWheelValue: "2")
        Thread.sleep(forTimeInterval: 1.0)
        XCTAssertEqual("Please set max laps", outputLabel.label)
    }
}
