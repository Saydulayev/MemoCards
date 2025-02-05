//
//  ContentView.swift
//  MemoCards
//
//  Created by Saydulayev on 25.01.25.
//

import SwiftUI
import SwiftData

/// Extension to help stack views with vertical offsets.
extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = Double(total - position)
        return self.offset(y: offset * 10)
    }
}

/// The main game view displaying the active flashcards.
struct ContentView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var accessibilityDifferentiateWithoutColor
    @Environment(\.accessibilityVoiceOverEnabled) var accessibilityVoiceOverEnabled
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.modelContext) private var modelContext

    /// Query to fetch only active cards, sorted by order.
    @Query(filter: #Predicate { $0.isActive == true }, sort: \Card.order, order: .forward)
    private var activeCards: [Card]
    
    @State private var isActive = true
    @State private var timeRemaining = 100
    @State private var showingEditScreen = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Image(decorative: "background")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                Text("Time: \(timeRemaining)")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.75))
                    .clipShape(Capsule())
                
                ZStack {
                    // Use card.id as identifier for stability
                    ForEach(Array(activeCards.enumerated()), id: \.element.id) { index, card in
                        CardView(card: card) { reinsert in
                            withAnimation {
                                removeCard(at: index, reinsert: reinsert)
                            }
                        }
                        .stacked(at: index, in: activeCards.count)
                        // Only the top card is interactive.
                        .allowsHitTesting(index == activeCards.count - 1)
                        .accessibilityHidden(index < activeCards.count - 1)
                    }
                }
                .allowsHitTesting(timeRemaining > 0)
                
                if activeCards.isEmpty {
                    Button("Start Again", action: resetCards)
                        .padding()
                        .background(.white)
                        .foregroundStyle(.black)
                        .clipShape(Capsule())
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button {
                        showingEditScreen = true
                    } label: {
                        Image(systemName: "plus.circle")
                            .padding()
                            .background(.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                }
                Spacer()
            }
            .foregroundStyle(.white)
            .font(.largeTitle)
            .padding()
            
            if accessibilityDifferentiateWithoutColor || accessibilityVoiceOverEnabled {
                VStack {
                    Spacer()
                    HStack {
                        Button {
                            withAnimation {
                                removeCard(at: activeCards.count - 1, reinsert: true)
                            }
                        } label: {
                            Image(systemName: "xmark.circle")
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Wrong")
                        .accessibilityHint("Mark your answer as being incorrect")
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                removeCard(at: activeCards.count - 1, reinsert: false)
                            }
                        } label: {
                            Image(systemName: "checkmark.circle")
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Correct")
                        .accessibilityHint("Mark your answer as being correct")
                    }
                    .foregroundStyle(.white)
                    .font(.largeTitle)
                    .padding()
                }
            }
        }
        .onReceive(timer) { _ in
            guard isActive else { return }
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            // Resume timer when app becomes active if there are active cards.
            if newPhase == .active, !activeCards.isEmpty {
                isActive = true
            } else {
                isActive = false
            }
        }
        .sheet(isPresented: $showingEditScreen, onDismiss: resetCards, content: EditCards.init)
        .onAppear(perform: resetCards)
    }
    
    /// Removes or reorders a card based on the swipe gesture.
    /// - Parameters:
    ///   - index: Index of the card in the activeCards array.
    ///   - reinsert: If true, update the card's order to send it to the bottom of the stack.
    func removeCard(at index: Int, reinsert: Bool) {
        guard index >= 0, index < activeCards.count else { return }
        let card = activeCards[index]
        if reinsert {
            // Calculate new order to push the card to the bottom.
            let newOrder = (activeCards.first?.order ?? 0) - 1
            card.order = newOrder
        } else {
            // Instead of deleting, mark the card as inactive.
            card.isActive = false
        }
        saveContext()

        // If no active cards remain, stop the game.
        if activeCards.isEmpty {
            isActive = false
        }
    }
    
    /// Resets the game by setting the timer and marking all cards as active.
    func resetCards() {
        timeRemaining = 100
        isActive = true
        
        // Fetch all cards (active and inactive) and mark them active.
        if let allCards: [Card] = try? modelContext.fetch(FetchDescriptor<Card>()) {
            for card in allCards {
                card.isActive = true
            }
            saveContext()
        }
    }
    
    /// Helper function to save changes in the model context.
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving modelContext: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ContentView()
}



