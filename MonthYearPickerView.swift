//
//  MonthYearPicker.swift
//
//  Created by Ben Dodson on 15/04/2015.
//

import UIKit

open class MonthYearPickerView: UIPickerView {
    
    private let dateFormatter: DateFormatter = {
        return DateFormatter()
    }()
    
    private let calendar: Calendar = {
        return Calendar(identifier: .gregorian)
    }()
    
    private lazy var months: [String] = {
        return (0...11).reduce([String]()) {
            $0 + [dateFormatter.monthSymbols[$1].capitalized]
        }
    }()
    
    private lazy var years: [Int] = {
        let currentYear = calendar.component(.year, from: Date())
        return (currentYear...currentYear + 15).reduce([Int]()) { $0 + [$1] }
    }()
    
    public var month: Int = 0 {
        didSet { selectRow(month - 1, inComponent: 0, animated: false) }
    }
    
    public var year: Int = 0 {
        didSet { selectRow(years.index(of: year)!, inComponent: 1, animated: true) }
    }
    
    public var dateChanged: ((_ month: Int, _ year: Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUp()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setUp()
    }
    
    private func setUp() {
        delegate = self
        dataSource = self
        
        month = calendar.component(.month, from: Date())
        year = calendar.component(.year, from: Date())
    }
}

extension MonthYearPickerView: UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return months.count
        case 1: return years.count
        default: return 0
        }
    }
}

extension MonthYearPickerView: UIPickerViewDelegate {
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0: return months[row]
        case 1: return "\(years[row])"
        default: return nil
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        month = selectedRow(inComponent: 0) + 1
        year = years[selectedRow(inComponent: 1)]
        dateChanged?(month, year)
    }
}

