//
//  Card.swift
//  MemoCards
//
//  Created by Saydulayev on 29.01.25.
//

import Foundation

struct Card {
    var prompt: String
    var answer: String

    static let example = Card(prompt: "Who played the 13th Doctor in Doctor Who?", answer: "Jodie Whittaker")
}
