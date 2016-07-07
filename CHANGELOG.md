# 1.0.0 - 2016/7/4

- Initial commit
- Command line tool with basic functionality to bump semver and pure numerical version information in either xcconfig or plist files.

# 1.1.0 - 2016/7/7

- Added usage notes for "--file" and "--file" flags
- Added a "--try" option to only output what the tool will do, without actually modifying any files.
- Added a "--current-version" option to override whatever preexisting version info may be found at the specified --file/--key pair.
- Fixed parsing of build metadata and release identifiers to handle hyphens in their content.
