//
//  CS342_A2App.swift
//  CS342-A2
//
//  Created by Calvin Xu on 1/14/25.
//

import SwiftUI

@main
struct CS342_A2App: App {
    @State private var store = PatientStore()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                PatientListView()
            }
            .environment(store)
        }
    }
}
