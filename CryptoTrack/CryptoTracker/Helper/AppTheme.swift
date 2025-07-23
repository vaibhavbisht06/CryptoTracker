//
//  AppTheme.swift
//  CryptoTracker
//
//  Created by Vaibhav Bisht on 23/07/25.
//

import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case light, dark
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
    
    var colorScheme: ColorScheme {
        self == .dark ? .dark : .light
    }
}
