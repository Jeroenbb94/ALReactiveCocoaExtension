//
//  SignalProducer+Helper.swift
//  Pods
//
//  Created by Antoine van der Lee on 15/01/16.
//
//

import Foundation
import ReactiveCocoa

public extension SignalProducerType where Error == NSError {
    func mapTo<U>() -> SignalProducer<U, NSError> {
        return flatMap(FlattenStrategy.Latest, transform: { (object) -> SignalProducer<U, NSError> in
            if let castedObject = object as? U {
                return SignalProducer(value: castedObject)
            } else {
                return SignalProducer(error: NSError(domain: "ALReactiveCocoaExtension", code: 500, userInfo: nil))
            }
        })
    }
}

public extension SignalProducerType {
    
    private func errorLogCastNext<U>(next:Value?, withClosure nextClosure:(U) -> ()){
        if let nextAsT = next as? U {
            nextClosure(nextAsT)
        } else {
            print("ERROR: Could not cast! \(next)")
        }
    }
    
    func initially(callback:() -> ()) -> SignalProducer<Value, Error> {
        return self.on(started: callback)
    }
    
    func doError(callback:(error:NSError) -> () ) -> SignalProducer<Value, Error> {
        return self.on(failed: { (error) -> () in
            callback(error: error as NSError)
        })
    }
    
    func doNext(nextClosure:(object:Value) -> ()) -> SignalProducer<Value, Error> {
        return self.on(next: nextClosure)
    }
    
    func doNextAs<U>(nextClosure:(U) -> ()) -> SignalProducer<Value, Error> {
        return self.on(next: { (object) -> () in
            self.errorLogCastNext(object, withClosure: nextClosure)
        })
    }
    
    func doCompleted(nextClosure:() -> ()) -> SignalProducer<Value, Error> {
        return self.on(completed: nextClosure)
    }
    
    func subscribeNext(nextClosure:(object:Value) -> ()) -> Disposable {
        return self.startWithNext(nextClosure)
    }
    
    func subscribeNextAs<U>(nextClosure:(U) -> ()) -> Disposable {
        return self.startWithNext({ (object) -> () in
            self.errorLogCastNext(object, withClosure: nextClosure)
        })
    }
    
    func subscribeCompleted(completed: () -> ()) -> Disposable {
        return self.startWithCompleted(completed)
    }
    
    func execute() -> Disposable {
        return self.start()
    }
}