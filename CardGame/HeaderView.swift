import SwiftUI

struct HeaderView: View {
    let title: String
    // Only display the current room title. The character selector has moved
    // to the footer toolbar.

    var body: some View {
        Text(title)
            .font(.largeTitle)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.horizontal, .bottom])
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(title: "Preview Location")
    }
}
