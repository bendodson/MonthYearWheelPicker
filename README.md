# MonthYearPickerView-Swift
A simple UIPickerView subclass (in Swift) that allows you to quickly add a picker for just month and year.  This is useful when you want to do something like an expiration date picker for a credit card.

## Example Usage
	let expiryDatePicker = MonthYearPickerView()
	expiryDatePicker.onDateSelected = { (month: Int, year: Int) in
		let string = String(format: "%02d/%d", month, year)
		NSLog(string) // should show something like 05/2015
	}
	
The MonthYearPickerView uses a simple block-based "onDateSelected" method to return the date to you upon selection. By default, it selects the current month and year and shows upto 15 years in the future - this can be adapted easily should you wish you use this for something other than expiry dates.

![MonthYearPickerView-Swift being used as a keyboard input](example.jpg?raw=true)