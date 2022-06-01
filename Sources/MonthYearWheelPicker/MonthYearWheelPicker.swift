//
//  MonthYearPicker.swift
//
//  Created by Ben Dodson on 15/04/2015.
//  Modified by Jiayang Miao on 24/10/2016 to support Swift 3
//  Modified by David Luque on 24/01/2018 to get default date
//  Rewritten by Ben Dodson on 01/06/2022 to support Swift 5 / SPM
//
import UIKit

open class MonthYearWheelPicker: UIPickerView {
    
    private var calendar = Calendar(identifier: .gregorian)
    
    private var _maximumDate: Date?
    open var maximumDate: Date {
        set {
            _maximumDate = formattedDate(from: newValue)
            updateAvailableYears(animated: false)
        }
        get {
            return _maximumDate ?? formattedDate(from: Date())
        }
    }
    
    private var _minimumDate: Date?
    open var minimumDate: Date {
        set {
            _minimumDate = formattedDate(from: newValue)
            updateAvailableYears(animated: false)
        }
        get {
            return _minimumDate ?? formattedDate(from: calendar.date(byAdding: .year, value: -100, to: Date()) ?? Date())
        }
    }
    
    private var _date: Date?
    open var date: Date {
        set {
            setDate(newValue, animated: false)
        }
        get {
            return _date ?? formattedDate(from: Date())
        }
    }
    
    open var month = Calendar(identifier: .gregorian).component(.month, from: Date()) {
        didSet {
            selectRow(month - 1, inComponent: 0, animated: false)
        }
    }
    
    open var year = Calendar(identifier: .gregorian).component(.year, from: Date()) {
        didSet {
            if let firstYearIndex = years.firstIndex(of: year) {
                selectRow(firstYearIndex, inComponent: 1, animated: true)
            }
        }
    }
    
    open var onDateSelected: ((_ month: Int, _ year: Int) -> Void)?
    
    private var months = [String]()
    private var years = [Int]()
    private var target: AnyObject?
    private var action: Selector?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonSetup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func formattedDate(from date: Date) -> Date {
        return DateComponents(calendar: calendar, year: calendar.component(.year, from: date), month: calendar.component(.month, from: date), day: 1, hour: 0, minute: 0, second: 0).date ?? Date()
    }
    
    private func updateAvailableYears(animated: Bool) {
        var years = [Int]()
        
        let startYear = calendar.component(.year, from: minimumDate)
        let endYear = max(calendar.component(.year, from: maximumDate), startYear)
        
        while years.last != endYear {
            years.append((years.last ?? startYear - 1) + 1)
        }
        self.years = years
        
        updatePickers(animated: animated)
    }
    
    private func commonSetup() {
        delegate = self
        dataSource = self
        
        var months: [String] = []
        var month = 0
        for _ in 1...12 {
            months.append(DateFormatter().monthSymbols[month].capitalized)
            month += 1
        }
        self.months = months
        
        updateAvailableYears(animated: false)
    }
    
    public func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        removeTarget()
        guard controlEvents == .valueChanged else {
            return
        }
        self.target = target as? AnyObject
        self.action = action
    }
    
    public func removeTarget() {
        self.target = nil
        self.action = nil
    }
    
    public func removeTarget(_ target: Any?, action: Selector?, for controlEvents: UIControl.Event) {
        removeTarget()
    }
    
    public func setDate(_ date: Date, animated: Bool) {
        let date = formattedDate(from: date)
        _date = date
        if date > maximumDate {
            setDate(maximumDate, animated: true)
            return
        }
        if date < minimumDate {
            setDate(minimumDate, animated: true)
            return
        }
        updatePickers(animated: animated)
    }
    
    private func updatePickers(animated: Bool) {
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        
        DispatchQueue.main.async {
            self.selectRow(month - 1, inComponent: 0, animated: animated)
            if let firstYearIndex = self.years.firstIndex(of: year) {
                self.selectRow(firstYearIndex, inComponent: 1, animated: animated)
            }
        }
    }
    
    private func pickerViewDidSelectRow() {
        let month = selectedRow(inComponent: 0) + 1
        let year = years[selectedRow(inComponent: 1)]
        
        self.month = month
        self.year = year
        guard let date = DateComponents(calendar: calendar, year: year, month: month, day: 1, hour: 0, minute: 0, second: 0).date else {
            fatalError("Could not generate date from components")
        }
        self.date = date
        
        if let block = onDateSelected {
            block(month, year)
        }
        
        if let target = target, let action = action {
            _ = target.perform(action, with: self)
        }
    }
}

extension MonthYearWheelPicker: UIPickerViewDelegate, UIPickerViewDataSource {
    
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return months.count
        case 1:
            return years.count
        default:
            return 0
        }
    }
    
    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerViewDidSelectRow()
        if component == 1 {
            pickerView.reloadComponent(0)
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        var text: String?
        switch component {
        case 0:
            text = months[row]
        case 1:
            text = "\(years[row])"
        default:
            return nil
        }
        
        guard let text = text else { return nil }

        var attributes = [NSAttributedString.Key: Any]()
        if #available(iOS 13.0, *) {
            attributes[.foregroundColor] = UIColor.label
        } else {
            attributes[.foregroundColor] = UIColor.black
        }
        
        if component == 0 {
            let month = row + 1
            let year = years[selectedRow(inComponent: 1)]
            if let date = DateComponents(calendar: calendar, year: year, month: month, day: 1, hour: 0, minute: 0, second: 0).date, date < minimumDate || date > maximumDate {
                if #available(iOS 13.0, *) {
                    attributes[.foregroundColor] = UIColor.secondaryLabel
                } else {
                    attributes[.foregroundColor] = UIColor.gray
                }
            }
        }
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
}
