//
//  TableHeaderView.swift
//  RefectoringLSB
//
//  Created by Matthew Dias on 6/13/20.
//  Copyright © 2020 Matthew Dias. All rights reserved.
//

import UIKit

class TableHeaderView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var textField: UITextField!
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return SubReddit.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textField.resignFirstResponder()
        textField.text = SubReddit.allCases[row].rawValue
        
        guard let table = UIApplication.shared.keyWindow?.rootViewController as? SubredditTableViewController else { return }
        table.get(subreddit: SubReddit.allCases[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        SubReddit.allCases[row].rawValue
    }

    var subredditPicker = UIPickerView()
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        self.accessibilityIdentifier = "table header view"

        textField.inputView = subredditPicker
        
        subredditPicker.dataSource = self
        subredditPicker.delegate = self
    }

}
