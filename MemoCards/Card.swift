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

    static let example = Card(prompt: "Трудно ли стать программистом?", answer: "Сначала трудно, потом тоже трудно.😅")
}
