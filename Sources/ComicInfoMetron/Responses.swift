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

  /// A named resource as Metron embeds it in another: a publisher, a role, a genre, a character.
  struct Item: Decodable {
    let id: Int
    let name: String?
  }

  /// A series as an issue's detail embeds it.
  struct Series: Decodable {
    let genres: [Item]?
    let id: Int
    let name: String?
    let volume: Int?
    let yearBegan: Int?
  }

  /// A creator and every role they had on an issue.
  struct Credit: Decodable {
    let creator: String
    let role: [Item]?
  }

  /// One issue's full detail.
  struct Issue: Decodable {
    enum CodingKeys: String, CodingKey {
      case arcs, characters, coverDate, credits, desc, id, imprint, number, publisher, resourceUrl, series, teams, title
      case storyTitles = "name"
    }

    let arcs: [Item]?
    let characters: [Item]?
    let coverDate: String?
    let credits: [Credit]?
    let desc: String?
    let id: Int
    let imprint: Item?
    let number: String?
    let publisher: Item?
    /// The issue's page on Metron's site.
    let resourceUrl: String?
    let series: Series
    /// The titles of the stories inside, Metron's `name`.
    let storyTitles: [String]?
    let teams: [Item]?
    /// The collection's title, often blank.
    let title: String?
  }
}
