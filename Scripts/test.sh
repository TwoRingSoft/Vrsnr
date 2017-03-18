set -e

#
# Build vrsn
#

if [[ ${VRSN_TRAVIS_BUILD:=0} -eq 1 ]]; then
    echo "travis_fold:start:Build vrsn"
    echo "Build vrsn:"
    echo
fi

xcodebuild -project Vrsnr/Vrsnr.xcodeproj -scheme vrsn clean build | xcpretty

if [[ ${VRSN_TRAVIS_BUILD:=0} -eq 1 ]]; then
    echo "travis_fold:end:Build vrsn"
    echo
fi

#
# CLI tests
#

if [[ ${VRSN_TRAVIS_BUILD:=0} -eq 1 ]]; then
    echo "travis_fold:start:CLI tests"
    echo "CLI tests:"
    echo
fi

xcodebuild -project Vrsnr/Vrsnr.xcodeproj -scheme vrsnTests build

if [[ ${VRSN_TRAVIS_BUILD:=0} -eq 1 ]]; then
    echo "travis_fold:end:CLI tests"
    echo
fi

#
# Unit tests
#

if [[ ${VRSN_TRAVIS_BUILD:=0} -eq 1 ]]; then
    echo "travis_fold:start:Unit tests"
    echo "Unit tests:"
    echo
fi

xcodebuild -project Vrsnr/Vrsnr.xcodeproj -scheme VrsnrTests clean test | xcpretty

if [[ ${VRSN_TRAVIS_BUILD:=0} -eq 1 ]]; then
    echo "travis_fold:end:Unit tests"
    echo
fi
