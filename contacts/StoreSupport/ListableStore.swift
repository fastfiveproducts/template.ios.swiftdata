//
//  ListableStore.swift
//  template
//
//  Created by Pete Maiser on 7/3/25.
//


import Foundation

@MainActor
protocol ListableStore: ObservableObject {
    associatedtype T: Listable
    var list: Loadable<[T]> { get }
}
