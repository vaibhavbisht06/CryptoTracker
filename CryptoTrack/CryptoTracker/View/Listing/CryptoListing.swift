//
//  CryptoListing.swift
//  CryptoTracker
//
//  Created by Vaibhav Bisht on 23/07/25.
//

import SwiftUI

struct CryptoListing: View {
    @EnvironmentObject var viewModel: HomeViewModel
    
    private let refreshTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    @State private var enteredCryptoName: String = ""
    @State private var viewLoading: Bool = true
    private var filteredTrsansctions: [CryptoModel] {
        if enteredCryptoName.count < 1 {
            //when nothing is entered in the search bar
            return viewModel.cryptoListing
        } else {
            // Using high degree function "filter"
            let temp  = viewModel.cryptoListing.filter { $0.name.localizedCaseInsensitiveContains(enteredCryptoName) }
            return temp
        }
    }
    
    var body: some View {
        NavigationView{
            VStack{
                //when we haven't received reponse from the server
                if viewLoading{
                    ProgressView()
                        .tint(Color.gray)
                }else{
                    if self.viewModel.cryptoListing.isEmpty{
                        // when we get no crypto data from backend
                        Text("No Crpyto found")
                            .foregroundStyle(Color.gray)
                    }else{
                        if filteredTrsansctions.isEmpty {
                            //when we are searching and no response is found as per entered text.
                            Text("No result found")
                                .foregroundStyle(Color.gray)
                        }else{
                            List{
                                ForEach(filteredTrsansctions, id: \.self){crypto in
                                    ListingCell(item: crypto)
                                        .swipeActions(edge: .trailing){
                                            if self.viewModel.watchlist.contains(where: {$0.id == crypto.id}){
                                                //if crypto exist in watchlist array
                                                deleteFromWishList(crytoData: crypto)
                                            }else{
                                                //if crypto dosen't in watchlist array
                                                addToWishList(crytoData: crypto)
                                            }
                                        }
                                }
                                .listRowBackground(Color.clear)
                                
                            }
                            .scrollDismissesKeyboard(.interactively)
                            .frame(maxWidth: .infinity)
                            .listStyle(PlainListStyle())
                            .refreshable {
                                //For Pull to refresh functionality
                                do {
                                    self.viewModel.refreshCryptoPrice()
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(Text("Listing"))
        }
        .searchable(text: $enteredCryptoName, prompt: "Search Crypto")
        
        .onAppear{
            if self.viewModel.cryptoListing.isEmpty{
                self.viewModel.getCryptoListing(){_ in
                    self.viewLoading = false}
            }
        }
        .onReceive(refreshTimer){_ in
            //60 sec API refresh
            self.viewModel.refreshCryptoPrice()
        }
    }
    
    // Add to wishlist button View
    private func addToWishList(crytoData :CryptoModel) -> some View {
        Button {
            self.viewModel.addCrypto(crpyo: crytoData)
        } label: {
            VStack {
                Image(systemName: "checkmark.circle.fill")
            }
        }
        .tint(.green)
    }
    
    // Delete to wishlist button View
    private func deleteFromWishList(crytoData :CryptoModel) -> some View {
        Button(role: .destructive) {
            self.viewModel.removeCrypto(crypto: crytoData)
        } label: {
            VStack {
                Image(systemName: "trash.fill")
            }
        }
    }
    
}
