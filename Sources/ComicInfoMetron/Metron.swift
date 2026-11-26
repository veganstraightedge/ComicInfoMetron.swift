//
// Metron.swift
// ComicInfoMetron
//

import ComicInfo
import Foundation

/// Looks up comic details in [Metron](https://metron.cloud).
///
/// ```swift
/// let metron = Metron(token: token, userAgent: "MyApp/1.0")
/// let matches = try await metron.matches(for: issue)
/// let found = try await metron.issue(for: matches[0])
/// let updated = issue.fillingBlanks(from: found)
/// ```
///
/// Whatever shows Metron's data credits and links back to it. Requests are made with a Metron
/// account's API token.
public struct Metron: ComicInfo.MetadataSource {
  public let name = "Metron"
  public let homeURL = URL(string: "https://metron.cloud/")!

  private let client: Client

  /// - Parameters:
  ///   - token: The account's Metron API token.
  ///   - userAgent: Names the app, such as "MyApp/1.0".
  ///   - session: The URL session requests are made with.
  public init(token: String, userAgent: String, session: URLSession = .shared) {
    client = Client(token: token, userAgent: userAgent, session: session)
  }

  public func missingDetails(for issue: ComicInfo.Issue) -> String? {
    guard Self.isBlank(issue.series) || Self.isBlank(issue.number) else { return nil }
    return "Metron needs a Series and a Number to search for."
  }

  /// The issues with the issue's number in every series whose name contains its series, best first.
  ///
  /// When the issue has a year, only issues with a cover dated that year are asked for.
  public func matches(for issue: ComicInfo.Issue) async throws -> [ComicInfo.Match] {
    let series = Self.nonBlank(issue.series) ?? ""
    let number = Self.nonBlank(issue.number) ?? ""
    let found = try await client.findIssues(series: series, number: number, coverYear: issue.year)
    return found.map(Self.match).ranked(for: issue)
  }

  public func issue(for match: ComicInfo.Match) async throws -> ComicInfo.Issue {
    guard let id = Int(match.id) else { throw MetronError.invalidIssueID(match.id) }
    let found = try await client.issue(id)
    return IssueMapping(issue: found).issue
  }

  /// One issue from the issue list as a match.
  ///
  /// Metron's issue pages are addressed by a slug, which the list doesn't have, so it has no site URL.
  private static func match(_ found: Responses.IssueSummary) -> ComicInfo.Match {
    let series = found.series.name ?? ""
    let heading = nonBlank(found.displayName) ?? "\(series) #\(found.number ?? "")"
    return ComicInfo.Match(
      id: String(found.id),
      heading: heading,
      series: series,
      number: found.number,
      coverDate: found.coverDate,
      details: "Cover date " + (nonBlank(found.coverDate) ?? "unknown")
    )
  }

  static func nonBlank(_ text: String?) -> String? {
    guard let text = text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else { return nil }
    return text
  }

  private static func isBlank(_ text: String?) -> Bool { nonBlank(text) == nil }
}
