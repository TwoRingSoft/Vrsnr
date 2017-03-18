set -eu pipefail

#
# Integration tests
#

if [[ $VRSN_TRAVIS_BUILD -eq 1 ]]; then
    echo "travis_fold:start:Integration tests"
    echo "Integration tests:"
    echo
fi

xcodebuild -project Vrsnr/Vrsnr.xcodeproj -scheme vrsnTests clean build

if [[ $VRSN_TRAVIS_BUILD -eq 1 ]]; then
    echo "travis_fold:end:Integration tests"
    echo
fi

#
# Unit tests
#

if [[ $VRSN_TRAVIS_BUILD -eq 1 ]]; then
    echo "travis_fold:start:Unit tests"
    echo "Unit tests:"
    echo
fi

xcodebuild -project Vrsnr/Vrsnr.xcodeproj -scheme VrsnrTests clean test

if [[ $VRSN_TRAVIS_BUILD -eq 1 ]]; then
    echo "travis_fold:end:Unit tests"
    echo
fi
