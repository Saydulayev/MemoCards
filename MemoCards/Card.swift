//
//  Card.swift
//  MemoCards
//
//  Created by Saydulayev on 29.01.25.
//

import SwiftData
import Foundation

/// The Card model represents a flashcard used in the game.
@Model
final class Card: Identifiable, Hashable {
    var id: UUID = UUID()
    var prompt: String
    var answer: String
    /// Order is used to arrange the cards in the stack.
    var order: Int = 0
    /// Flag indicating whether the card is active (available in the current game round).
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



