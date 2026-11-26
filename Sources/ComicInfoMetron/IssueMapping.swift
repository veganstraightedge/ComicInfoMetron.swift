//
// IssueMapping.swift
// ComicInfoMetron
//

import ComicInfo
import Foundation

/// A Metron issue as a `ComicInfo.Issue`.
struct IssueMapping {
  let issue: ComicInfo.Issue

  init(issue found: Responses.Issue) {
    let credits = Credits(found.credits ?? [])
    let coverDate = CoverDate(found.coverDate)
    let volume = found.series.volume.flatMap { $0 > 0 ? $0 : nil }

    issue = ComicInfo.Issue(
      colorist: credits.names("colorist"),
      coverArtist: credits.names("cover"),
      editor: credits.names("editor"),
      imprint: Metron.nonBlank(found.imprint?.name),
      inker: credits.names("inker", "artist"),
      letterer: credits.names("letterer"),
      month: coverDate.month,
      number: Metron.nonBlank(found.number),
      penciller: credits.names("penciller", "artist"),
      publisher: Metron.nonBlank(found.publisher?.name),
      series: Metron.nonBlank(found.series.name),
      storyArc: Self.joined(found.arcs),
      summary: Metron.nonBlank(found.desc),
      title: Self.title(found),
      translator: credits.names("translator"),
      volume: volume,
      writer: credits.names("writer", "script", "story", "plot"),
      year: coverDate.year
    )
    .settingCharacters(Self.names(found.characters))
    .settingGenres(Self.names(found.series.genres))
    .settingTeams(Self.names(found.teams))
    .settingWebLinks([found.resourceUrl].compactMap(\.self))
  }

  /// The collection's title, or else its first story's.
  private static func title(_ found: Responses.Issue) -> String? {
    Metron.nonBlank(found.title) ?? (found.storyTitles ?? []).lazy.compactMap(Metron.nonBlank).first
  }

  private static func names(_ items: [Responses.Item]?) -> [String] {
    (items ?? []).compactMap(\.name)
  }

  private static func joined(_ items: [Responses.Item]?) -> String? {
    Metron.nonBlank(names(items).joined(separator: ", "))
  }
}

/// A cover date such as "2012-03-01", as a year and month.
///
/// The day is left out: a cover date carries the 1st when only the month is known.
private struct CoverDate {
  let year: Int?
  let month: Int?

  init(_ text: String?) {
    let parts = (text ?? "").split(separator: "-")
    year = parts.count >= 2 ? Int(parts[0]) : nil
    month = parts.count >= 2 ? Int(parts[1]) : nil
  }
}

/// The creators credited on an issue, and their roles.
private struct Credits {
  private let credits: [Responses.Credit]

  init(_ credits: [Responses.Credit]) {
    self.credits = credits
  }

  /// Everyone credited with any of `roles` (lowercase), each once, in credit order, or `nil` when no one is.
  func names(_ roles: String...) -> String? {
    var people: [String] = []
    for credit in credits where !people.contains(credit.creator) {
      let creditRoles = (credit.role ?? []).compactMap { $0.name?.lowercased() }
      if creditRoles.contains(where: roles.contains) {
        people.append(credit.creator)
      }
    }
    return people.isEmpty ? nil : people.joined(separator: ", ")
  }
}
