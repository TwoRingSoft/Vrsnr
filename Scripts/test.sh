set -eu pipefail

#
# Integration tests
#

if [[ $SMVR_TRAVIS_BUILD -eq 1 ]]; then
    echo "travis_fold:start:Integration tests"
    echo "Integration tests:"
    echo
fi

xcodebuild -project SemVer/SemVer.xcodeproj -scheme SemVerIntegrations clean build

if [[ $SMVR_TRAVIS_BUILD -eq 1 ]]; then
    echo "travis_fold:end:Integration tests"
    echo
fi

#
# Unit tests
#

if [[ $SMVR_TRAVIS_BUILD -eq 1 ]]; then
    echo "travis_fold:start:Unit tests"
    echo "Unit tests:"
    echo
fi

xcodebuild -project SemVer/SemVer.xcodeproj -scheme SemVerTests clean test

if [[ $SMVR_TRAVIS_BUILD -eq 1 ]]; then
    echo "travis_fold:end:Unit tests"
    echo
fi
