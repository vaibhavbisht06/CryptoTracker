//
//  Settings.swift
//  CryptoTracker
//
//  Created by Vaibhav Bisht on 23/07/25.
//

import SwiftUI

struct Settings: View {
    @EnvironmentObject var watchlist: HomeViewModel
    
    @AppStorage("appTheme") private var appThemeRawValue: String = AppTheme.dark.rawValue
    var body: some View {
        NavigationView{
            VStack(spacing:12){
                // App dark mode theme
                Toggle("Dark Mode", isOn: Binding(
                    get: { appThemeRawValue == AppTheme.dark.rawValue },
                    set: { appThemeRawValue = $0 ? AppTheme.dark.rawValue : AppTheme.light.rawValue }
                ))
                .padding(8)
                
                // Delete all the watchlist array
                Button(role :.destructive){
                    self.watchlist.removeAllWatchlist()
                }label: {
                    Text("\(Image(systemName: "trash")) Delete all watchlist Data")
                }
                Spacer()
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle(Text("Settings"))
        }
    }
}
