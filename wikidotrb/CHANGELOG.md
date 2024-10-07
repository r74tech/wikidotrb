# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [released]

## [3.0.7.pre] - 2024-10-06

### Added
- Initial release of `wikidotrb`, a Ruby library inspired by `wikidot.py`.

## [3.0.7.pre.1] - 2024-10-08

### Changed
- Improved `UserParser.parse` method to convert non-`Nokogiri::XML::Element` elements properly before processing.

## [3.0.7.pre.2] - 2024-10-08

### Fixed
- Corrected the instantiation of `PageRevisionCollection` by ensuring it properly passes `page` and `revisions` as named parameters.

## [3.0.7.pre.3] - 2024-10-08

### Fixed
- Remove debug `puts` statement from `PageCollection` instantiation.