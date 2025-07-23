//
//  AlertPresenter.swift
//  CryptoTracker
//
//  Created by Vaibhav Bisht on 23/07/25.
//

import SwiftUI

struct AlertPresenter {
    static func showAlert(message: String, title: String = "Warning") {
        DispatchQueue.main.async {
            HapticManager.shared.notification(type: .warning)
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))

            guard let root = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows
                .first(where: \.isKeyWindow)?.rootViewController else {
                    return
                }

            var topController = root
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }

            topController.present(alert, animated: true)
        }
    }
}
