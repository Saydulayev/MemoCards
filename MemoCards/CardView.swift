//
//  CardViev.swift
//  MemoCards
//
//  Created by Saydulayev on 29.01.25.
//


import SwiftUI

/// Extension to adjust the fill color of shapes based on horizontal offset.
extension Shape {
    func fill(using offset: CGSize) -> some View {
        if offset.width == 0 {
            self.fill(.white)
        } else if offset.width < 0 {
            self.fill(.red)
        } else {
            self.fill(.green)
        }
    }
}

/// The view for displaying an individual flashcard.
struct CardView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var accessibilityDifferentiateWithoutColor
    @Environment(\.accessibilityVoiceOverEnabled) var accessibilityVoiceOverEnabled
    let card: Card
    /// The removal closure is triggered when the card is swiped sufficiently.
    var removal: ((Bool) -> Void)? = nil
    
    @State private var isShowingAnswer = false
    @State private var offset = CGSize.zero

    var body: some View {
        ZStack {
            // Background with dynamic color and opacity based on swipe offset.
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    accessibilityDifferentiateWithoutColor
                    ? .white
                    : .white
                        .opacity(1 - Double(abs(offset.width / 50)))
                )
                .accessibilityAddTraits(.isButton)
                .background(
                    accessibilityDifferentiateWithoutColor
                    ? nil
                    : RoundedRectangle(cornerRadius: 25)
                        .fill(using: offset)
                )
                .shadow(radius: 10)

            // Display prompt and answer (if toggled).
            VStack {
                if accessibilityVoiceOverEnabled {
                    Text(isShowingAnswer ? card.answer : card.prompt)
                        .font(.largeTitle)
                        .foregroundStyle(.black)
                } else {
                    Text(card.prompt)
                        .font(.title)
                        .foregroundStyle(.black)
                    
                    if isShowingAnswer {
                        Text(card.answer)
                            .font(.title)
                            .foregroundStyle(.black.opacity(0.5))
                    }
                }
            }
            .padding(20)
            .multilineTextAlignment(.center)
        }
        .frame(width: 450, height: 250)
        .rotationEffect(.degrees(offset.width / 5.0))
        .offset(x: offset.width * 5)
        .opacity(2 - Double(abs(offset.width / 50)))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                }
                .onEnded { _ in
                    // Reset offset if swipe is not significant
                    if abs(offset.width) < 100 {
                        withAnimation {
                            offset = .zero
                        }
                    } else if offset.width > 100 {
                        removal?(false)
                    } else if offset.width < -100 {
                        removal?(true)
                        withAnimation {
                            offset = .zero
                        }
                    }
                }
        )
        .onTapGesture {
            // Toggle between showing the prompt and answer.
            isShowingAnswer.toggle()
        }
        .animation(.bouncy, value: offset)
    }
}

#Preview {
    CardView(card: .example)
}



