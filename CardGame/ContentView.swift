import SwiftUI

struct Card: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let color: Color
}

struct CardView: View {
    let card: Card
    let onRemove: () -> Void

    @State private var offset: CGSize = .zero

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(card.color)
                .shadow(radius: 8)
            Text(card.title)
                .font(.title)
                .foregroundColor(.white)
        }
        .frame(width: 300, height: 400)
        .offset(offset)
        .rotationEffect(.degrees(Double(offset.width / 20)))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                }
                .onEnded { _ in
                    if abs(offset.width) > 100 {
                        // Remove card if swiped far enough
                        withAnimation {
                            offset.width > 0 ? (offset.width = 1000) : (offset.width = -1000)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            onRemove()
                        }
                    } else {
                        withAnimation { offset = .zero }
                    }
                }
        )
        .animation(.spring(), value: offset)
    }
}

struct DeckView: View {
    @State private var cards = [
        Card(title: "SwiftUI", color: .blue),
        Card(title: "Kotlin", color: .purple),
        Card(title: "JavaScript", color: .orange),
        Card(title: "Ruby", color: .red)
    ]

    var body: some View {
        ZStack {
            ForEach(cards) { card in
                if card == cards.last {
                    CardView(card: card) {
                        // Remove top card
                        cards.removeLast()
                    }
                }
            }
            if cards.isEmpty {
                Text("No more cards!")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

struct ContentView: View {
    var body: some View {
        DeckView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

