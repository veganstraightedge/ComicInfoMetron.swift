//
// Responses.swift
// ComicInfoMetron
//

import Foundation

/// Metron's API responses, as far as they are read.
///
/// They follow Mokkari's schemas (Metron's own Python client).
enum Responses {
  /// A list response's wrapper, one page of results.
  struct Page<Result: Decodable>: Decodable {
    let results: [Result]
  }

  /// A series as an issue list embeds it.
  struct SeriesSummary: Decodable {
    let id: Int
    let name: String?
    let volume: Int?
    let yearBegan: Int?
  }

  /// An issue as the issue list returns it.
  struct IssueSummary: Decodable {
    enum CodingKeys: String, CodingKey {
      case coverDate, id, number, series
      case displayName = "issue"
    }

    let coverDate: String?
    /// Metron's name for the issue, such as "Saga (2012) #1".
    let displayName: String?
    let id: Int
    let number: String?
    let series: SeriesSummary
  }
}
