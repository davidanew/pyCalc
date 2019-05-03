//import UIKit
import Foundation
import RxSwift
import RxCocoa

/*
func addOne extension Observable (input : Observable<Int32>) throws -> Observable<Int32>  {
    input.map({$0+1})
}
*/

extension Observable where Element == Int32 {
    
    func addOne  ()  -> Observable<Int32>  {
        return self
    }
    
    static func every(_ s1: Observable<Bool>, _ s2: Observable<Bool>) -> Observable<Bool> {
        return Observable<Bool>.combineLatest(s1, s2) { $0 && $1 }
    }
}
/*
func addOneInt (input : Int) throws -> Int  {
    $0 + 1
}
*/
 
 
_ = Observable.just(Int32(1)).addOne().catchErrorJustReturn(0)


Observable.just(1).addOne


let x = {if true {1} else {2}}

print("hello")




