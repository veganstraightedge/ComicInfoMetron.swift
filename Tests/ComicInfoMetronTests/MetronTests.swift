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

  @Test func testTheIssueHasEverythingMetronKnows() async throws {
    let match = try #require(try await metron.matches(for: issue).first)
    let found = try await metron.issue(for: match)

    #expect(found.series == "Saga")
    #expect(found.volume == 1)
    #expect(found.number == "1")
    #expect(found.title == "Chapter One")
    #expect(found.count == nil)
    #expect(found.year == 2012)
    #expect(found.month == 3)
    #expect(found.day == nil)
    #expect(found.publisher == "Image")
    #expect(found.imprint == nil)
    #expect(found.summary == "Two soldiers from opposite sides of a never-ending galactic war fall in love.")
    #expect(found.genres == ["Fantasy", "Science Fiction"])
    #expect(found.webLinks == ["https://metron.cloud/issue/saga-2012-1/"])
  }

  @Test func testCreditsGoToTheirRoles() async throws {
    let match = try #require(try await metron.matches(for: issue).first)
    let found = try await metron.issue(for: match)

    #expect(found.writer == "Brian K. Vaughan")
    #expect(found.penciller == "Fiona Staples")
    #expect(found.inker == "Fiona Staples")
    #expect(found.colorist == nil)
    #expect(found.letterer == "Fonografiks")
    #expect(found.coverArtist == "Fiona Staples")
    #expect(found.editor == "Eric Stephenson")
    #expect(found.translator == nil)
  }

  @Test func testCharactersTeamsAndStoryArcs() async throws {
    let match = try #require(try await metron.matches(for: issue).first)
    let found = try await metron.issue(for: match)

    #expect(found.characters == ["Alana", "Marko"])
    #expect(found.teams == [])
    #expect(found.storyArc == "Chapter One")
  }

  @Test func testTheFoundIssueOnlyFillsBlanks() async throws {
    let match = try #require(try await metron.matches(for: issue).first)
    let found = try await metron.issue(for: match)
    let mine = ComicInfo.Issue(number: "1", series: "My Saga", writer: "Me")

    let updated = mine.fillingBlanks(from: found)

    #expect(updated.series == "My Saga")
    #expect(updated.writer == "Me")
    #expect(updated.publisher == "Image")
  }

  @Test func testAMatchWithoutAMetronIssueIDIsAnError() async {
    let match = ComicInfo.Match(id: "saga-2012-1", heading: "Saga (2012) #1", series: "Saga")
    await #expect(throws: MetronError.invalidIssueID("saga-2012-1")) {
      try await metron.issue(for: match)
    }
  }

  @Test func testAnIssueMetronDoesNotHaveIsNotFound() async {
    let match = ComicInfo.Match(id: "1", heading: "Nothing #1", series: "Nothing")
    await #expect(throws: MetronError.httpStatus(404)) {
      try await metron.issue(for: match)
    }
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
    #expect(MetronError.invalidIssueID("x").localizedDescription == "“x” isn't a Metron issue ID.")
  }
}
