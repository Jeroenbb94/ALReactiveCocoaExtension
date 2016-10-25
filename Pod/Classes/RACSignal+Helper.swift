//
//  RACSignal+Helper.swift
//  Pods
//
//  Created by Antoine van der Lee on 15/01/16.
//
//

import Foundation
import ReactiveCocoa

public extension RACSignal {
    
    fileprivate func errorLogCastNext<T>(_ next:Any!, withClosure nextClosure:(T) -> ()){
        if let nextAsT = next as? T {
            nextClosure(nextAsT)
        } else {
            print("ERROR: Could not cast! \(next)")
        }
    }
    
    func subscribeNextAs<T>(_ nextClosure:@escaping (T) -> ()) -> RACDisposable {
        return self.subscribeNext {
            (next: Any!) -> () in
            self.errorLogCastNext(next, withClosure: nextClosure)
        }
    }
    
    func trySubscribeNextAs<T>(_ nextClosure:@escaping (T) -> ()) -> () {
        self.filter { (next: Any!) -> Bool in
            return next != nil
            }.subscribeNext {
                (next: Any!) -> () in
                
                self.errorLogCastNext(next, withClosure: nextClosure)
        }
    }
    
    func subscribeNextAs<T>(_ nextClosure:@escaping (T) -> (), error: @escaping (NSError) -> ()) -> RACDisposable {
        return self.subscribeNext({ (next: Any!) -> Void in
            self.errorLogCastNext(next, withClosure: nextClosure)
            }, error: { (err: Error?) -> Void in
                error(err as! NSError)
        })
    }
    
    func subscribeNextAs<T>(_ nextClosure:@escaping (T) -> (), error: @escaping (NSError) -> (), completed:@escaping () ->()) -> () {
        self.subscribeNext({
            (next: Any!) -> () in
            self.errorLogCastNext(next, withClosure: nextClosure)
            }, error: {
                (err: Error?) -> () in
                error(err as! NSError)
            }, completed: completed)
    }
    
    func flattenMapAs<T: Any>(_ flattenMapClosure:@escaping (T) -> RACStream) -> RACSignal {
        return self.flattenMap {
            (next: Any!) -> RACStream in
            let nextAsT = next as! T
            return flattenMapClosure(nextAsT)
        }
    }
    
    func mapAs<T, U: Any>(_ mapClosure:@escaping (T) -> U) -> RACSignal {
        return self.map {
            (next: Any!) -> Any! in
            let nextAsT = next as! T
            return mapClosure(nextAsT)
        }
    }
    
    func filterAs<T: Any>(_ filterClosure:@escaping (T) -> Bool) -> RACSignal {
        return self.filter {
            (next: Any!) -> Bool in
            let nextAsT = next as! T
            return filterClosure(nextAsT)
        }
    }
    
    func doNextAs<T>(_ nextClosure:@escaping (T) -> ()) -> RACSignal {
        return self.doNext {
            (next: Any!) -> () in
            self.errorLogCastNext(next, withClosure: nextClosure)
        }
    }
    
    func execute() -> RACDisposable {
        return self.subscribeCompleted { () -> Void in
            
        }
    }
    
    func executeWithDelay(_ interval:TimeInterval) -> RACDisposable? {
        let signals = [RACSignal.empty().delay(interval), self]
        let delayedSignal = RACSignal.concat(signals as NSFastEnumeration!)
        return delayedSignal?.execute()
    }
    
    func ignoreNil() -> RACSignal {
        return self.filter({ (innerValue) -> Bool in
            return innerValue != nil
        })
    }
}
