import SwiftUI

struct TopBar: View {
    @Binding var taskFilter: TaskFilter
    @Binding var searchText: String
    @FocusState.Binding var searchFocused: Bool
    @Binding var modeSelected: ViewMode
    
    var body: some View {
        HStack {
            TaskFilterPicker(taskFilter: $taskFilter)
            
            SearchBar(
                searchText: $searchText,
                searchFocused: $searchFocused
            )
            
            Spacer()
            
            ViewModePicker(modeSelected: $modeSelected)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
