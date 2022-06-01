import XCTest
@testable import MonthYearWheelPicker

final class MonthYearWheelPickerTests: XCTestCase {
    
    let calendar = Calendar(identifier: .gregorian)
    
    func testDefaultMaximumDateIsStartOfMonth() throws {
        let sut = MonthYearWheelPicker()
        let date = DateComponents(calendar: calendar, year: calendar.component(.year, from: Date()), month: calendar.component(.month, from: Date()), day: 1, hour: 0, minute: 0, second: 0).date ?? Date()
        XCTAssertEqual(sut.maximumDate, date)
    }
    
    func testDefaultMinimumDateIs100YearsAgoAtStartOfMonth() throws {
        let sut = MonthYearWheelPicker()
        let date = Calendar(identifier: .gregorian).date(byAdding: .year, value: -100, to: Date()) ?? Date()
        let adjustedDate = DateComponents(calendar: calendar, year: calendar.component(.year, from: date), month: calendar.component(.month, from: date), day: 1, hour: 0, minute: 0, second: 0).date ?? Date()
        XCTAssertEqual(sut.minimumDate, adjustedDate)
    }
    
    func testDefaultNumberOfYearsIs101() throws {
        let sut = MonthYearWheelPicker()
        XCTAssertEqual(sut.pickerView(sut, numberOfRowsInComponent: 1), 101)
    }
    
    func testNumberOfYearsIs1IfMinimumDateEqualToMaximumDate() throws {
        let sut = MonthYearWheelPicker()
        sut.minimumDate = sut.maximumDate
        XCTAssertEqual(sut.pickerView(sut, numberOfRowsInComponent: 1), 1)
    }
    
    func testNumberOfYearsIs6IfMinimumDateEqualToMaximumDateMinus5Years() throws {
        let sut = MonthYearWheelPicker()
        sut.minimumDate = calendar.date(byAdding: DateComponents(year: -5), to: sut.maximumDate)!
        XCTAssertEqual(sut.pickerView(sut, numberOfRowsInComponent: 1), 6)
    }
    
    func testDefaultDateIsStartOfMonth() {
        let sut = MonthYearWheelPicker()
        let date = DateComponents(calendar: calendar, year: calendar.component(.year, from: Date()), month: calendar.component(.month, from: Date()), day: 1, hour: 0, minute: 0, second: 0).date ?? Date()
        XCTAssertEqual(sut.date, date)
    }
    
    func testDateIsLimitedToMaximumDate() {
        let sut = MonthYearWheelPicker()
        XCTAssertEqual(sut.date, sut.maximumDate) // default date and maximum date are the same
        let earlierDate = DateComponents(calendar: calendar, year: calendar.component(.year, from: sut.maximumDate) - 1, month: calendar.component(.month, from: sut.maximumDate), day: 1, hour: 0, minute: 0, second: 0).date ?? Date()
        sut.date = earlierDate
        XCTAssertNotEqual(sut.date, sut.maximumDate)
        let laterDate = DateComponents(calendar: calendar, year: calendar.component(.year, from: sut.maximumDate) + 1, month: calendar.component(.month, from: sut.maximumDate), day: 1, hour: 0, minute: 0, second: 0).date ?? Date()
        sut.date = laterDate
        XCTAssertEqual(sut.date, sut.maximumDate)
    }
    
    func testDateIsLimitedToMinimumDate() {
        let sut = MonthYearWheelPicker()
        XCTAssertNotEqual(sut.date, sut.minimumDate) // default date and minimum date are different
        let laterDate = DateComponents(calendar: calendar, year: calendar.component(.year, from: sut.minimumDate) + 1, month: calendar.component(.month, from: sut.minimumDate), day: 1, hour: 0, minute: 0, second: 0).date ?? Date()
        sut.date = laterDate
        XCTAssertNotEqual(sut.date, sut.minimumDate)
        let earlierDate = DateComponents(calendar: calendar, year: calendar.component(.year, from: sut.minimumDate) - 1, month: calendar.component(.month, from: sut.minimumDate), day: 1, hour: 0, minute: 0, second: 0).date ?? Date()
        sut.date = earlierDate
        XCTAssertEqual(sut.date, sut.minimumDate)
    }
    
    func testDefaultMonthProperty() {
        let sut = MonthYearWheelPicker()
        let month = calendar.component(.month, from: sut.date)
        XCTAssertEqual(sut.month, month)
    }
    
    func testMonthPropertyOnSeptember2nd2022() {
        let sut = MonthYearWheelPicker()
        sut.maximumDate = DateComponents(calendar: calendar, year: 2022, month: 12, day: 1, hour: 0, minute: 0, second: 0).date ?? Date()
        sut.date = DateComponents(calendar: calendar, year: 2022, month: 9, day: 2, hour: 0, minute: 0, second: 0).date ?? Date()
        XCTAssertEqual(sut.month, 9)
    }
    
    func testDefaultYearProperty() {
        let sut = MonthYearWheelPicker()
        let year = calendar.component(.year, from: sut.date)
        XCTAssertEqual(sut.year, year)
    }
    
    func testYearPropertyOnSeptember2nd2022() {
        let sut = MonthYearWheelPicker()
        sut.maximumDate = DateComponents(calendar: calendar, year: 2022, month: 12, day: 1, hour: 0, minute: 0, second: 0).date ?? Date()
        sut.date = DateComponents(calendar: calendar, year: 2022, month: 9, day: 2, hour: 0, minute: 0, second: 0).date ?? Date()
        XCTAssertEqual(sut.year, 2022)
    }
    
    func testBlockCallback() {
        let expectation = expectation(description: "onDateSelected will be called with month 9 and year 2022")
        
        var testMonth = 0
        var testYear = 0
        var count = 0
        
        let sut = MonthYearWheelPicker()
        sut.maximumDate = DateComponents(calendar: calendar, year: 2022, month: 12, day: 1, hour: 0, minute: 0, second: 0).date ?? Date()
        sut.onDateSelected = { (month, year) in
            testMonth = month
            testYear = year
            count += 1
            if count == 2 {
                expectation.fulfill()
            }
        }
        
        sut.selectRow(8, inComponent: 0, animated: false)
        sut.pickerView(sut, didSelectRow: 8, inComponent: 0)
        sut.selectRow(100, inComponent: 1, animated: false)
        sut.pickerView(sut, didSelectRow: 100, inComponent: 1)
        
        waitForExpectations(timeout: 1) { _ in
            XCTAssertEqual(testMonth, 9)
            XCTAssertEqual(testYear, 2022)
        }
    }
    
}
