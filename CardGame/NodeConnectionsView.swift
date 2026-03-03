import SwiftUI

struct NodeConnectionsView: View {
    var currentNode: MapNode?
    let onMove: (NodeConnection) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Paths from this room")
                .font(Theme.systemFont(size: 11, weight: .semibold))
                .tracking(1)
                .textCase(.uppercase)
                .foregroundColor(Theme.inkFaded)

            if let node = currentNode {
                ForEach(Array(node.connections.enumerated()), id: \.0) { _, connection in
                    Button {
                        onMove(connection)
                    } label: {
                        HStack(spacing: 10) {
                            Text("↳")
                                .font(.system(size: 14))
                                .foregroundColor(Theme.parchmentDark)

                            Text(connection.description)
                                .font(Theme.bodyFont(size: 14))
                                .foregroundColor(Theme.parchment)
                                .fixedSize(horizontal: false, vertical: true)

                            Spacer()

                            if !connection.isUnlocked {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(Theme.inkFaded)
                            } else {
                                Text("→")
                                    .font(.system(size: 14))
                                    .foregroundColor(Theme.goldDim)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Theme.parchmentDeep.opacity(0.25), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                    .disabled(!connection.isUnlocked)
                    .opacity(connection.isUnlocked ? 1 : 0.5)
                }
            }
        }
    }
}
