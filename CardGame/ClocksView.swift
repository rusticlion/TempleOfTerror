import SwiftUI

struct ClocksView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("Active Clocks")
                .font(Theme.displayFont(size: 18))
                .foregroundColor(Theme.parchment)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(viewModel.gameState.activeClocks) { clock in
                        GraphicalClockView(clock: clock)
                    }
                }
                .padding(.bottom, 8)
            }
        }
    }
}

private struct ClockSlice: Shape {
    let index: Int
    let total: Int
    let gapDegrees: Double

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        let segmentSize = 360.0 / Double(max(total, 1))
        let start = -90.0 + (Double(index) * segmentSize) + gapDegrees / 2
        let end = start + segmentSize - gapDegrees

        var path = Path()
        path.move(to: center)
        path.addArc(center: center,
                    radius: radius,
                    startAngle: .degrees(start),
                    endAngle: .degrees(end),
                    clockwise: false)
        path.closeSubpath()
        return path
    }
}

struct GraphicalClockView: View {
    let clock: GameClock

    var body: some View {
        let filledCount = min(max(clock.progress, 0), clock.segments)

        VStack(spacing: 6) {
            Text(clock.name)
                .font(Theme.bodyFont(size: 14))
                .foregroundColor(Theme.parchment)

            ZStack {
                ForEach(0..<clock.segments, id: \.self) { index in
                    ClockSlice(index: index, total: clock.segments, gapDegrees: 3)
                        .fill(index < filledCount ? Theme.gold : Theme.inkFaded.opacity(0.2))
                }

                Circle()
                    .fill(Theme.bgWarm)
                    .frame(width: 30, height: 30)

                Circle()
                    .stroke(Theme.parchmentDeep.opacity(0.4), lineWidth: 1)

                Text("\(clock.progress)/\(clock.segments)")
                    .font(Theme.systemFont(size: 10, weight: .semibold))
                    .foregroundColor(Theme.parchmentDark)
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
