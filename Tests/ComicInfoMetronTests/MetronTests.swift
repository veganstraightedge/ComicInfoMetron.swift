import ComicInfo
import Foundation
import Testing

@testable import ComicInfoMetron

struct MetronTests {
  private let metron = Metron(
    token: FixtureURLProtocol.token, userAgent: FixtureURLProtocol.userAgent, session: FixtureURLProtocol.session)
  private let issue = ComicInfo.Issue(number: "1", series: "Saga")

  @Test func testItIsCreditedAsMetron() {
    #expect(metron.name == "Metron")
    #expect(metron.homeURL.absoluteString == "https://metron.cloud/")
  }

  @Test func testItNeedsASeriesAndANumber() {
    #expect(metron.missingDetails(for: issue) == nil)
    #expect(metron.missingDetails(for: ComicInfo.Issue(number: "1", series: "Saga", year: 2012)) == nil)
    #expect(metron.missingDetails(for: ComicInfo.Issue(number: "1")) == "Metron needs a Series and a Number to search for.")
    #expect(metron.missingDetails(for: ComicInfo.Issue(series: "Saga")) != nil)
    #expect(metron.missingDetails(for: ComicInfo.Issue(number: " ", series: "Saga")) != nil)
  }

  @Test func testMatchesAreTheNumberedIssueInEverySeriesNamedLikeIt() async throws {
    let matches = try await metron.matches(for: issue)

    #expect(matches.map(\.id) == ["31660", "99901"])
    let match = try #require(matches.first)
    #expect(match.heading == "Saga (2012) #1")
    #expect(match.series == "Saga")
    #expect(match.number == "1")
    #expect(match.title == nil)
    #expect(match.coverDate == "2012-03-01")
    #expect(match.details == "Cover date 2012-03-01")
    #expect(match.siteURL == nil)
  }

  @Test func testAYearNarrowsTheSearchToIssuesCoveredThatYear() async throws {
    let matches = try await metron.matches(for: ComicInfo.Issue(number: "1", series: "Saga", year: 2012))

    #expect(matches.map(\.heading) == ["Saga (2012) #1"])
  }

  @Test func testTheSeriesAndNumberAreSearchedForTrimmed() async throws {
    let matches = try await metron.matches(for: ComicInfo.Issue(number: " 1 ", series: " Saga "))

    #expect(matches.map(\.series) == ["Saga", "Saga of the Swamp Thing"])
  }

  @Test func testAWrongTokenIsUnauthorized() async {
    let wrongToken = Metron(token: "wrong", userAgent: FixtureURLProtocol.userAgent, session: FixtureURLProtocol.session)
    await #expect(throws: MetronError.httpStatus(401)) {
      try await wrongToken.matches(for: issue)
    }
  }

  @Test func testAnUnnamedAppIsForbidden() async {
    let unnamed = Metron(token: FixtureURLProtocol.token, userAgent: "", session: FixtureURLProtocol.session)
    await #expect(throws: MetronError.httpStatus(403)) {
      try await unnamed.matches(for: issue)
    }
  }

  @Test func testAnHTTPErrorSaysSo() {
    #expect(MetronError.httpStatus(429).localizedDescription == "Metron answered with HTTP status 429.")
  }
}
