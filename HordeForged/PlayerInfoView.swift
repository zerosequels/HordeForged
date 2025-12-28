import SwiftUI

struct PlayerInfoView: View {
    var body: some View {
        VStack {
            Text("Player Name")
                .font(.headline)
            Text("Gold: 100")
            Text("Food: 50")
        }
        .padding()
        .background(Color.gray.opacity(0.5))
        .cornerRadius(10)
    }
}

#Preview {
    PlayerInfoView()
}
