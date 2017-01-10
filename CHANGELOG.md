# 1.2.2 2017/1/9

- Remove any single quotes from podspec files around version strings, as well as double quotes
- Xcode 8.2 support, building legacy Swift

# 1.2.0 2016/7/16

- Taught `semver` to accept just `--try` and `--current-version` options to essentially calculate the next version and see what it will output.
- Taught `semver` to only read the current version from specified file and print it to output with the `--read` option.
- Fall back to a default key if none is specified on the command line with `--key`, defined per file type and version type.
- Add CocoaPods podspec file type support, with a default key of `version`.
- Fix bug where using `--current-version` could result in incorrect replacement of new version information.

# 1.1.0 - 2016/7/7

- Added usage notes for `--file` and `--key` flags
- Added a `--try` option to only output what the tool will do, without actually modifying any files.
- Added a `--current-version` option to override whatever preexisting version info may be found at the specified --file/--key pair.
- Fixed parsing of build metadata and release identifiers to handle hyphens in their content.

# 1.0.0 - 2016/7/4

- Initial commit
- Command line tool with basic functionality to bump semver and pure numerical version information in either xcconfig or plist files.
