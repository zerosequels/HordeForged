import SwiftUI

struct ActionBarView: View {
    var actionButtons: [Button<Text>] = [
        Button(action: {}) { Text("Action 1") },
        Button(action: {}) { Text("Action 2") },
        Button(action: {}) { Text("Action 3") }
    ]

    var body: some View {
        HStack {
            ForEach(0..<actionButtons.count, id: \.self) { i in
                self.actionButtons[i]
            }
        }
    }
}
