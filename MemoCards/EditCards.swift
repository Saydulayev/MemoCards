//
//  EditCards.swift
//  MemoCards
//
//  Created by Saydulayev on 01.02.25.
//

import SwiftUI
import SwiftData

/// View for editing flashcards: adding, listing, and deleting cards.
struct EditCards: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    /// Query to fetch all cards sorted by order.
    @Query(sort: \Card.order, order: .forward)
    var cards: [Card]
    
    @State private var newPrompt = ""
    @State private var newAnswer = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section("Add new card") {
                    TextField("Prompt", text: $newPrompt)
                    TextField("Answer", text: $newAnswer)
                    Button("Add Card", action: addCard)
                }
                
                Section {
                    // Use card.id as identifier for stable list rendering.
                    ForEach(cards, id: \.id) { card in
                        VStack(alignment: .leading) {
                            Text(card.prompt)
                                .font(.headline)
                            Text(card.answer)
                                .foregroundStyle(.secondary)
                            Text("Active: \(card.isActive ? "Yes" : "No")")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                    }
                    .onDelete(perform: removeCards)
                }
            }
            .navigationTitle("Edit Cards")
            .toolbar {
                Button("Done", action: done)
            }
        }
    }
    
    func done() {
        dismiss()
    }
    
    /// Adds a new card with a calculated order and marks it as active.
    func addCard() {
        let trimmedPrompt = newPrompt.trimmingCharacters(in: .whitespaces)
        let trimmedAnswer = newAnswer.trimmingCharacters(in: .whitespaces)
        guard !trimmedPrompt.isEmpty, !trimmedAnswer.isEmpty else { return }
        
        let newOrder = (cards.first?.order ?? 0) - 1
        let card = Card(prompt: trimmedPrompt, answer: trimmedAnswer, order: newOrder)
        card.isActive = true
        modelContext.insert(card)
        saveContext()
        
        newPrompt = ""
        newAnswer = ""
    }
    
    /// Removes the selected cards from the model context.
    func removeCards(at offsets: IndexSet) {
        for index in offsets {
            let card = cards[index]
            modelContext.delete(card)
        }
        saveContext()
    }
    
    /// Helper function to save changes in the model context.
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving modelContext in EditCards: \(error.localizedDescription)")
        }
    }
}

#Preview {
    EditCards()
}



