import ComicInfo
import Foundation
import Testing

@testable import ComicInfoMetron

struct MetronTests {
  private let metron = Metron(token: "test-token", userAgent: "ComicInfoMetronTests/1.0")
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
}
