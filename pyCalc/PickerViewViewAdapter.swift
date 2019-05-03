//
//  PickerViewAdapter.swift
//  pyCalc
//
//  Created by David New on 03/05/2019.
//  Copyright © 2019 David New. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

//From https://github.com/ReactiveX/RxSwift/blob/master/RxExample/RxExample/Examples/UIPickerViewExample/CustomPickerViewAdapterExampleViewController.swift

final class PickerViewViewAdapter
    : NSObject
    , UIPickerViewDataSource
    , UIPickerViewDelegate
    , RxPickerViewDataSourceType
, SectionedViewDataSourceType {
    typealias Element = [[CustomStringConvertible]]
    private var items: [[CustomStringConvertible]] = []
    
    func model(at indexPath: IndexPath) throws -> Any {
        return items[indexPath.section][indexPath.row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = items[component][row].description
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.blue
        
        label.font = UIFont.systemFont(ofSize: 40)
        label.textAlignment = .center
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, observedEvent: Event<Element>) {
        Binder(self) { (adapter, items) in
            adapter.items = items
            pickerView.reloadAllComponents()
            }.on(observedEvent)
    }
}


