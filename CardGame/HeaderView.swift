import SwiftUI

struct HeaderView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(Theme.displayFont(size: 26))
            .foregroundColor(Theme.parchment)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.bottom, 8)
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(title: "Preview Location")
    }
}
