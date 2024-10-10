//
//  ContentView.swift
//  Fetch
//
//  Created by Tomas Gonzalez on 10/2/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        // ItemsView forced to light mode for black text due to custom colored UI that requires black text for readability
        ItemsView()
            .colorScheme(.light)
    }
}

#Preview {
    ContentView()
}
