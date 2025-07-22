import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String
    @FocusState.Binding var searchFocused: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
        
            TextField("", text: $searchText)
                .textFieldStyle(.plain)
                .focused($searchFocused)
        
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    searchFocused = true
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.accentColor.opacity(0.3), lineWidth: searchFocused ? 1 : 0)
        )
        .glassEffect(in: RoundedRectangle(cornerRadius: 20))
        .frame(maxWidth: 300)
    }
}
