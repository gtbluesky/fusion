//
//  WeakReference.swift
//  fusion
//
// Created by gtbluesky on 2022/4/12.
//

import Foundation

class WeakReference<T: AnyObject> {
    private(set) weak var value: T?

    init(_ value: T) {
        self.value = value
    }
}