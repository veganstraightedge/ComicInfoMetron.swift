//
// MetronError.swift
// ComicInfoMetron
//

import Foundation

/// Why a Metron request failed.
public enum MetronError: Error, Equatable, LocalizedError {
  /// Metron answered with an HTTP error status, such as 401 for a wrong token, or 429.
  case httpStatus(Int)

  public var errorDescription: String? {
    switch self {
    case .httpStatus(let status): "Metron answered with HTTP status \(status)."
    }
  }
}
