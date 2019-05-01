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
    
    //let elapsedSeconds = BehaviorSubject<Int32>(value: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Observable.just([Array(0...9).map{"\($0)"}])
            .bind(to: timeHours.rx.items(adapter: PickerViewViewAdapter()))
            .disposed(by: disposeBag)
        
        Observable.just([Array(0...59).map{"\($0)"}])
            .bind(to: timeMinutes.rx.items(adapter: PickerViewViewAdapter()))
            .disposed(by: disposeBag)
        
        Observable.just([Array(0...59).map{"\($0)"}])
            .bind(to: timeSeconds.rx.items(adapter: PickerViewViewAdapter()))
            .disposed(by: disposeBag)
        
        Observable.just([Array(1...99).map{"\($0)"}])
            .bind(to: laps.rx.items(adapter: PickerViewViewAdapter()))
            .disposed(by: disposeBag)
        
        Observable.just([Array(1...99).map{"\($0)"}])
            .bind(to: maxLaps.rx.items(adapter: PickerViewViewAdapter()))
            .disposed(by: disposeBag)
        
        Observable.just([Array(0...9).map{"\($0)"}])
            .bind(to: pyThousands.rx.items(adapter: PickerViewViewAdapter()))
            .disposed(by: disposeBag)
        
        Observable.just([Array(0...9).map{"\($0)"}])
            .bind(to: pyHundreds.rx.items(adapter: PickerViewViewAdapter()))
            .disposed(by: disposeBag)
        
        Observable.just([Array(0...9).map{"\($0)"}])
            .bind(to: pyTens.rx.items(adapter: PickerViewViewAdapter()))
            .disposed(by: disposeBag)
        
        Observable.just([Array(0...9).map{"\($0)"}])
            .bind(to: pyUnits.rx.items(adapter: PickerViewViewAdapter()))
            .disposed(by: disposeBag)
        
        //let elapsedTimeInSeconds = calcElapsedTimeInSeconds()
        
        let elapsedTimeInSeconds = calcElapsedTimeInSeconds(timeHours: timeHours, timeMinutes: timeMinutes, timeSeconds: timeSeconds)
        let lapCorrection = calcLapCorrection(laps: laps, maxLaps: maxLaps)
        let py = calcPy(pyThousands: pyThousands, pyHundreds: pyHundreds, pyTens: pyTens, pyUnits: pyUnits)
        let correctedTime = Observable.combineLatest(elapsedTimeInSeconds, lapCorrection, py, resultSelector : {(elapsedInSeconds, lapCorrection, py) -> Float in
            if py > 0 {
                let correctedTimeValue = Float ( elapsedInSeconds ) * lapCorrection * 1000.00 / Float (py)
                let correctedTime2DP = (correctedTimeValue * 100).rounded() / 100
                print ("Corrected time is \(correctedTime2DP)")
                return correctedTime2DP
            } else {
                return 0.0
            }
            
        })
        correctedTime.map{Optional(String($0))}.bind(to: self.correctedTime.rx.text).disposed(by: disposeBag)
        //TODO: output should be blank for error
        //TODO: changed corrected time text to info
         _ = elapsedTimeInSeconds.subscribe(onNext: {print ("elapsedTimeInSeconds \($0)")})
         _ = lapCorrection.subscribe(onNext: {print ("lapCorrection \($0)")})
         _ = py.subscribe(onNext: {print ("py \($0)")})
        _ = correctedTime.subscribe(onNext: {print ("correctedTime \($0)")})
        /*
        // Get main screen bounds
        let screenSize: CGRect = UIScreen.main.bounds
        
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        print("Screen width = \(screenWidth), screen height = \(screenHeight)")
 */
    }
    
    
    
    func calcElapsedTimeInSeconds (timeHours : UIPickerView,
                                   timeMinutes : UIPickerView,
                                   timeSeconds : UIPickerView ) -> Observable<Int32> {
        let elapsedHoursInSeconds = timeHours.rx.modelSelected(String.self).map{ 3600 * (Int32($0.first ?? "0") ?? 0) }.startWith(0)
        let elapsedMinutesInSeconds = timeMinutes.rx.modelSelected(String.self).map{ 60 * (Int32($0.first ?? "0") ?? 0) }.startWith(0)
        let elapsedSecondsInSeconds = timeSeconds.rx.modelSelected(String.self).map{ 1 * (Int32($0.first ?? "0") ?? 0) }.startWith(0)
        let elapsedInSeconds = Observable.combineLatest( elapsedHoursInSeconds, elapsedMinutesInSeconds, elapsedSecondsInSeconds, resultSelector : {value1, value2, value3 in
            return value1 + value2 + value3
        })
        
        return elapsedInSeconds
    }
    
    func calcLapCorrection ( laps: UIPickerView, maxLaps: UIPickerView ) -> Observable<Float>{
        let completedLaps = laps.rx.modelSelected(String.self).map{ Int32($0.first ?? "") ?? 1}.startWith(1)
        let maximumLaps = maxLaps.rx.modelSelected(String.self).map{ Int32($0.first ?? "") ?? 1}.startWith(1)
        let lapCorrection = Observable.combineLatest(completedLaps, maximumLaps, resultSelector : {value1, value2 in
            return Float( value2 / value1)
        })
        return lapCorrection
    }
    
    func calcPy (pyThousands: UIPickerView,
                 pyHundreds: UIPickerView,
                 pyTens: UIPickerView,
                 pyUnits : UIPickerView) -> Observable<Int32> {
        let pyThousandsInUnits = pyThousands.rx.modelSelected(String.self).map{ 1000 * (Int32($0.first ?? "") ?? 0) }.startWith(0)
        let pyHundredsInUnits = pyHundreds.rx.modelSelected(String.self).map{ 100 * (Int32($0.first ?? "") ?? 0) }.startWith(0)
        let pyTensInUnits = pyTens.rx.modelSelected(String.self).map{ 10 * (Int32($0.first ?? "") ?? 0) }.startWith(0)
        let pyUnitsInUnits = pyUnits.rx.modelSelected(String.self).map{ 1 * (Int32($0.first ?? "") ?? 0) }.startWith(0)
        let py = Observable.combineLatest(pyThousandsInUnits, pyHundredsInUnits, pyTensInUnits, pyUnitsInUnits, resultSelector: {value1, value2, value3, value4 in
            return value1 + value2 + value3 + value4
        } )
        return py
    }
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


