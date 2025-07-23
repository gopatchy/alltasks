import SwiftUI

struct ViewModePicker: View {
    @Binding var modeSelected: ViewMode
    
    var body: some View {
        Picker("View Mode", selection: $modeSelected) {
            ForEach(ViewMode.allCases, id: \.self) { mode in
                Image(systemName: mode.systemImage)
                    .tag(mode)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .labelsHidden()
        .tint(.purple)
        .glassEffect(in: RoundedRectangle(cornerRadius: 10))
    }
}
