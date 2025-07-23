//
//  CryptoTrackerApp.swift
//  CryptoTracker
//
//  Created by Vaibhav Bisht on 23/07/25.
//

import SwiftUI

@main
struct CryptoTrackerApp: App {
    @AppStorage("appTheme") private var appThemeRawValue: String = AppTheme.dark.rawValue
    @ObservedObject var homeViewModel = HomeViewModel()
    var body: some Scene {
        WindowGroup {
            MainTabbarView()
                .preferredColorScheme(AppTheme(rawValue: appThemeRawValue)?.colorScheme)
        }
        .environmentObject(homeViewModel)
    }
}
