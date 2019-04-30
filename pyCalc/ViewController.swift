//
//  ViewController.swift
//  pyCalc
//
//  Created by David New on 28/04/2019.
//  Copyright © 2019 David New. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    let disposeBag = DisposeBag()

    
    @IBOutlet weak var timeHours: UIPickerView!
    @IBOutlet weak var timeMinutes: UIPickerView!
    @IBOutlet weak var timeSeconds: UIPickerView!
    @IBOutlet weak var laps: UIPickerView!
    @IBOutlet weak var pyThousands: UIPickerView!
    @IBOutlet weak var pyHundreds: UIPickerView!
    @IBOutlet weak var pyTens: UIPickerView!
    @IBOutlet weak var pyUnits: UIPickerView!
    @IBOutlet weak var maxLaps: UIPickerView!
    
    
    @IBOutlet weak var correctedTime: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
       // Observable.of(1,2).bind(to: timeHours.rx.itemTitles((row, element) in
        //    return element)
        
        //print(1..5)
        
        //let x = Array(1...5).map{"\($0)"}
        
        
        
        
        
        
        
        //Observable.of(Array(0...9).map{"\($0)h"})
        //    .bind(to: timeHours.rx.itemTitles) { misc , item in
        //        return "\(item)"
        //    }.disposed(by: disposeBag)
        
        Observable.just(Array(0...59).map{"\($0)m"})
            .bind(to: timeMinutes.rx.itemTitles) { _, item in
                return "\(item)"
            }.disposed(by: disposeBag)
        
        //Observable.just(Array(0...59).map{"\($0)s"})
        //    .bind(to: timeSeconds.rx.itemTitles) { _, item in
        //        return "\(item)"
        //    }.disposed(by: disposeBag)
        
        
       // let quote = "Haters gonna hate"
       // let font = UIFont.systemFont(ofSize: 72)
      //  let attributes = [NSAttributedString.Key.font: font]
      //  let attributedQuote = NSAttributedString(string: quote, attributes: attributes)
        
        /*
        Observable.just(Array(0...59).map{"\($0)s"}).bind(to: timeSeconds.rx.itemAttributedTitles) { _, item in
            
            
            
            return NSAttributedString(string: item , attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30)])
            
            
            }.disposed(by: disposeBag)
        */
        
        
 
        Observable.just([[1, 2, 3], [5, 8, 13], [21, 34]])
            .bind(to: timeSeconds.rx.items(adapter: PickerViewViewAdapter()))
            .disposed(by: disposeBag)
 
 
        
        
        
        
        
        Observable.just([Array(1...99).map{"\($0)"}])
            .bind(to: laps.rx.items(adapter: PickerViewViewAdapter()))
            .disposed(by: disposeBag)
        
        Observable.just(Array(0...9).map{"\($0)"})
            .bind(to: pyThousands.rx.itemTitles) { _, item in
                return "\(item)"
            }.disposed(by: disposeBag)
        
        Observable.just(Array(0...9).map{"\($0)"})
            .bind(to: pyHundreds.rx.itemTitles) { _, item in
                return "\(item)"
            }.disposed(by: disposeBag)
        
        Observable.just(Array(0...9).map{"\($0)"})
            .bind(to: pyTens.rx.itemTitles) { _, item in
                return "\(item)"
            }.disposed(by: disposeBag)
        
        Observable.just(Array(0...9).map{"\($0)"})
            .bind(to: pyUnits.rx.itemTitles) { _, item in
                return "\(item)"
            }.disposed(by: disposeBag)
        
        Observable.just(Array(1...99).map{"\($0)"})
            .bind(to: maxLaps.rx.itemTitles) { _, item in
                return "\(item)"
            }.disposed(by: disposeBag)
        
        /*
        //timeHours.rx.
        let x = maxLaps.rx.itemTitles(Observable.just(Array(0...99).map{"\($0)"}))
        let y = {print("hi")}
        
        let z = maxLaps.rx.items(Observable.just(Array(0...99).map{"\($0)"}))
        */
        
        /*
        Observable.just([UIColor.red, UIColor.green, UIColor.blue])
            .bind(to: timeHours.rx.items) { _, item, _ in
                let view = UILabel()
                
                view.
                //view.backgroundColor = item
                
                return view
            }
            .disposed(by: disposeBag)
        */
        
        Observable.of(Array(0...9).map{"\($0)h"})
            .bind(to: timeHours.rx.items) { _, item, _  in
                let label = UILabel()
                label.backgroundColor = UIColor.lightGray
                label.text = item
                label.font = UIFont (name: "Helvetica Neue", size: 25)
                return label
            }.disposed(by: disposeBag)
        
        //timeHours.rowSize(forComponent: 30)
        
        
        /*
        let items = Observable.just([
            "First Item",
            "Second Item",
            "Third Item"
            ])
        
        
        items
            .bind(to: timeMinutes.rx.items) { (row, element, view) in
                guard let myView = view as? UIView else {
                    let view = UIView()
                    view.configure(with: element)
                    return view
                }
                myView.configure(with: element)
                return myView
            }
            .disposed(by: disposeBag)
 */
        
 
 
    }
    
    
    
    
    /*
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = UILabel()
        if let v = view as? UILabel { label = v }
        label.font = UIFont (name: "Helvetica Neue", size: 10)
        label.text =  "10"
        label.textAlignment = .center
        return label
    }
 */

}




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
        //label.font = UIFont.preferredFont(forTextStyle: .headline)
        
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


