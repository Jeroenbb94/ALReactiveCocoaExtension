//
//  NSNotificationCenter+RAC.swift
//  Pods
//
//  Created by Antoine van der Lee on 15/01/16.
//
//

import Foundation
import ReactiveSwift
import enum Result.NoError

extension NotificationCenter {
    func rac_addObserversForNames(_ names:[String]) -> SignalProducer<Notification, NoError> {
        var signals = [SignalProducer<Notification, NoError>]()
        for name in names {
            signals.append(SignalProducer(signal:reactive.notifications(forName: Notification.Name(rawValue: name))))
        }
        
        return SignalProducer.merge(signals)
    }
}
