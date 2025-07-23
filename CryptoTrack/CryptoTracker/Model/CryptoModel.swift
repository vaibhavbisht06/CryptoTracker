//
//  CryptoModel.swift
//  CryptoTracker
//
//  Created by Vaibhav Bisht on 23/07/25.
//

import Foundation

struct CryptoModel: Codable, Hashable {
    let id: String
    let symbol: String?
    let name: String
    var current_price: Double?
    let image: String?
}
