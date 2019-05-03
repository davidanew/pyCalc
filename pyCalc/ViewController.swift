//  Copyright © 2019 David New. All rights reserved.


//TODO: change to result type
//https://www.hackingwithswift.com/articles/126/whats-new-in-swift-5-0
//TODO: help popup

import UIKit
import RxSwift
import RxCocoa

struct ValueAndMessage <T> {
    let value : T
    let message : Message
}

enum Message {
    case elapsedTimeZero
    case pyZero
    case lapsTooHigh
    case ok
}

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
    @IBOutlet weak var outputLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Get calculated values from their associated picker views
        let elapsedTimeInSeconds = calcElapsedTimeInSeconds(timeHours: &timeHours, timeMinutes: &timeMinutes, timeSeconds: &timeSeconds)
        let lapCorrection = calcLapCorrection(laps: &laps, maxLaps: &maxLaps)
        let py = calcPy(pyThousands: &pyThousands, pyHundreds: &pyHundreds, pyTens: &pyTens, pyUnits: &pyUnits)
        //Calculate the corrected time
        let correctedTime = calcCorrectedTime(elapsedTimeInSeconds: elapsedTimeInSeconds, lapCorrection: lapCorrection, py: py)
        
        let correctedTimeString = calcCorrectedTimeString(correctedTime: correctedTime)
        correctedTimeString.bind(to: self.correctedTime.rx.text).disposed(by: disposeBag)
        let outputLabelSting = calcOutputLabelString(correctedTime: correctedTime)
        outputLabelSting.bind(to: self.outputLabel.rx.text).disposed(by: disposeBag)

        //For debugging
        _ = elapsedTimeInSeconds.subscribe(onNext: {print ("elapsedTimeInSeconds \($0)")})
        _ = lapCorrection.subscribe(onNext: {print ("lapCorrection \($0)")})
        _ = py.subscribe(onNext: {print ("py \($0)")})
        _ = correctedTime.subscribe(onNext: {print ("correctedTime \($0)")})
    }
    
    func calcCorrectedTimeString(correctedTime: Observable<ValueAndMessage<Float>> ) -> Observable<String> {
        //TODO: put formatting here
        return correctedTime.map({$0.message == .ok ? "\($0.value)" : ""} )
    }
    
    func calcOutputLabelString(correctedTime: Observable<ValueAndMessage<Float>> ) -> Observable<String> {
        //TODO: put formatting here
        //return correctedTime.map({$0.message == .ok ? "Corrected Time (seconds)" : "\($0.message)"} )
        return correctedTime.map({
            switch $0.message {
            case .ok : return "Corrected Time (seconds)"
            case .elapsedTimeZero :return "Please set Elasped Time"
            case .pyZero : return "Please set PY"
            case .lapsTooHigh : return "Please set max laps"
            }
        })
    }
    
    func calcElapsedTimeInSeconds (timeHours : inout UIPickerView,
                                   timeMinutes : inout UIPickerView,
                                   timeSeconds : inout UIPickerView ) -> Observable<ValueAndMessage<Int32>> {
        
        Observable.just([Array(0...9).map{"\($0)"}])
            .bind(to: timeHours.rx.items(adapter: PickerViewViewAdapter()))
            .disposed(by: disposeBag)
        
        Observable.just([Array(0...59).map{String(format: "%02d", $0)}])
            .bind(to: timeMinutes.rx.items(adapter: PickerViewViewAdapter()))
            .disposed(by: disposeBag)
        
        Observable.just([Array(0...59).map{String(format: "%02d", $0)}])
            .bind(to: timeSeconds.rx.items(adapter: PickerViewViewAdapter()))
            .disposed(by: disposeBag)
        
        let elapsedHoursInSeconds = timeHours.rx.modelSelected(String.self).map{ 3600 * (Int32($0.first ?? "0") ?? 0) }.startWith(0)
        let elapsedMinutesInSeconds = timeMinutes.rx.modelSelected(String.self).map{ 60 * (Int32($0.first ?? "0") ?? 0) }.startWith(0)
        let elapsedSecondsInSeconds = timeSeconds.rx.modelSelected(String.self).map{ 1 * (Int32($0.first ?? "0") ?? 0) }.startWith(0)
        let elapsedInSeconds = Observable.combineLatest( elapsedHoursInSeconds,
                                                         elapsedMinutesInSeconds,
                                                         elapsedSecondsInSeconds,
                                                         resultSelector : {(value1, value2, value3) -> ValueAndMessage<Int32>  in
                                                            let value = value1 + value2 + value3
                                                            return ValueAndMessage(value: value, message: value == 0 ? .elapsedTimeZero : .ok)
        })
        
        return elapsedInSeconds
    }
    
    func calcLapCorrection ( laps: inout UIPickerView,
                             maxLaps: inout UIPickerView ) -> Observable<ValueAndMessage<Float>>{
        
        Observable.just([Array(1...99).map{"\($0)"}])
            .bind(to: laps.rx.items(adapter: PickerViewViewAdapter()))
            .disposed(by: disposeBag)
        
        Observable.just([Array(1...99).map{"\($0)"}])
            .bind(to: maxLaps.rx.items(adapter: PickerViewViewAdapter()))
            .disposed(by: disposeBag)
        
        let completedLaps = laps.rx.modelSelected(String.self).map{ Int32($0.first ?? "") ?? 1}.startWith(1)
        let maximumLaps = maxLaps.rx.modelSelected(String.self).map{ Int32($0.first ?? "") ?? 1}.startWith(1)
        let lapCorrection = Observable.combineLatest(completedLaps, maximumLaps, resultSelector : {(value1, value2) -> ValueAndMessage<Float>  in
            return ValueAndMessage<Float>(value: Float(value2/value1) , message: value2 > value1 ? .lapsTooHigh : .ok)
        })
        
        return lapCorrection
    }
    
    func calcPy (pyThousands: inout UIPickerView,
                 pyHundreds: inout UIPickerView,
                 pyTens: inout UIPickerView,
                 pyUnits : inout UIPickerView) -> Observable<ValueAndMessage<Int32>> {
        
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
        
        let pyThousandsInUnits = pyThousands.rx.modelSelected(String.self).map{ 1000 * (Int32($0.first ?? "") ?? 0) }.startWith(0)
        let pyHundredsInUnits = pyHundreds.rx.modelSelected(String.self).map{ 100 * (Int32($0.first ?? "") ?? 0) }.startWith(0)
        let pyTensInUnits = pyTens.rx.modelSelected(String.self).map{ 10 * (Int32($0.first ?? "") ?? 0) }.startWith(0)
        let pyUnitsInUnits = pyUnits.rx.modelSelected(String.self).map{ 1 * (Int32($0.first ?? "") ?? 0) }.startWith(0)
        let py = Observable.combineLatest(pyThousandsInUnits,
                                          pyHundredsInUnits,
                                          pyTensInUnits,
                                          pyUnitsInUnits,
                                          resultSelector: {(value1, value2, value3, value4) -> ValueAndMessage<Int32> in
                                            let value = value1 + value2 + value3 + value4
                                            let py = ValueAndMessage<Int32>(value: value, message: value == 0 ? .pyZero : .ok)
                                            return py
        } )
        return py
    }
    
    func calcCorrectedTime (elapsedTimeInSeconds : Observable<ValueAndMessage<Int32>>,
                            lapCorrection: Observable<ValueAndMessage<Float>> ,
                            py: Observable<ValueAndMessage<Int32>>   ) -> Observable<ValueAndMessage<Float>> {
        let correctedTime = Observable.combineLatest(elapsedTimeInSeconds, lapCorrection, py, resultSelector : {(elapsedInSeconds, lapCorrection, py) -> ValueAndMessage<Float> in
            guard elapsedInSeconds.message == .ok, lapCorrection.message == .ok, py.message == .ok else {
                let returnMessage : Message = { if (elapsedInSeconds.message == .elapsedTimeZero) { return .elapsedTimeZero}
                                                else if (py.message == .pyZero) { return  .pyZero }
                                                else if (lapCorrection.message == .lapsTooHigh) {return .lapsTooHigh}
                                                else {return .ok}}()
                return ValueAndMessage<Float>(value: 0.0, message: returnMessage)
            }
            let correctedTimeValue = Float ( elapsedInSeconds.value ) * lapCorrection.value * 1000.00 / Float (py.value)
            let correctedTime2DP = (correctedTimeValue * 100).rounded() / 100
     //       print ("Corrected time is \(correctedTime2DP)")
            return ValueAndMessage<Float>(value: correctedTime2DP, message: .ok)
        })
        return correctedTime
    }
}

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


