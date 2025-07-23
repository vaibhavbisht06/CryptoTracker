//
//  MainTabbarView.swift
//  CryptoTracker
//
//  Created by Vaibhav Bisht on 23/07/25.
//


import SwiftUI

struct MainTabbarView: View {
    @State private var selectedTab = 0
    @Namespace private var animation

    var body: some View {
        VStack{
            ZStack(alignment: .bottom) {
                TabView(selection: $selectedTab) {
                    CryptoListing()
                        .tag(0)
                        .toolbar(.hidden, for: .tabBar)
                    CryptoWatchlist()
                        .tag(1)
                        .toolbar(.hidden, for: .tabBar)
                    Settings()
                        .tag(2)
                        .toolbar(.hidden, for: .tabBar)
                }
                HStack(spacing: 4) {
                    ForEach(TabbedItems.allCases, id: \.self) { item in
                        Button {
                            HapticManager.shared.impact(style: .soft)
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                selectedTab = item.rawValue
                            }
                        } label: {
                            CustomTabItem(
                                imageName: item.iconName,
                                title: item.title,
                                isActive: selectedTab == item.rawValue,
                                animation: animation
                            )
                        }
                    }
                }
                .padding(4)
                .frame(height: 48)
                .background(.thickMaterial)
                .cornerRadius(100)
                .padding(.horizontal, 60)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }
        .background(Color.white)
    }
}

extension MainTabbarView {
    func CustomTabItem(imageName: String, title: String, isActive: Bool, animation: Namespace.ID) -> some View {
        ZStack {
            if isActive {
                RoundedRectangle(cornerRadius: 100)
                    .fill(Color(red: 0.67, green: 0.91, blue: 0.17))
                    .matchedGeometryEffect(id: "tabBackground", in: animation)
            }

            HStack(spacing: 6) {
                Image(systemName: imageName)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(isActive ? .black : .gray)
                    .frame(width: 18, height: 18)

                if isActive {
                    Text(title.uppercased())
                        .font(.subheadline)
                        .lineLimit(1)
                        .fixedSize()
                        .foregroundColor(.black)
                }
            }

            .padding(.horizontal, isActive ? 16 : 0)
            .frame(height: 40)
        }
        .frame(maxWidth: .infinity)
    }
}



enum TabbedItems: Int, CaseIterable{
    case home = 0
    case wathchList
    case settings
    
    var title: String{
        switch self {
        case .home:
            return "Home"
        case .wathchList:
            return "WatchList"
        case .settings:
            return "Setting"
        }
    }
    
    var iconName: String{
        switch self {
        case .home:
            return "chart.xyaxis.line"
        case .wathchList:
            return "tray.full"
        case .settings:
            return "gear"
        }
    }
}
