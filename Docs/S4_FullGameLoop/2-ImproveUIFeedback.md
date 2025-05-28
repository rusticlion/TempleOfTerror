Task 2: Improve UI Feedback
Let's make our status displays more visually appealing than plain text.

Action: Create a proper, graphical ClockView that shows a segmented circle.
Action: Enhance PartyStatusView to show stress/harm bars.
ClockView.swift (Graphical Update)
There are many ways to draw a clock. Here's a simple approach using Circle and trim.

Swift

// In ClocksView.swift, replace the Text with a graphical representation
struct GraphicalClockView: View {
    let clock: GameClock
    
    var body: some View {
        VStack {
            Text(clock.name).font(.caption)
            ZStack {
                Circle().stroke(lineWidth: 10).opacity(0.3)
                Circle()
                    .trim(from: 0.0, to: min(CGFloat(clock.progress) / CGFloat(clock.segments), 1.0))
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                    .foregroundColor(.red)
                    .rotationEffect(Angle(degrees: 270.0))
                Text("\(clock.progress)/\(clock.segments)")
            }
            .frame(width: 60, height: 60)
        }
    }
}
// Then in ClocksView, use this in a ScrollView:
// ScrollView(.horizontal) { HStack { ForEach(...) { GraphicalClockView(...) } } }