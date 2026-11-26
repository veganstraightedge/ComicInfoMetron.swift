//
// Client.swift
// ComicInfoMetron
//

import Foundation

/// Calls the Metron API with one account's API token.
struct Client: Sendable {
  static let baseURL = URL(string: "https://metron.cloud/api/")!

  let token: String
  let userAgent: String
  let session: URLSession
}
