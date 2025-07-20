import SwiftUI

struct TaskFilterPicker: View {
    @Binding var taskFilter: TaskFilter
    
    var body: some View {
        Picker("", selection: $taskFilter) {
            ForEach(TaskFilter.allCases, id: \.self) { filter in
                Image(systemName: filter.systemImage)
                    .tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
        .tint(.purple)
        .glassEffect(in: RoundedRectangle(cornerRadius: 10))
    }
}