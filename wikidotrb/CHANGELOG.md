# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [released]

## [3.0.7.pre.6] - 2024-10-08

### Changed
- Refactored `UserParser.parse` to better handle the string `"(user deleted)"` as input. 

### Added
- Private helper method `deleted_user_string?` to clearly separate the logic for parsing `"(user deleted)"`.

### Improved
- Made parsing helper methods (`parse_deleted_user`, `parse_anonymous_user`, `parse_guest_user`, `parse_wikidot_user`, `parse_regular_user`) private to encapsulate their functionality.

### Fixed
- Added `nil` check for `user_anchor` in `parse_regular_user` to prevent errors when user information is missing.

## [3.0.7.pre.5] - 2024-10-08

### Fixed
- Remove debug `puts` statement from `PageCollection` instantiation.

## [3.0.7.pre.4] - 2024-10-08

### Fixed
- Fixed an issue where the `acquire_sources` and `acquire_htmls` methods incorrectly parsed the `response` object. Now directly access `response["body"]` without unnecessary parsing.

## [3.0.7.pre.3] - 2024-10-08

### Fixed
- Remove debug `puts` statement from `PageCollection` instantiation.

## [3.0.7.pre.2] - 2024-10-08

### Fixed
- Corrected the instantiation of `PageRevisionCollection` by ensuring it properly passes `page` and `revisions` as named parameters.

## [3.0.7.pre.1] - 2024-10-08

### Changed
- Improved `UserParser.parse` method to convert non-`Nokogiri::XML::Element` elements properly before processing.

## [3.0.7.pre] - 2024-10-06

### Added
- Initial release of `wikidotrb`, a Ruby library inspired by `wikidot.py`.

[unreleased]: https://github.com/r74tech/wikidotrb/compare/3.0.7.pre.6...HEAD
[0.0.7]: https://github.com/r74tech/wikidotrb/compare/3.0.7.pre.5...3.0.7.pre.6
[0.0.6]: https://github.com/r74tech/wikidotrb/compare/3.0.7.pre.4...3.0.7.pre.5
[0.0.5]: https://github.com/r74tech/wikidotrb/compare/3.0.7.pre.3...3.0.7.pre.4
[0.0.4]: https://github.com/r74tech/wikidotrb/compare/3.0.7.pre.2...3.0.7.pre.3
[0.0.3]: https://github.com/r74tech/wikidotrb/compare/3.0.7.pre.1...3.0.7.pre.2
[0.0.2]: https://github.com/r74tech/wikidotrb/compare/3.0.7.pre...3.0.7.pre.1
[0.0.1]: https://github.com/r74tech/wikidotrb/releases/tag/3.0.7.pre
