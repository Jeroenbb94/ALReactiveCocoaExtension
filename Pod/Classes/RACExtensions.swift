//
//  RACExtensions.swift
//
//  Created by AvdLee on 28/10/15.
//  Copyright (c) 2014 A. van der Lee. All rights reserved.
//

import Foundation
import ReactiveCocoa

public extension RACSignal {
    
    private func errorLogCastNext<T>(next:AnyObject!, withClosure nextClosure:(T) -> ()){
        if let nextAsT = next as? T {
            nextClosure(nextAsT)
        } else {
            print("ERROR: Could not cast! \(next)")
        }
    }
    
    func subscribeNextAs<T>(nextClosure:(T) -> ()) -> RACDisposable {
        return self.subscribeNext {
            (next: AnyObject!) -> () in
            self.errorLogCastNext(next, withClosure: nextClosure)
        }
    }
    
    func trySubscribeNextAs<T>(nextClosure:(T) -> ()) -> () {
        self.filter { (next: AnyObject!) -> Bool in
            return next != nil
            }.subscribeNext {
                (next: AnyObject!) -> () in
                
                self.errorLogCastNext(next, withClosure: nextClosure)
        }
    }
    
    func subscribeNextAs<T>(nextClosure:(T) -> (), error: (NSError) -> ()) -> RACDisposable {
        return self.subscribeNext({ (next: AnyObject!) -> Void in
            self.errorLogCastNext(next, withClosure: nextClosure)
            }, error: { (err: NSError!) -> Void in
                error(err)
        })
    }
    
    func subscribeNextAs<T>(nextClosure:(T) -> (), error: (NSError) -> (), completed:() ->()) -> () {
        self.subscribeNext({
            (next: AnyObject!) -> () in
            self.errorLogCastNext(next, withClosure: nextClosure)
            }, error: {
                (err: NSError!) -> () in
                error(err)
            }, completed: completed)
    }
    
    func flattenMapAs<T: AnyObject>(flattenMapClosure:(T) -> RACStream) -> RACSignal {
        return self.flattenMap {
            (next: AnyObject!) -> RACStream in
            let nextAsT = next as! T
            return flattenMapClosure(nextAsT)
        }
    }
    
    func mapAs<T, U: AnyObject>(mapClosure:(T) -> U) -> RACSignal {
        return self.map {
            (next: AnyObject!) -> AnyObject! in
            let nextAsT = next as! T
            return mapClosure(nextAsT)
        }
    }
    
    func filterAs<T: AnyObject>(filterClosure:(T) -> Bool) -> RACSignal {
        return self.filter {
            (next: AnyObject!) -> Bool in
            let nextAsT = next as! T
            return filterClosure(nextAsT)
        }
    }
    
    func doNextAs<T>(nextClosure:(T) -> ()) -> RACSignal {
        return self.doNext {
            (next: AnyObject!) -> () in
            self.errorLogCastNext(next, withClosure: nextClosure)
        }
    }
    
    func execute() -> RACDisposable {
        return self.subscribeCompleted { () -> Void in
            
        }
    }
    
    func executeWithDelay(interval:NSTimeInterval) -> RACDisposable {
        let signals = [RACSignal.empty().delay(interval), self]
        let delayedSignal = RACSignal.concat(signals)
        return delayedSignal.execute()
    }
    
    func ignoreNil() -> RACSignal {
        return self.filter({ (innerValue) -> Bool in
            return innerValue != nil
        })
    }
}

public struct RAC  {
    var target: NSObject
    var keyPath: String
    var nilValue: AnyObject?
    
    public init(_ target: NSObject, _ keyPath: String, nilValue: AnyObject? = nil) {
        self.target = target
        self.keyPath = keyPath
        self.nilValue = nilValue
    }
    
    func assignSignal(signal : RACSignal) -> RACDisposable {
        return signal.setKeyPath(self.keyPath, onObject: self.target, nilValue: self.nilValue)
    }
}

infix operator <~ {
associativity right
precedence 93
}

public func <~ (rac: RAC, signal: RACSignal) -> RACDisposable {
    return signal ~> rac
}

public func ~> (signal: RACSignal, rac: RAC) -> RACDisposable {
    return rac.assignSignal(signal)
}

public func RACObserve(target: NSObject!, _ keyPath: String) -> RACSignal {
    return target.rac_valuesForKeyPath(keyPath, observer: target)
}

extension NSNotificationCenter {
    func rac_addObserversForNames(names:[String]) -> RACSignal {
        var signals = [RACSignal]()
        for name in names {
            signals.append(self.rac_addObserverForName(name, object: nil))
        }
        
        return RACSignal.merge(signals)
    }
}