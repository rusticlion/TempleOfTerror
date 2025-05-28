import SwiftUI

struct ClocksView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("Active Clocks")
                .font(.headline)
            ScrollView(.horizontal) {
                HStack {
                    ForEach(viewModel.gameState.activeClocks) { clock in
                        GraphicalClockView(clock: clock)
                    }
                }
                .padding(.bottom, 8)
            }
        }
    }
}

struct GraphicalClockView: View {
    let clock: GameClock

    var body: some View {
        VStack {
            Text(clock.name)
                .font(.caption)
            ZStack {
                Circle().stroke(lineWidth: 10).opacity(0.3)
                Circle()
                    .trim(from: 0.0,
                          to: min(CGFloat(clock.progress) / CGFloat(clock.segments), 1.0))
                    .stroke(style: StrokeStyle(lineWidth: 10,
                                               lineCap: .round,
                                               lineJoin: .round))
                    .foregroundColor(.red)
                    .rotationEffect(Angle(degrees: 270.0))
                Text("\(clock.progress)/\(clock.segments)")
            }
            .frame(width: 60, height: 60)
        }
    }
}

struct ClocksView_Previews: PreviewProvider {
    static var previews: some View {
        ClocksView(viewModel: GameViewModel())
    }
}
