import SwiftUI

struct NodeConnectionsView: View {
    let connections: [PresentedNodeConnection]
    let onMove: (NodeConnection) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Paths from this room")
                .font(Theme.systemFont(size: 11, weight: .semibold))
                .tracking(1)
                .textCase(.uppercase)
                .foregroundColor(Theme.inkFaded)

            ForEach(Array(connections.enumerated()), id: \.0) { index, presentedConnection in
                let connection = presentedConnection.connection
                let isTraversable = presentedConnection.isTraversable

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

                        if !presentedConnection.isStructurallyUnlocked {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Theme.inkFaded)
                        } else if !isTraversable {
                            Image(systemName: "slash.circle.fill")
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
                .disabled(!isTraversable)
                .opacity(isTraversable ? 1 : 0.5)
                .accessibilityIdentifier("connectionButton_\(index)")
            }
        }
    }
}
