import SwiftUI

struct ClocksView: View {
    let clocks: [GameClock]
    var title: String = "Active Clocks"
    var prominent: Bool = false

    private var visibleClocks: [GameClock] {
        clocks.filter { $0.progress > 0 }
    }

    @ViewBuilder
    var body: some View {
        if !visibleClocks.isEmpty {
            Group {
                if prominent {
                    prominentContent
                } else {
                    standardContent
                }
            }
        }
    }

    private var sectionHeader: some View {
        HStack(spacing: 8) {
            Image(systemName: "hourglass.bottomhalf.filled")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(prominent ? Theme.goldBright : Theme.gold)

            Text(title)
                .font(Theme.displayFont(size: prominent ? 20 : 18))
                .foregroundColor(Theme.parchment)

            Spacer()
        }
    }

    private var standardContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(visibleClocks) { clock in
                        GraphicalClockView(clock: clock)
                    }
                }
                .padding(.bottom, 8)
            }
        }
    }

    private var prominentContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(visibleClocks) { clock in
                        GraphicalClockView(clock: clock, cardStyle: true)
                    }
                }
                .padding(.bottom, 2)
            }
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [Theme.leatherLight.opacity(0.95), Theme.leather.opacity(0.98)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Theme.goldDim.opacity(0.35), lineWidth: 1)
        )
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
    var cardStyle: Bool = false

    private var clockDiameter: CGFloat {
        cardStyle ? 72 : 60
    }

    var body: some View {
        let filledCount = min(max(clock.progress, 0), clock.segments)

        VStack(spacing: cardStyle ? 10 : 6) {
            Text(clock.name)
                .font(Theme.bodyFont(size: cardStyle ? 16 : 14))
                .foregroundColor(Theme.parchment)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: cardStyle ? 112 : 84)

            ZStack {
                ForEach(0..<clock.segments, id: \.self) { index in
                    ClockSlice(index: index, total: clock.segments, gapDegrees: 3)
                        .fill(index < filledCount ? Theme.gold : Theme.inkFaded.opacity(0.2))
                }

                Circle()
                    .fill(Theme.bgWarm)
                    .frame(width: clockDiameter * 0.5, height: clockDiameter * 0.5)

                Circle()
                    .stroke(Theme.parchmentDeep.opacity(0.4), lineWidth: 1)

                Text("\(clock.progress)/\(clock.segments)")
                    .font(Theme.systemFont(size: cardStyle ? 11 : 10, weight: .semibold))
                    .foregroundColor(Theme.parchmentDark)
            }
            .frame(width: clockDiameter, height: clockDiameter)
        }
        .padding(cardStyle ? 12 : 0)
        .frame(width: cardStyle ? 136 : nil)
        .background(cardStyle ? Theme.bgWarm.opacity(0.45) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(cardStyle ? Theme.parchmentDeep.opacity(0.18) : .clear, lineWidth: 1)
        )
    }
}

struct ClocksView_Previews: PreviewProvider {
    static var previews: some View {
        ClocksView(
            clocks: [
                GameClock(name: "Temple Collapse", segments: 6, progress: 2),
                GameClock(name: "Awakened Guardians", segments: 4, progress: 1)
            ],
            prominent: true
        )
    }
}
