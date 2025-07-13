//
//  RestrictedWordConnector.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//      © Fast Five Products LLC, 2025
//      https://github.com/fastfiveproducts/template.ios
//      made available, and used here, per terms of the MIT License
//      changes should be rare; it is recommended changes are applied to the template
//      and the entire file compared-and-then-replaced here if/as appropriate
//
//      Template v0.1.1
//


import Foundation
import FirebaseDataConnect
import DefaultConnector

struct RestrictedWordConnector {
    
    func fetchRestrictedWords() async throws -> [String] {
        return ["badword", "worseword"]   // TODO: fetch the data we need to do restricted text functionality
    }

}
