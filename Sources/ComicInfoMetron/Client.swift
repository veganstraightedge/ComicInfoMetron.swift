//
// Client.swift
// ComicInfoMetron
//

import Foundation

/// Calls the Metron API with one account's API token.
struct Client: Sendable {
  static let baseURL = URL(string: "https://metron.cloud/api/")!

  /// The characters a query value keeps as they are; the rest are percent-encoded.
  ///
  /// `&`, `=` and `+` are left out: a server reads them as separating parameters or as a space.
  private static let queryValueCharacters = CharacterSet.urlQueryAllowed.subtracting(CharacterSet(charactersIn: "&=+"))

  let token: String
  let userAgent: String
  let session: URLSession

  /// The issues numbered `number` in series whose names contain `series`, narrowed to a cover year when there is one.
  func findIssues(series: String, number: String, coverYear: Int?) async throws -> [Responses.IssueSummary] {
    var parameters = ["number": number, "series_name": series]
    parameters["cover_year"] = coverYear.map(String.init)
    let page: Responses.Page<Responses.IssueSummary> = try await get("issue/", parameters)
    return page.results
  }

  /// Calls one API resource and decodes its response.
  private func get<Response: Decodable>(_ path: String, _ parameters: [String: String]) async throws -> Response {
    var components = URLComponents(url: Self.baseURL.appending(path: path), resolvingAgainstBaseURL: false)!
    if !parameters.isEmpty {
      components.percentEncodedQueryItems = parameters.sorted { $0.key < $1.key }.map { name, value in
        URLQueryItem(name: name, value: value.addingPercentEncoding(withAllowedCharacters: Self.queryValueCharacters))
      }
    }

    var request = URLRequest(url: components.url!)
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
    let (data, response) = try await session.data(for: request)

    if let response = response as? HTTPURLResponse, response.statusCode != 200 {
      throw MetronError.httpStatus(response.statusCode)
    }
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode(Response.self, from: data)
  }
}
