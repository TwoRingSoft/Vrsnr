# Vrsnr [![Build Status](https://travis-ci.org/TwoRingSoft/Vrsnr.svg?branch=master)](https://travis-ci.org/TwoRingSoft/Vrsnr)

Let's say you write software. Maybe you've dabbled with package managers. Such helpful little building blocks. They all come with versions. Lots of them, in all different schemes, systems, shapes, sizes. They're changing all the time, and no-one knows [why](http://sentimentalversioning.org). 

Semantic versioning is here to help. It helps producers and consumers of software, and end users too, by allowing everyone involved to communicate about each how each release changes the product. For more on semantic versioning, see [semver.org](http://semver.org).

---

**Vrsnr** is a set of tools to help keep your library/app/whatever's version up to date. One `vrsn` command can increment the version by modifying the file containing its definition. 

It can do other neat things too, like:

- understand plain integer version numbers, like for builds
- translate all cat languages in the basic multifeline plane

---

## Example

If I just want to change the version currently written in a file and save it, I can issue a command like one of these:

```
vrsn major --file ~/MyProject/Config.xcconfig --key CURRENT_PROJECT_VERSION
vrsn --numeric --file ~/MyProject/Config.xcconfig --key DYLIB_CURRENT_VERSION
```

##### What else can you do with it?

- automatically revision every build in a [pre-commit hook](http://stackoverflow.com/questions/17101473/change-version-file-automatically-on-commit-with-git/17101505#17101505)... "`command-that-increases-version`"! That's `vrsn`!!
- bump version numbers in package manager specfiles or deliverables
- add special information to the version before an automated staging build

...and much more!

## Installation

```
brew tap tworingsoft/formulae
brew install vrsn

# or 

brew install tworingsoft/formulae/vrsn

# don't forget to read the fine print!

vrsn --help
```

#### Upgrading

```
brew update
brew upgrade [tworingsoft/formulae/]vrsn
```

## Building & testing

The command line application is built with the `vrsn` target and Mac app with `Vrsnr`. App tests are run via `VrsnrTests` and CLI tests via `vrsnTests`. Travis runs both test schemes using Scripts/test.sh.

If you make a change that breaks `vrsnTests` because the baseline output needs to be updated, run `rake update_baselines`. Don't check in `vrsnTests/rsults`.

## Supported file formats

`vrsn` currently knows how to parse the value of a given key from the following file types:

- .xcconfig
- .plist
- .podspec

## Contributing

Bugfixes, new file type support, and new feature requests are welcomed! Please do the following:

- open an [issue](https://github.com/TwoRingSoft/Vrsnr/issues/new)
- fork the repo
- make changes and test
- open a [pull request](https://github.com/TwoRingSoft/Vrsnr/compare) linking to the issue

## Future work

- More filetypes
- Git tagging
- Caching
- Mac app front end
