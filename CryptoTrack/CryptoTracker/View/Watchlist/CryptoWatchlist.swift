//
//  CryptoWatchlist.swift
//  CryptoTracker
//
//  Created by Vaibhav Bisht on 23/07/25.
//

import SwiftUI

struct CryptoWatchlist: View {
    @EnvironmentObject var watchListManager : HomeViewModel
    
    var body: some View {
        NavigationView{
            VStack{
                if watchListManager.watchlist.isEmpty{
                    // When watchlist is empty
                    VStack{
                        Text("Add crypto to watchlist by sliding left on any crypto")
                            .foregroundStyle(Color.gray)
                    }
                }else{
                    List{
                        ForEach(self.watchListManager.watchlist, id: \.self){crypto in
                            ListingCell(item: crypto)
                                .swipeActions(edge: .trailing){
                                    deleteFromWishList(crytoData: crypto)
                                }
                        }
                        .listRowBackground(Color.clear)
                    }
                    .frame(maxWidth: .infinity)
                    .listStyle(.plain)
                }
            }
            .navigationTitle(Text("Watchlist"))
        }
        .onAppear{
            self.watchListManager.loadWatchlist()
        }
    }
    
    //Swipe to Delete Button
    private func deleteFromWishList(crytoData :CryptoModel) -> some View {
        Button(role: .destructive) {
            self.watchListManager.removeCrypto(crypto: crytoData)
        } label: {
            VStack {
                Image(systemName: "trash.fill")
            }
        }
    }
}
