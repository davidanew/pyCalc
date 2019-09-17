//  Copyright © 2019 David New. All rights reserved.

import XCTest

class pyCalcUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
        XCUIApplication().launch()
    }

    //Automatic test
    func testInitAndError() {
        let app = XCUIApplication()
        //test initial conditions
        let correctedTime = app.staticTexts["correctedTime"]
        //XCTAssertEqual("", correctedTime.label)
        XCTAssertFalse(correctedTime.exists)
        //print(correctedTime.exists
        let outputLabel = app.staticTexts["outputLabel"]
        XCTAssertEqual("Please set Elasped Time", outputLabel.label)
        //test error texts
        let timeHours = app.pickers["timeHours"]
        timeHours.pickerWheels.element.adjust(toPickerWheelValue: "1")
        Thread.sleep(forTimeInterval: 1.0)
        XCTAssertEqual("Please set handicap", outputLabel.label)
        let pyThousands = app.pickers["pyThousands"]
        pyThousands.pickerWheels.element.adjust(toPickerWheelValue: "1")
        Thread.sleep(forTimeInterval: 1.0)
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
        setTimePicker(time: TimePickerInput(hours: 0, minutes: 56, seconds: 28)) //3388
        setPyPicker(py: PyPickerInput(thousands: 1, hundreds: 1, tens: 5, units: 5))
        setLapsPicker(numLaps: 4)
        setMaxLapsPicker(numLaps: 5)
        Thread.sleep(forTimeInterval: 1.0)
        XCTAssertEqual("3666.67", correctedTime.label)
    }
    
    func testHelp() {
        let app = XCUIApplication()
        app.buttons.firstMatch.tap()
        Thread.sleep(forTimeInterval: 1.0)
        app.alerts.element.buttons["OK"].tap()
        Thread.sleep(forTimeInterval: 1.0)
    }
    
    //Note that this doesn't work well as a memory test
    func testMemory() {
        while (true) {
          //  testHelp()
            testPopulateFields()
          //  testCase()
            
        }
    }
    
    //auto test
    func testExtremes() {
        let app = XCUIApplication()
        let correctedTime = app.staticTexts["correctedTime"]
        let outputLabel = app.staticTexts["outputLabel"]
        //low value
        setTimePicker(time: TimePickerInput(hours: 0, minutes: 0, seconds: 1))
        setPyPicker(py: PyPickerInput(thousands: 9, hundreds: 9, tens: 9, units: 9))
        setLapsPicker(numLaps: 1)
        setMaxLapsPicker(numLaps: 1)
        Thread.sleep(forTimeInterval: 1.0)
        XCTAssertEqual("0.1", correctedTime.label)
        //div zero
        setTimePicker(time: TimePickerInput(hours: 1, minutes: 0, seconds: 0))
        setPyPicker(py: PyPickerInput(thousands: 0, hundreds: 0, tens: 0, units: 0))
        setLapsPicker(numLaps: 1)
        setMaxLapsPicker(numLaps: 1)
        Thread.sleep(forTimeInterval: 1.0)
        XCTAssertEqual("Please set handicap", outputLabel.label)
        //high value
        setTimePicker(time: TimePickerInput(hours: 9, minutes: 59, seconds: 59))
        setPyPicker(py: PyPickerInput(thousands: 0, hundreds: 0, tens: 0, units: 1))
        setLapsPicker(numLaps: 1)
        setMaxLapsPicker(numLaps: 99)
        Thread.sleep(forTimeInterval: 1.0)
        //let expectedValue = (9.0 * 60.0 * 60.0 + 59.0 * 60.0 + 59) * (99.0 / 1.0) * (1000.0 / 1)
        //print ("expected value is \(expectedValue)")
        //print (correctedTime.label)
        XCTAssertEqual("3.5639007e+09", correctedTime.label)
    }
    
    func testAuto() {
        testInitAndError()
        testHelp() // not auto
        testPopulateFields() //not auto
        testCase()
        testExtremes()
    }
}


