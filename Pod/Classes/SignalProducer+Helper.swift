//
//  SignalProducer+Helper.swift
//  Pods
//
//  Created by Antoine van der Lee on 15/01/16.
//
//

import Foundation
import ReactiveCocoa

public protocol ErrorTypeConvertible: ErrorType {
    typealias ConvertibleType = Self
    static func errorFromErrorType(error: ErrorType) -> ConvertibleType
}

/// Make NSError conform to ErrorTypeConvertible
extension NSError: ErrorTypeConvertible {
    public static func errorFromErrorType(error: ErrorType) -> NSError {
        return error as NSError
    }
}

extension NoError: ErrorTypeConvertible {
    public static func errorFromErrorType(error: ErrorType) -> NSError {
        return error as NSError
    }
}

public extension SignalProducerType where Error: ErrorTypeConvertible  {
    func mapTo<U>(type:U) -> SignalProducer<U, Error> {
        return flatMap(FlattenStrategy.Latest, transform: { (object) -> SignalProducer<U, Error> in
            if let castedObject = object as? U {
                return SignalProducer(value: castedObject)
            } else {
                print("ERROR: Could not cast! \(object)")
                let convertedError = Error.errorFromErrorType(NSError(domain: "ALReactiveCocoaExtension", code: 500, userInfo: nil)) as! Error
                return SignalProducer(error: convertedError)
            }
        })
    }
    
    func mapToType<U>() -> SignalProducer<U, Error> {
        return flatMap(FlattenStrategy.Latest, transform: { (object) -> SignalProducer<U, Error> in
            if let castedObject = object as? U {
                return SignalProducer(value: castedObject)
            } else {
                print("ERROR: Could not cast! \(object)")
                let convertedError = Error.errorFromErrorType(NSError(domain: "ALReactiveCocoaExtension", code: 500, userInfo: nil)) as! Error
                return SignalProducer(error: convertedError)
            }
        })
    }
}

public extension SignalProducerType where Error : ErrorTypeConvertible {
    
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
    
    func doNextAs<U>(nextClosure:(U) -> ()) -> SignalProducer<U, Error> {
        return self.mapToType().on(next: nextClosure)
    }
    
    func doCompleted(nextClosure:() -> ()) -> SignalProducer<Value, Error> {
        return self.on(completed: nextClosure)
    }
    
    func subscribeNext(nextClosure:(object:Value) -> ()) -> Disposable {
        return self.startWithNext(nextClosure)
    }
    
    func subscribeNextAs<U>(nextClosure:(U) -> ()) -> Disposable {
        return self.mapToType().startWithNext(nextClosure)
    }
    
    func subscribeCompleted(completed: () -> ()) -> Disposable {
        return self.startWithCompleted(completed)
    }
    
    func execute() -> Disposable {
        return self.start()
    }
}