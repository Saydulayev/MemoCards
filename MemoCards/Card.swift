//
//  Card.swift
//  MemoCards
//
//  Created by Saydulayev on 29.01.25.
//

import SwiftData
import Foundation

@Model
final class Card: Identifiable, Hashable {
    var id: UUID = UUID()
    var prompt: String
    var answer: String
    var order: Int = 0
    /// Флаг, показывающий, активна ли карточка для игры
    var isActive: Bool = true

    init(prompt: String, answer: String, order: Int = 0) {
        self.prompt = prompt
        self.answer = answer
        self.order = order
    }

    static let example = Card(prompt: "Трудно ли стать программистом?",
                                answer: "Сначала трудно, потом тоже трудно.😅")

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Card, rhs: Card) -> Bool {
        lhs.id == rhs.id
    }
}


