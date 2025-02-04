//
//  ContentView.swift
//  MemoCards
//
//  Created by Saydulayev on 25.01.25.
//

import SwiftUI
import SwiftData

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = Double(total - position)
        return self.offset(y: offset * 10)
    }
}

struct ContentView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var accessibilityDifferentiateWithoutColor
    @Environment(\.accessibilityVoiceOverEnabled) var accessibilityVoiceOverEnabled
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.modelContext) private var modelContext

    // Выбираем только активные карточки (isActive == true) и сортируем их по order.
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
                    ForEach(Array(activeCards.enumerated()), id: \.element) { index, card in
                        CardView(card: card) { reinsert in
                            withAnimation {
                                removeCard(at: index, reinsert: reinsert)
                            }
                        }
                        .stacked(at: index, in: activeCards.count)
                        // Только верхняя карточка интерактивна
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
            if newPhase == .active, !activeCards.isEmpty {
                isActive = true
            } else {
                isActive = false
            }
        }
        .sheet(isPresented: $showingEditScreen, onDismiss: resetCards, content: EditCards.init)
        .onAppear(perform: resetCards)
    }
    
    /// Если reinsert == true – карточку «отправляем» в конец стопки (меняем order),
    /// иначе отмечаем её как неактивную (isActive = false), чтобы она не отображалась в игре.
    func removeCard(at index: Int, reinsert: Bool) {
        guard index >= 0, index < activeCards.count else { return }
        let card = activeCards[index]
        if reinsert {
            let newOrder = (activeCards.first?.order ?? 0) - 1
            card.order = newOrder
        } else {
            card.isActive = false
        }
        try? modelContext.save()
        
        if activeCards.isEmpty {
            isActive = false
        }
    }
    
    /// Сброс игры: сбрасываем таймер и для всех карточек (включая неактивные) устанавливаем isActive в true.
    func resetCards() {
        timeRemaining = 100
        isActive = true
        if let allCards: [Card] = try? modelContext.fetch(FetchDescriptor<Card>()) {
            for card in allCards {
                card.isActive = true
            }
            try? modelContext.save()
        }
    }
}

#Preview {
    ContentView()
}


