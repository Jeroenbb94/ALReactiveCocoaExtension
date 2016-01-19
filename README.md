# ALReactiveCocoaExtension

[![Version](https://img.shields.io/cocoapods/v/ALReactiveCocoaExtension.svg?style=flat)](http://cocoapods.org/pods/ALReactiveCocoaExtension)
[![License](https://img.shields.io/cocoapods/l/ALReactiveCocoaExtension.svg?style=flat)](http://cocoapods.org/pods/ALReactiveCocoaExtension)
[![Platform](https://img.shields.io/cocoapods/p/ALReactiveCocoaExtension.svg?style=flat)](http://cocoapods.org/pods/ALReactiveCocoaExtension)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

The pod includes extensions for `RACSignal` and adds replacements for the `RAC` and `RACObserve` macros we're used to in Objective-C.

### SignalProducer extension
This pod includes an extension for the new `SignalProducer`. This brings the methods we're familiar with from earlier versions of ReactiveCocoa.

```swift
let producer = SignalProducer<String, NSError>(value: "testValue")
    
// Prints "producer started!"
producer.initially { () -> () in
    print("producer started!")
}.start()
    
// Prints "testValue"
producer.doNext { (object) -> () in
    print(object)
}.start()
    
// Prints "testValue"
producer.doNextAs { (string:String) -> () in
    print(string)
}.start()
    
// Prints "testValue"
producer.subscribeNextAs { (string:String) -> () in
    print(string)
}

// Prints "testValue"
producer.subscribeNext { (string) -> () in
print(string)
}
    
// Prints "completed"
producer.subscribeCompleted { () -> () in
    print("completed")
}
    
// Prints "Error Domain=sample.domain Code=-1 "(null)""
let errorProducer = SignalProducer<String, NSError>(error:NSError(domain: "sample.domain", code: -1, userInfo: nil))
errorProducer.doError { (error) -> () in
    print(error)
}.start()
```

## Requirements
This pod requires `ReactiveCocoa 4.0.0 and up`

## Installation

ALReactiveCocoaExtension is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "ALReactiveCocoaExtension"
```

## Author

Antoine van der Lee, 
https://twitter.com/twannl
https://www.avanderlee.com

## License

ALReactiveCocoaExtension is available under the MIT license. See the LICENSE file for more info.
