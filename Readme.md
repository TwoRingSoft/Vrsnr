[![Build Status](https://travis-ci.org/TwoRingSoft/SemVer.svg?branch=master)](https://travis-ci.org/TwoRingSoft/SemVer)
[![Semver](http://img.shields.io/SemVer/1.1.0.png)](http://semver.org/spec/v2.0.0.html)

# SemVer

Let's say you write software. Maybe you've dabbled with package managers. Such helpful little building blocks. They all come with versions. Lots of them, in all different schemes, systems, shapes, sizes. They're changing all the time, and no-one knows [why](http://sentimentalversioning.org). 

Semantic versioning is here to help. It helps producers and consumers of software, and end users too, by allowing everyone involved to communicate about each how each release changes the product. For more on semantic versioning, see [semver.org](http://semver.org).

---

**SemVer** is a set of tools to help keep your library/app/whatever's version up to date. One `semver` command can increment the version by modifying the file containing its definition. 

It can do other neat things too, like:

- understand plain integer version numbers, like for builds
- translate cat-speak to english and back 

---

## Example

If I just want to change the version currently written in a file and save it, I can issue a command like one of these:

```
semver major --file ~/MyProject/Config.xcconfig --key CURRENT_PROJECT_VERSION
semver --numeric --file ~/MyProject/Config.xcconfig --key DYLIB_CURRENT_VERSION
```

##### What else can you do with it?

- automatically revision every build in a [pre-commit hook](http://stackoverflow.com/questions/17101473/change-version-file-automatically-on-commit-with-git/17101505#17101505)... "`command-that-increases-version`"! That's `semver`!!
- bump version numbers in package manager specfiles or deliverables
- add special information to the version before an automated staging build
- move objects with the powers of your mind

...and much more!

## Installation

```
brew tap tworingsoft/formulae
brew install semver

# or 

brew install tworingsoft/formulae/semver

# don't forget to read the fine print!

semver --help
```

#### Upgrading

```
brew update
brew upgrade [tworingsoft/formulae/]semver
```

## Building & testing

The command line application is built with the `semver` target and Mac app with `SemVer.app`. Unit tests are run via `SemVerTests` and integration tests via `SemVerIntegrations`. Travis runs both test schemes using Scripts/test.sh.

## Supported file formats

`semver` currently knows how to parse the value of a given key from the following file types:

- .xcconfig
- .plist
- .podspec

## Contributing

Bugfixes, new file type support, and new feature requests are welcomed! Please do the following:

- open an [issue](https://github.com/TwoRingSoft/SemVer/issues/new)
- fork the repo
- make changes and test
- open a [pull request](https://github.com/TwoRingSoft/SemVer/compare) linking to the issue

## Future work

- More filetypes
- Git tagging
- Caching
- Mac app front end
