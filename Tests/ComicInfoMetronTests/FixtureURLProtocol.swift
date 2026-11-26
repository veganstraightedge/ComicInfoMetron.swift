import Foundation

/// Answers Metron API requests with the recorded responses in `Fixtures/`, as Metron would.
///
/// A request without the test token is refused as unauthorized, and one without the test
/// User-Agent as forbidden, so a passing test shows both are sent.
///
/// The fixtures follow Mokkari's schemas (Metron's own Python client); they were not recorded
/// from the live API.
final class FixtureURLProtocol: URLProtocol, @unchecked Sendable {
  static let token = "test-token"
  static let userAgent = "ComicInfoMetronTests/1.0"

  /// The fixture file each API path and query is answered with.
  private static let files = [
    "/api/issue/31660/": "issue_31660",
    "/api/issue/?cover_year=2012&number=1&series_name=Saga": "issues_saga_1_2012",
    "/api/issue/?number=1&series_name=Saga": "issues_saga_1",
  ]

  /// A URL session whose requests are all answered here.
  static var session: URLSession {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [FixtureURLProtocol.self]
    return URLSession(configuration: configuration)
  }

  override class func canInit(with request: URLRequest) -> Bool { true }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

  override func startLoading() {
    let (status, file) = answer()
    let body = file.flatMap(Self.fixture) ?? Data()
    let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: "HTTP/1.1", headerFields: nil)!
    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
    client?.urlProtocol(self, didLoad: body)
    client?.urlProtocolDidFinishLoading(self)
  }

  override func stopLoading() {}

  private func answer() -> (status: Int, file: String?) {
    guard let url = request.url, let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
      return (400, nil)
    }
    guard request.value(forHTTPHeaderField: "Authorization") == "Bearer \(Self.token)" else { return (401, nil) }
    guard request.value(forHTTPHeaderField: "User-Agent") == Self.userAgent else { return (403, nil) }

    let query = components.percentEncodedQuery.map { "?\($0)" } ?? ""
    guard let file = Self.files[components.path + query] else { return (404, nil) }
    return (200, file)
  }

  private static func fixture(_ name: String) -> Data? {
    guard let url = Bundle.module.url(forResource: name, withExtension: "json", subdirectory: "Fixtures") else {
      return nil
    }
    return try? Data(contentsOf: url)
  }
}
