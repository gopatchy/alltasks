import SwiftUI

struct TopBar: View {
    @Binding var taskFilter: TaskFilter
    @Binding var searchText: String
    @FocusState.Binding var isSearchFieldFocused: Bool
    @Binding var selectedMode: ViewMode
    var filteredTasks: [TaskItem]
    @Binding var selectedTask: TaskItem?
    
    var body: some View {
        HStack {
            TaskFilterPicker(taskFilter: $taskFilter)
            
            SearchBar(
                searchText: $searchText,
                isSearchFieldFocused: $isSearchFieldFocused,
                onSubmit: {
                    if !filteredTasks.isEmpty {
                        selectedTask = filteredTasks.first
                    }
                }
            )
            
            Spacer()
            
            ViewModePicker(selectedMode: $selectedMode)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}