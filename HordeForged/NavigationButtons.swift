import SwiftUI

struct NavigationButtons: View {
    var body: some View {
        VStack {
            Button("Inventory") {}
                .padding()
                .background(Color.blue.opacity(0.6))
                .cornerRadius(8)
            Button("Map") {}
                .padding()
                .background(Color.green.opacity(0.6))
                .cornerRadius(8)
            Button("Settings") {}
                .padding()
                .background(Color.purple.opacity(0.6))
                .cornerRadius(8)
        }
        .foregroundColor(.white)
        .padding()
        .background(Color.gray.opacity(0.3))
    }
    
    var count: Int {
        3 // Placeholder for the number of buttons
    }
}