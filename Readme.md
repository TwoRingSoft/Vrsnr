[![Build Status](https://travis-ci.org/TwoRingSoft/semver.svg?branch=master)](https://travis-ci.org/TwoRingSoft/semver)

# SemVer

A command line tool for managing semantic versioning, with support for plain integer version numbers as well. Adheres to the semver rules laid out at [semver.org](http://semver.org).

## Example

```
semver major --file ~/MyProject/Config.xcconfig --key CURRENT_PROJECT_VERSION
semver --numeric --file ~/MyProject/Config.xcconfig --key DYLIB_CURRENT_VERSION
```

## Supported formats

`semver` currently understands how to parse the value of a given key from the following file types:

- .xcconfig
- .plist

## Contributing

Bugfixes, new file type support, and new feature requests are welcomed. To submit something, please do the following:

- open an issue
- fork the repo
- open a PR linking to the issue

## Future work

- Defaults for semver/numeric keys per filetype.
