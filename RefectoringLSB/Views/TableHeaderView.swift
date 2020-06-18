//
//  TableHeaderView.swift
//  RefectoringLSB
//
//  Created by Matthew Dias on 6/13/20.
//  Copyright © 2020 Matthew Dias. All rights reserved.
//

import UIKit

class TableHeaderView: UIView {

    @IBOutlet weak var textField: UITextField!
    var subredditPicker = UIPickerView()
    
    // MARK: - Lifecycle
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        self.accessibilityIdentifier = "table header view"

        textField.inputView = subredditPicker
        
        subredditPicker.dataSource = self
        subredditPicker.delegate = self
    }
}

// MARK: - UIPickerViewDelegate
extension TableHeaderView: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        SubReddit.allCases[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textField.resignFirstResponder()
        textField.text = SubReddit.allCases[row].rawValue
        
        guard let table = UIApplication.shared.keyWindow?.rootViewController as? SubredditTableViewController else { return }
        table.get(subreddit: SubReddit.allCases[row])
    }
    
}

// MARK: - UIPickerViewDataSource
extension TableHeaderView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return SubReddit.allCases.count
    }
}
