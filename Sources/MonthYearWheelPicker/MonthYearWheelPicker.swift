//
//  MonthYearPicker.swift
//
//  Created by Ben Dodson on 15/04/2015.
//  Modified by Jiayang Miao on 24/10/2016 to support Swift 3
//  Modified by David Luque on 24/01/2018 to get default date
//  Rewritten by Ben Dodson on 01/06/2022 to support Swift 5 / SPM
//
import UIKit

/// A control for the inputting of month and year values in a view that uses a spinning-wheel or slot-machine metaphor.
open class MonthYearWheelPicker: UIPickerView {
    
    private var calendar = Calendar(identifier: .gregorian)
    private var _maximumDate: Date?
    private var _minimumDate: Date?
    private var _date: Date?
    private var months = [String]()
    private var years = [Int]()
    private var target: AnyObject?
    private var action: Selector?
    
    /// The maximum date that a picker can show.
    ///
    /// Use this property to configure the maximum date that is selected in the picker interface. The default is the current month and 15 years into the future.
    open var maximumDate: Date {
        set {
            _maximumDate = formattedDate(from: newValue)
            updateAvailableYears(animated: false)
        }
        get {
            return _maximumDate ?? formattedDate(from: calendar.date(byAdding: .year, value: 15, to: Date()) ?? Date())
        }
    }
    
    /// The minimum date that a picker can show.
    ///
    /// Use this property to configure the minimum date that is selected in the picker interface. The default is the current month and year.
    open var minimumDate: Date {
        set {
            _minimumDate = formattedDate(from: newValue)
            updateAvailableYears(animated: false)
        }
        get {
            return _minimumDate ?? formattedDate(from: Date())
        }
    }
    
    /// The date displayed by the picker.
    ///
    /// Use this property to get and set the currently selected date. The default value of this property is the date when the UIDatePicker object is created. Setting this property animates the date picker by spinning the wheels to the new date and time; if you don't want any animation to occur when you set the date, use the ``setDate(_:animated:)`` method, passing `false` for the animated parameter.
    ///
    /// - Note: If you attempt to set the date beyond the ``maximumDate``or below the ``minimumDate`` then the date will be corrected to the closest date within those bounds (i.e. if your maximum date is set to 1st June 2022 and you try to set the date as 1st January 2023, the date that will actually be set will be 1st June 2022). Also note that dates will be converted so they become the first of the month at midnight (i.e. if you set the date to 21st September 2022 @ 15:33 then the returned date will be 1st September 2022 @ 00:00).
    open var date: Date {
        set {
            setDate(newValue, animated: true)
        }
        get {
            return _date ?? formattedDate(from: Date())
        }
    }
    
    /// The month displayed by the picker.
    ///
    /// Use this property to get the current month in the Gregorian calendar starting from `1` for _January_ through to `12` for _December_.
    open var month: Int {
        return calendar.component(.month, from: date)
    }
    
    /// The year displayed by the picker.
    ///
    /// Use this property to get the current year in the Gregorian calendar.
    open var year: Int {
        return calendar.component(.year, from: date)
    }
    
    /// A completion handler to receive the month and year when the picker value is changed.
    open var onDateSelected: ((_ month: Int, _ year: Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonSetup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    /// Associates a target object and action method with the control.
    ///
    /// - parameter target: The target object—that is, the object whose action method is called. If you specify nil, UIKit searches the responder chain for an object that responds to the specified action message and delivers the message to that object.
    /// - parameter action: A selector identifying the action method to be called. This parameter must not be nil.
    /// - parameter controlEvents: A bitmask specifying the control-specific events for which the action method is called. This control only supports `.valueChanged`.
    /// - Note: `MonthYearWheelPicker` does not inherit from `UIControl` so this method is provided only as a way for it be a drop-in replacement for `UIDatePicker` in most scenarios. You can only use the `.valueChanged` control event and you may only set one active target; multiple calls to this method will mean the last call is used as the target / action.
    public func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        removeTarget()
        guard controlEvents == .valueChanged else {
            return
        }
        self.target = target as? AnyObject
        self.action = action
    }
    
    /// Stops the delivery of events to the previously set target object.
    public func removeTarget() {
        self.target = nil
        self.action = nil
    }
    
    /// Stops the delivery of events to the previously set target object.
    ///
    /// - Note: `MonthYearWheelPicker` does not inherit from `UIControl` so this method is provided only as a way for it be a drop-in replacement for `UIDatePicker` in most scenarios. The parameters used here are meaningless as any call to this method will result in the previously set target / action being removed.
    public func removeTarget(_ target: Any?, action: Selector?, for controlEvents: UIControl.Event) {
        removeTarget()
    }
    
    /// Sets the date to display in the date picker, with an option to animate the setting.
    ///
    /// - parameter date: An `NSDate` object representing the new date to display in the date picker.
    /// - parameter animated: `true` to animate the setting of the new date, otherwise `false`. The animation rotates the wheels until the new month and year is shown under the highlight rectangle.
    /// - Note: If you attempt to set the date beyond the ``maximumDate``or below the ``minimumDate`` then the date will be corrected to the closest date within those bounds (i.e. if your maximum date is set to 1st June 2022 and you try to set the date as 1st January 2023, the date that will actually be set will be 1st June 2022).
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
    
    
    // MARK: Private methods
    
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
