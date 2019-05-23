//  Copyright © 2019 David New. All rights reserved.

//TODO: App icon
//TODO: launch image
//TODO: Description

//Image public domain:
//https://commons.wikimedia.org/wiki/File:Musto_Skiff.jpg

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    //Need to pass errors and information seperately as Observales disconnect on error
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
    
    //For user to input elapsed time
    @IBOutlet weak var timeHours: UIPickerView!
    @IBOutlet weak var timeMinutes: UIPickerView!
    @IBOutlet weak var timeSeconds: UIPickerView!
    //For uset to input completed laps
    @IBOutlet weak var laps: UIPickerView!
    //To enter PY
    @IBOutlet weak var pyThousands: UIPickerView!
    @IBOutlet weak var pyHundreds: UIPickerView!
    @IBOutlet weak var pyTens: UIPickerView!
    @IBOutlet weak var pyUnits: UIPickerView!
    //Max laps that any boat did
    @IBOutlet weak var maxLaps: UIPickerView!
    //Show calculated corrected time
    @IBOutlet weak var correctedTime: UILabel!
    //Label for corrected time or user prompt
    @IBOutlet weak var outputLabel: UILabel!
    //Help button shows more detail on inputs and outputs
    @IBAction func helpButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Corrected Time Calculator Help", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {alert in}))
        let bold = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17)]
        let normal = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17)]
        let helpTextAs = NSMutableAttributedString()
        helpTextAs.append ( NSMutableAttributedString(string: "Elapsed Time\n" , attributes:bold) )
        helpTextAs.append ( NSMutableAttributedString(string: "Time for the competitor to complete all laps\n\n" , attributes:normal) )
        helpTextAs.append ( NSMutableAttributedString(string: "Laps\n" , attributes:bold) )
        helpTextAs.append ( NSMutableAttributedString(string: "Number of laps this competitor completed\n\n" , attributes:normal) )
        helpTextAs.append ( NSMutableAttributedString(string: "PY\n" , attributes:bold) )
        helpTextAs.append ( NSMutableAttributedString(string: "Portsmouth Yardstick\n\n" , attributes:normal) )
        helpTextAs.append ( NSMutableAttributedString(string: "Laps\n" , attributes:bold) )
        helpTextAs.append ( NSMutableAttributedString(string: "The maximum number of laps that any competitor completed" , attributes:normal) )
        alert.setValue(helpTextAs, forKey: "attributedTitle")
        self.present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Get values from their associated picker views
        let elapsedTimeInSeconds = calcElapsedTimeInSeconds(timeHours: &timeHours, timeMinutes: &timeMinutes, timeSeconds: &timeSeconds)
        let lapCorrection = calcLapCorrection(laps: &laps, maxLaps: &maxLaps)
        let py = calcPy(pyThousands: &pyThousands, pyHundreds: &pyHundreds, pyTens: &pyTens, pyUnits: &pyUnits)
        //Output to user
        let correctedTime = calcCorrectedTime(elapsedTimeInSeconds: elapsedTimeInSeconds, lapCorrection: lapCorrection, py: py)
        let correctedTimeString = calcCorrectedTimeString(correctedTime: correctedTime)
        correctedTimeString.bind(to: self.correctedTime.rx.text).disposed(by: disposeBag)
        let outputLabelSting = calcOutputLabelString(correctedTime: correctedTime)
        outputLabelSting.bind(to: self.outputLabel.rx.text).disposed(by: disposeBag)
        //For debugging
        //_ = elapsedTimeInSeconds.subscribe(onNext: {print ("elapsedTimeInSeconds \($0.value)")})
        //_ = lapCorrection.subscribe(onNext: {print ("lapCorrection \($0.value)")})
        //_ = py.subscribe(onNext: {print ("py \($0.value)")})
        //_ = correctedTime.subscribe(onNext: {print ("correctedTime \($0.value)")})
    }
    
    func calcCorrectedTimeString(correctedTime: Observable<ValueAndMessage<Float>> ) -> Observable<String> {
        return correctedTime.map({$0.message == .ok ? "\($0.value)" : ""} )
    }
    
    func calcOutputLabelString(correctedTime: Observable<ValueAndMessage<Float>> ) -> Observable<String> {
        return correctedTime.map({
            //Select readable string based on message output from calcCorrectedTime
            switch $0.message {
            case .ok : return "Corrected Time (seconds)"
            case .elapsedTimeZero :return "Please set Elasped Time"
            case .pyZero : return "Please set handicap"
            case .lapsTooHigh : return "Please set max laps"
            }
        })
    }
    
    func calcElapsedTimeInSeconds (timeHours : inout UIPickerView,
                                   timeMinutes : inout UIPickerView,
                                   timeSeconds : inout UIPickerView ) -> Observable<ValueAndMessage<Int32>> {
        //Populate picker view
        Observable.just([Array(0...9).map{"\($0)"}])
            .bind(to: timeHours.rx.items(adapter: PickerViewViewAdapter()))
            .disposed(by: disposeBag)
        
        Observable.just([Array(0...59).map{String(format: "%02d", $0)}])
            .bind(to: timeMinutes.rx.items(adapter: PickerViewViewAdapter()))
            .disposed(by: disposeBag)
        
        Observable.just([Array(0...59).map{String(format: "%02d", $0)}])
            .bind(to: timeSeconds.rx.items(adapter: PickerViewViewAdapter()))
            .disposed(by: disposeBag)
        //Calculate elapsed time. Return it an message idicating validity
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
        //populate picker view
        Observable.just([Array(1...99).map{"\($0)"}])
            .bind(to: laps.rx.items(adapter: PickerViewViewAdapter()))
            .disposed(by: disposeBag)
        
        Observable.just([Array(1...99).map{"\($0)"}])
            .bind(to: maxLaps.rx.items(adapter: PickerViewViewAdapter()))
            .disposed(by: disposeBag)
        //Calculate lap correction factor. Return it and message indicating validity
        let completedLaps = laps.rx.modelSelected(String.self).map{ Int32($0.first ?? "") ?? 1}.startWith(1)
        let maximumLaps = maxLaps.rx.modelSelected(String.self).map{ Int32($0.first ?? "") ?? 1}.startWith(1)
        let lapCorrection = Observable.combineLatest(completedLaps, maximumLaps, resultSelector : {(value1, value2) -> ValueAndMessage<Float>  in
            return ValueAndMessage<Float>(value: Float(value2/value1) , message: value1 > value2 ? .lapsTooHigh : .ok)
        })
        return lapCorrection
    }
    
    func calcPy (pyThousands: inout UIPickerView,
                 pyHundreds: inout UIPickerView,
                 pyTens: inout UIPickerView,
                 pyUnits : inout UIPickerView) -> Observable<ValueAndMessage<Int32>> {
        //Populate picker view
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
        //Calculate and return PY number and message giving validity
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
                //If previous output is an error, work out what message to display. return this and a py of zero
                let returnMessage : Message = { if (elapsedInSeconds.message == .elapsedTimeZero) { return .elapsedTimeZero}
                                                else if (py.message == .pyZero) { return  .pyZero }
                                                else if (lapCorrection.message == .lapsTooHigh) {return .lapsTooHigh}
                                                else {return .ok}}()
                return ValueAndMessage<Float>(value: 0.0, message: returnMessage)
            }
            //If ok return ok message and calculayted value
            let correctedTimeValue = Float ( elapsedInSeconds.value ) * lapCorrection.value * 1000.00 / Float (py.value)
            let correctedTime2DP = (correctedTimeValue * 100).rounded() / 100
            return ValueAndMessage<Float>(value: correctedTime2DP, message: .ok)
        })
        return correctedTime
    }
}

