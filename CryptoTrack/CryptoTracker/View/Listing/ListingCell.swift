//
//  ListingCell.swift
//  CryptoTracker
//
//  Created by Vaibhav Bisht on 23/07/25.
//

import SwiftUI

struct ListingCell: View {
    @Environment(\.colorScheme) var colorScheme
    var item : CryptoModel
    var body: some View {
        HStack(spacing: 12){
            AsyncImage(url: URL(string: item.image ?? "")) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 30, height: 30)
            
            //Crypto name and symbol with dynamic text color in context of app color theme
            Text("\(item.name) - (\(item.symbol?.uppercased() ?? ""))")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
            
            Spacer()
            Text(String(format: "$%.2f", item.current_price ?? 0))
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.green)

        }
        .padding(.vertical, 8)
    }
}
