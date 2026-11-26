# ComicInfoMetron.swift

Looks up comic details in [Metron](https://metron.cloud), for [ComicInfo.swift](https://github.com/veganstraightedge/ComicInfo.swift).

`Metron` is a `ComicInfo.MetadataSource`: it searches Metron for an issue, and returns what Metron knows about the one picked as a `ComicInfo.Issue`. See [Looking Up Details in Online Databases](https://github.com/veganstraightedge/ComicInfo.swift/blob/main/doc/metadata-sources.md).

It's the Swift counterpart of [comicinfo-metron](https://github.com/veganstraightedge/comicinfo-metron), and a sibling of [ComicInfoComicVine.swift](https://github.com/veganstraightedge/ComicInfoComicVine.swift).

## Installation

```swift
dependencies: [
  .package(url: "https://github.com/veganstraightedge/ComicInfoMetron.swift.git", from: "0.1.0")
]
```

## Usage

```swift
import ComicInfo
import ComicInfoMetron

let metron = Metron(token: "your API token", userAgent: "MyApp/1.0")

let issue = ComicInfo.Issue(number: "1", series: "Saga")
let matches = try await metron.matches(for: issue)    // best first
let found = try await metron.issue(for: matches[0])   // after a person picks one
let updated = issue.fillingBlanks(from: found)
```

- `matches(for:)` needs a Series and a Number; `missingDetails(for:)` says so when either is blank. A Year is optional: when there is one, only issues with a cover dated that year are found.
- It finds the issue with that number in every series whose name contains the issue's series, and ranks the matches by series name, then cover year.
- A match has no site URL: Metron's issue pages are addressed by a slug its search results don't include.
- `issue(for:)` reads the issue: series, volume, title (or else its first story's title), cover year and month, publisher, imprint, summary, genres, credits by role, characters, teams, story arcs, and the issue's Metron page as its web link.
- A request Metron refuses throws `MetronError.httpStatus`, such as 401 for a wrong token.

## Credit

Comic details from [Metron](https://metron.cloud). Whatever shows Metron's data must credit and link to Metron (`metron.name`, `metron.homeURL`).

## Requirements

- Swift 6.4+
- macOS 27+ or iOS 27+

## Development

```sh
script/test     # swift test
script/lint     # swift format lint --strict
script/format   # swift format --in-place
```

The tests answer every request with a Metron response from `Tests/ComicInfoMetronTests/Fixtures/`, so they need no token or network. The fixtures follow the schemas of [Mokkari](https://github.com/Metron-Project/mokkari), Metron's Python client; they weren't recorded from the live API.

## License

[MIT](LICENSE.md)
