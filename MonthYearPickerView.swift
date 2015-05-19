//
//  MonthYearPicker.swift
//
//  Created by Ben Dodson on 15/04/2015.
//

import UIKit

class MonthYearPickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {

    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    let years: [Int]!
    
    
    var month: Int = 0 {
        didSet {
            selectRow(month-1, inComponent: 0, animated: false)
        }
    }
    
    var year: Int = 0 {
        didSet {
            selectRow(find(years, year)!, inComponent: 1, animated: false)
        }
    }
    
    var onDateSelected: ((month: Int, year: Int) -> Void)?
    
    override init(frame: CGRect) {
        var years: [Int] = []
        if years.count == 0 {
            var year = NSCalendar(identifier: NSCalendarIdentifierGregorian)!.component(.CalendarUnitYear, fromDate: NSDate())
            for i in 1...15 {
                years.append(year)
                year++
            }
        }
        self.years = years
        
        super.init(frame: frame)

        self.delegate = self
        self.dataSource = self
        
        var month = NSCalendar(identifier: NSCalendarIdentifierGregorian)!.component(.CalendarUnitMonth, fromDate: NSDate())
        self.selectRow(month-1, inComponent: 0, animated: false)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // Mark: UIPicker Delegate / Data Source
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        switch component {
        case 0:
            return months[row]
        case 1:
            return "\(years[row])"
        default:
            return ""
        }
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return months.count
        case 1:
            return years.count
        default:
            return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let month = self.selectedRowInComponent(0)+1
        let year = years[self.selectedRowInComponent(1)]
        if let block = onDateSelected {
            block(month: month, year: year)
        }
        
        self.month = month
        self.year = year
    }
    
}
