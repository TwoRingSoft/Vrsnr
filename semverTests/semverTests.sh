#!/bin/sh

#  semverTests.sh
#  semver
#
#  Created by Andrew McKnight on 6/29/16.
#  Copyright © 2016 Two Ring Software. All rights reserved.

#  Note: written to be run from the root directory in the repo

SMVR_LOCATION="${1}" # path to the 'semver' executable to use

function runTest() {
    SMVR_TEST_NAME="${1}"
    SMVR_TEST_FILE="${2}"
    SMVR_TEST_KEY="${3}"
    SMVR_TEST_SEMVER_COMPONENT="${4}"
    SMVR_TEST_OPTIONS="${5}"

    SMVR_BACKUP_TEST_FILE="${SMVR_TEST_FILE}.orig"

    SMVR_TEST_RESULTS_DIR="semverTests/results"
    mkdir -p "${SMVR_TEST_RESULTS_DIR}"

    SMVR_TEST_RESULTS_FILE="${SMVR_TEST_RESULTS_DIR}/${SMVR_TEST_NAME}.results"
    SMVR_TEST_BASELINE_RESULTS_FILE="semverTests/baseLines/${SMVR_TEST_NAME}.results"

    SMVR_TEST_BASELINE_DELTA_REPORT="${SMVR_TEST_RESULTS_DIR}/${SMVR_TEST_NAME}.baseline-diff"

    # make copy of original file
    cp "${SMVR_TEST_FILE}" "${SMVR_BACKUP_TEST_FILE}"

    # perform the SMVR
    eval "${SMVR_LOCATION}/semver ${SMVR_TEST_SEMVER_COMPONENT} --file ${SMVR_TEST_FILE} --key ${SMVR_TEST_KEY} ${SMVR_TEST_OPTIONS}"

    # compare the modified file to copy of original
    diff "${SMVR_TEST_FILE}" "${SMVR_BACKUP_TEST_FILE}" > "${SMVR_TEST_RESULTS_FILE}"

    # compare new results to baseline results; they should be identical
    diff "${SMVR_TEST_BASELINE_RESULTS_FILE}" "${SMVR_TEST_RESULTS_FILE}"
    if [[ $? == 0 ]]; then
        rm "${SMVR_TEST_RESULTS_FILE}" # don't save results output for cases that pass
    else
        diff "${SMVR_TEST_BASELINE_RESULTS_FILE}" "${SMVR_TEST_RESULTS_FILE}" > "${SMVR_TEST_BASELINE_DELTA_REPORT}"
    fi

    # reset the file back to its original state
    rm "${SMVR_TEST_FILE}"
    mv "${SMVR_BACKUP_TEST_FILE}" "${SMVR_TEST_FILE}"

}

# plist tests
runTest "plist-semver-major" "semverTests/Fixtures/Sample.plist" "CFBundleShortVersionString" "major"       ""
runTest "plist-semver-minor" "semverTests/Fixtures/Sample.plist" "CFBundleShortVersionString" "minor"       ""
runTest "plist-semver-patch" "semverTests/Fixtures/Sample.plist" "CFBundleShortVersionString" "patch"       ""
runTest "plist-numerical"    "semverTests/Fixtures/Sample.plist" "CFBundleVersion"            "--numeric"   ""

runTest "plist-semver-major-try" "semverTests/Fixtures/Sample.plist" "CFBundleShortVersionString" "major"       "--try"
runTest "plist-semver-minor-try" "semverTests/Fixtures/Sample.plist" "CFBundleShortVersionString" "minor"       "--try"
runTest "plist-semver-patch-try" "semverTests/Fixtures/Sample.plist" "CFBundleShortVersionString" "patch"       "--try"
runTest "plist-numerical-try"    "semverTests/Fixtures/Sample.plist" "CFBundleVersion"            "--numeric"   "--try"

# xcconfig tests
runTest "xcconfig-semver-major" "semverTests/Fixtures/Sample.xcconfig" "CURRENT_PROJECT_VERSION" "major"        ""
runTest "xcconfig-semver-minor" "semverTests/Fixtures/Sample.xcconfig" "CURRENT_PROJECT_VERSION" "minor"        ""
runTest "xcconfig-semver-patch" "semverTests/Fixtures/Sample.xcconfig" "CURRENT_PROJECT_VERSION" "patch"        ""
runTest "xcconfig-numerical"    "semverTests/Fixtures/Sample.xcconfig" "DYLIB_CURRENT_VERSION"   "--numeric"    ""

runTest "xcconfig-semver-major-try" "semverTests/Fixtures/Sample.xcconfig" "CURRENT_PROJECT_VERSION" "major"        "--try"
runTest "xcconfig-semver-minor-try" "semverTests/Fixtures/Sample.xcconfig" "CURRENT_PROJECT_VERSION" "minor"        "--try"
runTest "xcconfig-semver-patch-try" "semverTests/Fixtures/Sample.xcconfig" "CURRENT_PROJECT_VERSION" "patch"        "--try"
runTest "xcconfig-numerical-try"    "semverTests/Fixtures/Sample.xcconfig" "DYLIB_CURRENT_VERSION"   "--numeric"    "--try"
