//
//  HomeViewModel.swift
//  CryptoTracker
//
//  Created by Vaibhav Bisht on 23/07/25.
//

import Foundation
import SwiftyJSON

class HomeViewModel: ObservableObject {
    @Published var cryptoListing = [CryptoModel]()
    @Published var watchlist: [CryptoModel] = []
    private let storageKey = "WatchlistCoins"
    
    func getCryptoListing(completion: @escaping (Bool) -> Void) {
        Task {
            do {
                let response = try await APIHelper.shared.request(
                    endpoint: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=20&page=0&sparkline=false",
                    method: .GET)
                let json = try JSON(data: response.data)
                let jsonData = getDataFrom(JSON: json)
                if let data = jsonData{
                    do{
                        let cartModelData = try JSONDecoder().decode([CryptoModel].self, from: data)
                        await MainActor.run {
                            self.cryptoListing = cartModelData
                            completion(true)
                        }
                        return
                    }catch let jsonError as NSError{
                        completion(false)
                        print("JSON Failed:", jsonError.description)
                    }
                    return
                }else{
                    completion(true)
                }
            }catch {
                AlertPresenter.showAlert(message: "Getting difficulty to connect to server. Please try again later.", title: "Error")
            }
        }
    }
    
    //API For updating price only of the crypto
    func refreshCryptoPrice() {
        let ids = cryptoListing.map { $0.id }.joined(separator: ",")
        let url = "https://api.coingecko.com/api/v3/simple/price?ids=\(ids)&vs_currencies=usd"
        
        Task {
            do {
                let response = try await APIHelper.shared.request(endpoint: url, method: .GET)
                let json = try JSON(data: response.data)
                await MainActor.run {
                    for i in 0..<self.cryptoListing.count {
                        let id = self.cryptoListing[i].id
                        if let newPrice = json[id]["usd"].double {
                            self.cryptoListing[i].current_price = newPrice
                        }
                    }
                    //update price from watchlist
                    self.loadWatchlist()
                }
            } catch {
                print("Price refresh failed:", error.localizedDescription)
            }
        }
    }

    func loadWatchlist() {
        self.watchlist.removeAll()
            if let savedIDs = UserDefaults.standard.array(forKey: storageKey) as? [String] {
                for itemID in savedIDs {
                    if let temp = self.cryptoListing.first(where: { $0.id == itemID }) {
                        self.watchlist.append(temp)
                    }
                }
            } else {
                self.watchlist = []
            }
        }

    func addCrypto(crpyo: CryptoModel) {
        guard !watchlist.contains(crpyo) else { return }
        watchlist.append(crpyo)
        saveWatchlist()
    }

    func removeCrypto(crypto: CryptoModel) {
        watchlist.removeAll { $0.id == crypto.id }
        saveWatchlist()
    }
    
    func removeAllWatchlist() {
        watchlist.removeAll()
        saveWatchlist()
    }
    
    private func saveWatchlist() {
        UserDefaults.standard.set(watchlist.map{$0.id}, forKey: storageKey)
        }
}
