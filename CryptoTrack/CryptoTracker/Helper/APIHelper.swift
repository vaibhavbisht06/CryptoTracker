//
//  APIHelper.swift
//  CryptoTracker
//
//  Created by Vaibhav Bisht on 23/07/25.
//

import Foundation
import UIKit
import SwiftyJSON
import SwiftUI

enum HTTPMethod: String {
    case GET, POST, PUT, PATCH, DELETE
}

enum APIError: Error, LocalizedError {
    case invalidURL, noData, invalidResponse
    case networkError(Error), serverError(Int, Data?)
    case unauthorized, forbidden, notFound, timeout, noInternetConnection

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .noData: return "No data received"
        case .invalidResponse: return "Invalid response"
        case .networkError(let err): return "Network error: \(err.localizedDescription)"
        case .serverError(let code, _): return "Server error: \(code)"
        case .unauthorized: return "Unauthorized"
        case .forbidden: return "Forbidden"
        case .notFound: return "Not Found"
        case .timeout: return "Request timeout"
        case .noInternetConnection: return "No internet connection"
        }
    }
}

struct APIResponse {
    let data: Data
    let statusCode: Int
    let headers: [AnyHashable: Any]?
}

class APIHelper {
    static let shared = APIHelper()
    private let session: URLSession
    private var baseURL = ""
    private var defaultHeaders: [String: String] = [
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": UserDefaults.standard.string(forKey: "userSessionID") ?? ""
    ]
    private let timeout: TimeInterval = 30.0
    var isDebugLoggingEnabled = false

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout
        session = URLSession(configuration: config)
    }

    func configure(baseURL: String, defaultHeaders: [String: String] = [:], enableDebugLogging: Bool = true) {
        self.baseURL = baseURL.hasSuffix("/") ? String(baseURL.dropLast()) : baseURL
        self.isDebugLoggingEnabled = enableDebugLogging
        for (k, v) in defaultHeaders {
            self.defaultHeaders[k] = v
        }
        debugLog("🔧 Configured APIHelper with baseURL: \(self.baseURL)")
        debugLog("📋 Default Headers: \(self.defaultHeaders)")
    }

    func setAuthToken(_ token: String, type: String = "Bearer") {
        defaultHeaders["Authorization"] = "\(type) \(token)"
        debugLog("🔐 Auth token set")
    }

    func removeAuthToken() {
        defaultHeaders.removeValue(forKey: "Authorization")
        debugLog("🔓 Auth token removed")
    }

    func request(
        endpoint: String,
        method: HTTPMethod = .GET,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        completion: @escaping (Result<APIResponse, APIError>) -> Void
    ) {
        let urlString = endpoint.hasPrefix("http") ? endpoint : baseURL + endpoint
        guard let url = URL(string: urlString) else {
            debugLog("❌ Invalid URL: \(urlString)")
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        var allHeaders = defaultHeaders
        headers?.forEach { allHeaders[$0.key] = $0.value }
        allHeaders.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        logRequest(url: urlString, method: method, headers: allHeaders, parameters: parameters)

        if let params = parameters {
            switch method {
            case .GET:
                var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                components?.queryItems = params.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                if let newURL = components?.url {
                    request.url = newURL
                    debugLog("🔗 Updated URL with query parameters: \(newURL.absoluteString)")
                }
            default:
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
                } catch {
                    debugLog("❌ Failed to encode parameters: \(error.localizedDescription)")
                    completion(.failure(.networkError(error)))
                    return
                }
            }
        }

        let startTime = Date()

        session.dataTask(with: request) { data, response, error in
            let duration = Date().timeIntervalSince(startTime)
            self.debugLog("⏱️ Request completed in \(String(format: "%.2f", duration)) seconds")

            DispatchQueue.main.async {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                self.logResponse(statusCode: statusCode, data: data, error: error)

                if let error = error {
                    completion(.failure(self.mapURLErrorToAPIError(error)))
                    return
                }

                guard let httpResp = response as? HTTPURLResponse else {
                    completion(.failure(.invalidResponse))
                    return
                }

                //Removed this piece of code because I wanted to handle the error inside the function of API Call
//                switch statusCode {
//                case 200...299: break
//                case 401: completion(.failure(.unauthorized)); return
//                case 403: completion(.failure(.forbidden)); return
//                case 404: completion(.failure(.notFound)); return
//                default: completion(.failure(.serverError(statusCode, data))); return
//                }

                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }

                let apiResponse = APIResponse(data: data, statusCode: statusCode, headers: httpResp.allHeaderFields)
                completion(.success(apiResponse))
            }
        }.resume()
    }

    func uploadData(
        endpoint: String,
        data: Data,
        fileName: String,
        mimeType: String,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        completion: @escaping (Result<APIResponse, APIError>) -> Void
    ) {
        let urlString = endpoint.hasPrefix("http") ? endpoint : baseURL + endpoint
        guard let url = URL(string: urlString) else {
            debugLog("❌ Invalid URL: \(urlString)")
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.POST.rawValue

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var allHeaders = defaultHeaders
        headers?.forEach { allHeaders[$0.key] = $0.value }
        allHeaders.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)

        parameters?.forEach { key, value in
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        session.uploadTask(with: request, from: body) { data, response, error in
            DispatchQueue.main.async {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                self.logResponse(statusCode: statusCode, data: data, error: error)

                if let error = error {
                    completion(.failure(self.mapURLErrorToAPIError(error)))
                    return
                }

                guard let httpResp = response as? HTTPURLResponse else {
                    completion(.failure(.invalidResponse))
                    return
                }

                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }

                let apiResponse = APIResponse(data: data, statusCode: statusCode, headers: httpResp.allHeaderFields)
                completion(.success(apiResponse))
            }
        }.resume()
    }

    func uploadImage(
        endpoint: String,
        image: UIImage,
        compressionQuality: CGFloat = 0.8,
        fileName: String = "image.jpg",
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        completion: @escaping (Result<APIResponse, APIError>) -> Void
    ) {
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
            completion(.failure(.networkError(NSError(domain: "ImageConversion", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"]))))
            return
        }
        uploadData(endpoint: endpoint, data: imageData, fileName: fileName, mimeType: "image/jpeg", parameters: parameters, headers: headers, completion: completion)
    }

    @available(iOS 13.0, *)
    func request(
        endpoint: String,
        method: HTTPMethod = .GET,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil
    ) async throws -> APIResponse {
        return try await withCheckedThrowingContinuation { continuation in
            self.request(endpoint: endpoint, method: method, parameters: parameters, headers: headers) { result in
                continuation.resume(with: result)
            }
        }
    }

    private func mapURLErrorToAPIError(_ error: Error) -> APIError {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut: return .timeout
            case .notConnectedToInternet, .networkConnectionLost: return .noInternetConnection
            default: return .networkError(urlError)
            }
        }
        return .networkError(error)
    }

    private func debugLog(_ message: String) {
        if isDebugLoggingEnabled {
            print("🌐 APIHelper: \(message)")
        }
    }

    private func logRequest(url: String, method: HTTPMethod, headers: [String: String], parameters: [String: Any]?) {
        guard isDebugLoggingEnabled else { return }

        print("\n=")
        print("🚀 API REQUEST")
        print("=")
        print("📍 URL: \(url)")
        print("🔄 Method: \(method.rawValue)")
        print("📋 Headers:")
        for (key, value) in headers {
            if key.lowercased().contains("authorization") {
                print("   \(key): [HIDDEN]")
            } else {
                print("   \(key): \(value)")
            }
        }

        if let params = parameters {
            print("📦 Parameters:")
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print(jsonString)
                }
            } catch {
                print("   \(params)")
            }
        } else {
            print("📦 Parameters: None")
        }
        print("=\n")
    }

    private func logResponse(statusCode: Int, data: Data?, error: Error?) {
        guard isDebugLoggingEnabled else { return }

        print("\n=")
        print("📨 API RESPONSE")
        print("=")
        print("📊 Status Code: \(statusCode)")

        if let error = error {
            print("❌ Error: \(error.localizedDescription)")
        }

        if let data = data {
            print("📏 Response Size: \(data.count) bytes")
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                let prettyData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                if let prettyString = String(data: prettyData, encoding: .utf8) {
                    print("📄 Response Data:")
                    print(prettyString)
                }
            } catch {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📄 Response Data: \(responseString)")
                }
            }
        } else {
            print("📄 Response Data: None")
        }
        print("=\n")
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

public func getDataFrom(JSON json: JSON) -> Data? {
    do {
        return try json.rawData(options: .prettyPrinted)
    } catch _ {
        return nil
    }
}
