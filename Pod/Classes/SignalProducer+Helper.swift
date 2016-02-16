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

public extension SignalProducerType {
    func onStarted(callback:() -> ()) -> SignalProducer<Value, Error> {
        return self.on(started: callback)
    }
    
    func onError(callback:(error:Error) -> () ) -> SignalProducer<Value, Error> {
        return self.on(failed: { (error) -> () in
            callback(error: error)
        })
    }
    
    func onNext(nextClosure:(object:Value) -> ()) -> SignalProducer<Value, Error> {
        return self.on(next: nextClosure)
    }
    
    func onCompleted(nextClosure:() -> ()) -> SignalProducer<Value, Error> {
        return self.on(completed: nextClosure)
    }
}

/// Deprecated methods
public extension SignalProducerType {
    @available(*, deprecated, message="This will be removed. Use onStarted instead.")
    func initially(callback:() -> ()) -> SignalProducer<Value, Error> {
        return self.on(started: callback)
    }
    
    @available(*, deprecated, message="This will be removed. Use onError instead.")
    func doError(callback:(error:Error) -> () ) -> SignalProducer<Value, Error> {
        return self.on(failed: { (error) -> () in
            callback(error: error)
        })
    }
    
    @available(*, deprecated, message="This will be removed. Use onNext instead.")
    func doNext(nextClosure:(object:Value) -> ()) -> SignalProducer<Value, Error> {
        return self.on(next: nextClosure)
    }
    
    @available(*, deprecated, message="This will be removed. Use onCompleted instead.")
    func doCompleted(nextClosure:() -> ()) -> SignalProducer<Value, Error> {
        return self.on(completed: nextClosure)
    }
    
    @available(*, deprecated, message="This will be removed. Use startWithNext instead.")
    func subscribeNext(nextClosure:(object:Value) -> ()) -> Disposable {
        return self.startWithNext(nextClosure)
    }
    
    @available(*, deprecated, message="This will be removed. Use start instead.")
    func execute() -> Disposable {
        return self.start()
    }
    
    @available(*, deprecated, message="This will be removed. Use startWithCompleted instead.")
    func subscribeCompleted(completed: () -> ()) -> Disposable {
        return self.startWithCompleted(completed)
    }
}

public extension SignalProducerType where Error : ErrorTypeConvertible {
    func doNextAs<U>(nextClosure:(U) -> ()) -> SignalProducer<U, Error> {
        return self.mapToType().on(next: nextClosure)
    }
    
    func subscribeNextAs<U>(nextClosure:(U) -> ()) -> Disposable {
        return self.mapToType().startWithNext(nextClosure)
    }
}