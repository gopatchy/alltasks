import SwiftUI

struct ContentView: View {
    @Binding var selectedMode: ViewMode
    
    var body: some View {
        TaskListView(selectedMode: $selectedMode)
    }
}

#Preview {
    ContentView(selectedMode: .constant(.list))
}
