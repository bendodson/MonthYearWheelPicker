# MonthYearWheelPicker

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbendodson%2FMonthYearWheelPicker%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/bendodson/MonthYearWheelPicker) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbendodson%2FMonthYearWheelPicker%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/bendodson/MonthYearWheelPicker)

> **If you're targeting iOS 17.4 or above, you can now use [UIDatePicker.Mode.yearAndMonth](https://developer.apple.com/documentation/uikit/uidatepicker/mode/yearandmonth) which makes this package obsolete.**

A `UIPickerView` subclass that allows you to quickly add a picker for just month and year; in most cases it can be used as a drop-in replacement for `UIDatePicker`.  This is useful when you want to do something like an expiration date picker for a credit card where you are only interested in the month and year and so a `UIDatePicker` is not appropriate.

The current version is written in Swift 5.6 and is supported on iOS 10 and above.

If you want to use this in SwiftUI, I've [written a basic sample](https://github.com/bendodson/MonthYearWheelPicker/issues/19) to demonstrate how you can rewrite this entire project in SwiftUI as usually easier than porting it in via UIViewRepresentable.

## Example Usage
	let expiryDatePicker = MonthYearWheelPicker()
	expiryDatePicker.onDateSelected = { (month, year) in
		let string = String(format: "%02d/%d", month, year)
		// will show something like 06/2022
	}
	
MonthYearWheelPicker uses a block-based `onDateSelected` method to return the month and year to you upon selection within the picker. You can also use a target and selector to get a callback when the value changes if you prefer it to act more like `UIDatePicker`. For example:

	monthYearWheelPicker.addTarget(self, action: #selector(monthYearWheelPickerDidChange), for: .valueChanged)

	@objc private func monthYearWheelPickerDidChange() {
        let date = monthYearWheelPicker.date
        // A standard date object that will be your selected month and year with day set to 1 and time set to 00:00:00
    }

By default, the picker is set to a minimum date of the current month and year and a maximum date of the current month and 15 years in the future (as this makes sense for the most common usage of an expiration date picker for payment processing). This can be changed using the `minimumDate` and `maximumDate` properties. Just like `UIDatePicker`, invalid dates are shown in grey and will animate you back to a valid date (i.e. if your maximum date is June 2022, then when you scroll to September if will be greyed out and will scroll you back to June; if you then changed the year to 2023, all of the months would be available to you).

There are some unit tests included for checking everything is working as well as documentation for all public methods. If you run into any problems, please [open an issue](https://github.com/bendodson/MonthYearWheelPicker/issues/new).


## Installation
Swift Package Manager: https://github.com/bendodson/MonthYearWheelPicker.git

Manually:  There is only a single file to power the MonthYearWheelPicker so you can just download and add [MonthYearWheelPicker.swift](Sources/MonthYearWheelPicker/MonthYearWheelPicker.swift).


![MonthYearWheelPicker being used as a keyboard input](example.jpg?raw=true)

* _This project was previously named MonthYearPickerView; it was renamed to MonthYearWheelPicker to make it clear that this uses the wheel based picker view rather than the date picker design as used by iOS 13.4 and above._
