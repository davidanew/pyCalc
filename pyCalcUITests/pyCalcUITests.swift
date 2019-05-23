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
    

    //Automatic test
    func testInitAndError() {
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
    
    struct TimePickerInput {
        let hours : Int
        let minutes : Int
        let seconds : Int
    }
    
    func setTimePicker(time: TimePickerInput) {
        let app = XCUIApplication()
        let timeHours = app.pickers["timeHours"]
        let timeMinutes = app.pickers["timeMinutes"]
        let timeSeconds = app.pickers["timeSeconds"]
        timeHours.pickerWheels.element.adjust(toPickerWheelValue: String(time.hours))
        timeMinutes.pickerWheels.element.adjust(toPickerWheelValue: String(format: "%02d", time.minutes))
        timeSeconds.pickerWheels.element.adjust(toPickerWheelValue: String(format: "%02d", time.seconds))
    }
    
    struct PyPickerInput {
        let thousands : Int
        let hundreds : Int
        let tens : Int
        let units : Int
    }
    
    func setPyPicker(py: PyPickerInput) {
        let app = XCUIApplication()
        let pyThousands = app.pickers["pyThousands"]
        let pyHundreds = app.pickers["pyHundreds"]
        let pyTens = app.pickers["pyTens"]
        let pyUnits = app.pickers["pyUnits"]
        pyThousands.pickerWheels.element.adjust(toPickerWheelValue: String(py.thousands))
        pyHundreds.pickerWheels.element.adjust(toPickerWheelValue: String(py.hundreds))
        pyTens.pickerWheels.element.adjust(toPickerWheelValue: String(py.tens))
        pyUnits.pickerWheels.element.adjust(toPickerWheelValue: String(py.units))
    }
    
    func setLapsPicker(numLaps: Int) {
        let app = XCUIApplication()
        let laps = app.pickers["laps"]
        laps.pickerWheels.element.adjust(toPickerWheelValue: String(numLaps))
    }
    
    func setMaxLapsPicker(numLaps: Int) {
        let app = XCUIApplication()
        let maxLaps = app.pickers["maxLaps"]
        maxLaps.pickerWheels.element.adjust(toPickerWheelValue: String(numLaps))
    }
    
    //Manual test, see if all fields are populated
    func testPopulateFields() {
        setTimePicker(time: TimePickerInput(hours: 1, minutes: 2, seconds: 3))
        setPyPicker(py: PyPickerInput(thousands: 1, hundreds: 2, tens: 3, units: 4))
        setLapsPicker(numLaps: 2)
        setMaxLapsPicker(numLaps: 3)
        Thread.sleep(forTimeInterval: 5.0)
    }
    
    //Automatic test
    func testCase() {
        let app = XCUIApplication()
        let correctedTime = app.staticTexts["correctedTime"]
        //Laser radial 60.20 5/5 3162
        setTimePicker(time: TimePickerInput(hours: 1, minutes: 0, seconds: 20))
        setPyPicker(py: PyPickerInput(thousands: 1, hundreds: 1, tens: 4, units: 5))
        setLapsPicker(numLaps: 5)
        setMaxLapsPicker(numLaps: 5)
        Thread.sleep(forTimeInterval: 1.0)
        XCTAssertEqual("3161.57", correctedTime.label)
        //Laser std 60.14 5/5 3288
        setTimePicker(time: TimePickerInput(hours: 1, minutes: 0, seconds: 14))
        setPyPicker(py: PyPickerInput(thousands: 1, hundreds: 0, tens: 9, units: 9))
        setLapsPicker(numLaps: 5)
        setMaxLapsPicker(numLaps: 5)
        Thread.sleep(forTimeInterval: 1.0)
        XCTAssertEqual("3288.44", correctedTime.label)
        //British Moth 56.28 4/5 2933
        setTimePicker(time: TimePickerInput(hours: 0, minutes: 56, seconds: 28))
        setPyPicker(py: PyPickerInput(thousands: 1, hundreds: 1, tens: 5, units: 5))
        setLapsPicker(numLaps: 4)
        setMaxLapsPicker(numLaps: 5)
        Thread.sleep(forTimeInterval: 1.0)
        XCTAssertEqual("2933.33", correctedTime.label)
    }
}

//Also make sure help system comes up, and can be dismissed

