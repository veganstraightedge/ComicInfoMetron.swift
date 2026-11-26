//
// MetronError.swift
// ComicInfoMetron
//

import Foundation

/// Why a Metron request failed.
public enum MetronError: Error, Equatable, LocalizedError {
  /// Metron answered with an HTTP error status, such as 401 for a wrong token, or 429.
  case httpStatus(Int)
  /// A match's ID isn't a Metron issue ID, so it can't have come from `Metron`.
  case invalidIssueID(String)

  public var errorDescription: String? {
    switch self {
    case .httpStatus(let status): "Metron answered with HTTP status \(status)."
    case .invalidIssueID(let id): "“\(id)” isn't a Metron issue ID."
    }
  }
}
