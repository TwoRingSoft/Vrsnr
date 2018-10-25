#!/bin/sh

#  vrsnTests.sh
#  vrsn
#
#  Created by Andrew McKnight on 6/29/16.
#  Copyright © 2016 Two Ring Software. All rights reserved.

#  Note: written to be run from the root directory in the repo

VRSN_LOCATION="${1}" # path to the 'vrsn' executable to use

function runTest() {
    VRSN_TEST_NAME="${1}"
    VRSN_TEST_FILE="${2}"
    VRSN_TEST_SEMANTIC_VERSION_COMPONENT="${3}"
    VRSN_TEST_OPTIONS="${4}"

    VRSN_BACKUP_TEST_FILE="${VRSN_TEST_FILE}.orig"

    VRSN_TEST_RESULTS_DIR="vrsnTests/results"
    mkdir -p "${VRSN_TEST_RESULTS_DIR}"

    VRSN_TEST_RESULTS_FILE="${VRSN_TEST_RESULTS_DIR}/${VRSN_TEST_NAME}.results"
    VRSN_TEST_BASELINE_RESULTS_FILE="vrsnTests/baseLines/${VRSN_TEST_NAME}.results"
    # make copy of original file
    cp "${VRSN_TEST_FILE}" "${VRSN_BACKUP_TEST_FILE}"

    # perform the command
    VRSN_CMD="vrsn ${VRSN_TEST_SEMANTIC_VERSION_COMPONENT} --file ${VRSN_TEST_FILE} ${VRSN_TEST_OPTIONS}"

    echo $VRSN_CMD > "${VRSN_TEST_RESULTS_FILE}"
    eval "${VRSN_LOCATION}/${VRSN_CMD}" >> "${VRSN_TEST_RESULTS_FILE}"

    echo >> "${VRSN_TEST_RESULTS_FILE}"
    echo "Before:" >> "${VRSN_TEST_RESULTS_FILE}"
    echo >> "${VRSN_TEST_RESULTS_FILE}"
    cat "${VRSN_BACKUP_TEST_FILE}" >> "${VRSN_TEST_RESULTS_FILE}"

    echo >> "${VRSN_TEST_RESULTS_FILE}"
    echo "After:" >> "${VRSN_TEST_RESULTS_FILE}"
    echo >> "${VRSN_TEST_RESULTS_FILE}"
    cat "${VRSN_TEST_FILE}" >> "${VRSN_TEST_RESULTS_FILE}"

    # compare the modified file to copy of original
    echo >> "${VRSN_TEST_RESULTS_FILE}"
    echo "Difference:" >> "${VRSN_TEST_RESULTS_FILE}"
    echo >> "${VRSN_TEST_RESULTS_FILE}"
    diff "${VRSN_TEST_FILE}" "${VRSN_BACKUP_TEST_FILE}" >> "${VRSN_TEST_RESULTS_FILE}"

    # compare new results to baseline results; they should be identical unless intentionally changing something
    diff "${VRSN_TEST_BASELINE_RESULTS_FILE}" "${VRSN_TEST_RESULTS_FILE}" > /dev/null
    if [[ $? == 0 ]]; then
        printf '\e[1;32m✓' # print a green checkmark
        rm "${VRSN_TEST_RESULTS_FILE}" # don't save results output for cases that pass
    else
        diff "${VRSN_TEST_BASELINE_RESULTS_FILE}" "${VRSN_TEST_RESULTS_FILE}" | awk '{print "| " $0}'
		VRSN_FAILED=1
	    printf '\e[1;31m𐄂' # print a red x
    fi

    # reset the file back to its original state
    rm "${VRSN_TEST_FILE}"
    mv "${VRSN_BACKUP_TEST_FILE}" "${VRSN_TEST_FILE}"
}

function runTestFlavor() {
    VRSN_TEST_FLAVOR="${1}"
    VRSN_TEST_FLAVOR_OPTIONS="${2}"

    if [[ -z "${VRSN_TEST_FLAVOR}" ]]; then
        VRSN_FLAVOR_SUFFIX=""
    else
        VRSN_FLAVOR_SUFFIX="-${VRSN_TEST_FLAVOR}"
    fi

    VRSN_FIXTURE_DIR="vrsnTests/Fixtures"

    runTest "${VRSN_FILE_TYPE}-semantic-major${VRSN_FLAVOR_SUFFIX}" "${VRSN_FIXTURE_DIR}/Sample.${VRSN_FILE_TYPE}" "major"     "${VRSN_TEST_FLAVOR_OPTIONS}"
    runTest "${VRSN_FILE_TYPE}-semantic-minor${VRSN_FLAVOR_SUFFIX}" "${VRSN_FIXTURE_DIR}/Sample.${VRSN_FILE_TYPE}" "minor"     "${VRSN_TEST_FLAVOR_OPTIONS}"
    runTest "${VRSN_FILE_TYPE}-semantic-patch${VRSN_FLAVOR_SUFFIX}" "${VRSN_FIXTURE_DIR}/Sample.${VRSN_FILE_TYPE}" "patch"     "${VRSN_TEST_FLAVOR_OPTIONS}"
    runTest "${VRSN_FILE_TYPE}-numerical${VRSN_FLAVOR_SUFFIX}"    "${VRSN_FIXTURE_DIR}/Sample.${VRSN_FILE_TYPE}" "--numeric" "${VRSN_TEST_FLAVOR_OPTIONS}"

    runTest "${VRSN_FILE_TYPE}-semantic-major${VRSN_FLAVOR_SUFFIX}-custom-key" "${VRSN_FIXTURE_DIR}/Sample.${VRSN_FILE_TYPE}" "major"     "--key ${VRSN_FILE_SEMANTIC_VERSION_KEY} ${VRSN_TEST_FLAVOR_OPTIONS}"
    runTest "${VRSN_FILE_TYPE}-semantic-minor${VRSN_FLAVOR_SUFFIX}-custom-key" "${VRSN_FIXTURE_DIR}/Sample.${VRSN_FILE_TYPE}" "minor"     "--key ${VRSN_FILE_SEMANTIC_VERSION_KEY} ${VRSN_TEST_FLAVOR_OPTIONS}"
    runTest "${VRSN_FILE_TYPE}-semantic-patch${VRSN_FLAVOR_SUFFIX}-custom-key" "${VRSN_FIXTURE_DIR}/Sample.${VRSN_FILE_TYPE}" "patch"     "--key ${VRSN_FILE_SEMANTIC_VERSION_KEY} ${VRSN_TEST_FLAVOR_OPTIONS}"
    runTest "${VRSN_FILE_TYPE}-numerical${VRSN_FLAVOR_SUFFIX}-custom-key"    "${VRSN_FIXTURE_DIR}/Sample.${VRSN_FILE_TYPE}" "--numeric" "--key ${VRSN_FILE_NUMERIC_KEY} ${VRSN_TEST_FLAVOR_OPTIONS}"

    runTest "${VRSN_FILE_TYPE}-semantic-major${VRSN_FLAVOR_SUFFIX}-try" "${VRSN_FIXTURE_DIR}/Sample.${VRSN_FILE_TYPE}" "major"     "${VRSN_TEST_FLAVOR_OPTIONS} --try"
    runTest "${VRSN_FILE_TYPE}-semantic-minor${VRSN_FLAVOR_SUFFIX}-try" "${VRSN_FIXTURE_DIR}/Sample.${VRSN_FILE_TYPE}" "minor"     "${VRSN_TEST_FLAVOR_OPTIONS} --try"
    runTest "${VRSN_FILE_TYPE}-semantic-patch${VRSN_FLAVOR_SUFFIX}-try" "${VRSN_FIXTURE_DIR}/Sample.${VRSN_FILE_TYPE}" "patch"     "${VRSN_TEST_FLAVOR_OPTIONS} --try"
    runTest "${VRSN_FILE_TYPE}-numerical${VRSN_FLAVOR_SUFFIX}-try"    "${VRSN_FIXTURE_DIR}/Sample.${VRSN_FILE_TYPE}" "--numeric" "${VRSN_TEST_FLAVOR_OPTIONS} --try"

    runTest "${VRSN_FILE_TYPE}-semantic-major${VRSN_FLAVOR_SUFFIX}-custom-key-try" "${VRSN_FIXTURE_DIR}/Sample.${VRSN_FILE_TYPE}" "major"     "--key ${VRSN_FILE_SEMANTIC_VERSION_KEY} ${VRSN_TEST_FLAVOR_OPTIONS} --try"
    runTest "${VRSN_FILE_TYPE}-semantic-minor${VRSN_FLAVOR_SUFFIX}-custom-key-try" "${VRSN_FIXTURE_DIR}/Sample.${VRSN_FILE_TYPE}" "minor"     "--key ${VRSN_FILE_SEMANTIC_VERSION_KEY} ${VRSN_TEST_FLAVOR_OPTIONS} --try"
    runTest "${VRSN_FILE_TYPE}-semantic-patch${VRSN_FLAVOR_SUFFIX}-custom-key-try" "${VRSN_FIXTURE_DIR}/Sample.${VRSN_FILE_TYPE}" "patch"     "--key ${VRSN_FILE_SEMANTIC_VERSION_KEY} ${VRSN_TEST_FLAVOR_OPTIONS} --try"
    runTest "${VRSN_FILE_TYPE}-numerical${VRSN_FLAVOR_SUFFIX}-custom-key-try"    "${VRSN_FIXTURE_DIR}/Sample.${VRSN_FILE_TYPE}" "--numeric" "--key ${VRSN_FILE_NUMERIC_KEY} ${VRSN_TEST_FLAVOR_OPTIONS} --try"

    runTest "${VRSN_FILE_TYPE}-semantic-major${VRSN_FLAVOR_SUFFIX}-current-version-override" "${VRSN_FIXTURE_DIR}/Sample.${VRSN_FILE_TYPE}" "major"     "${VRSN_TEST_FLAVOR_OPTIONS} --current-version 1.2.3"
    runTest "${VRSN_FILE_TYPE}-semantic-minor${VRSN_FLAVOR_SUFFIX}-current-version-override" "${VRSN_FIXTURE_DIR}/Sample.${VRSN_FILE_TYPE}" "minor"     "${VRSN_TEST_FLAVOR_OPTIONS} --current-version 1.2.3"
    runTest "${VRSN_FILE_TYPE}-semantic-patch${VRSN_FLAVOR_SUFFIX}-current-version-override" "${VRSN_FIXTURE_DIR}/Sample.${VRSN_FILE_TYPE}" "patch"     "${VRSN_TEST_FLAVOR_OPTIONS} --current-version 1.2.3"
    runTest "${VRSN_FILE_TYPE}-numerical${VRSN_FLAVOR_SUFFIX}-current-version-override"    "${VRSN_FIXTURE_DIR}/Sample.${VRSN_FILE_TYPE}" "--numeric" "${VRSN_TEST_FLAVOR_OPTIONS} --current-version 1"

    runTest "${VRSN_FILE_TYPE}-semantic-major${VRSN_FLAVOR_SUFFIX}-custom-key-current-version-override" "${VRSN_FIXTURE_DIR}/Sample.${VRSN_FILE_TYPE}" "major"     "--key ${VRSN_FILE_SEMANTIC_VERSION_KEY} ${VRSN_TEST_FLAVOR_OPTIONS} --current-version 1.2.3"
    runTest "${VRSN_FILE_TYPE}-semantic-minor${VRSN_FLAVOR_SUFFIX}-custom-key-current-version-override" "${VRSN_FIXTURE_DIR}/Sample.${VRSN_FILE_TYPE}" "minor"     "--key ${VRSN_FILE_SEMANTIC_VERSION_KEY} ${VRSN_TEST_FLAVOR_OPTIONS} --current-version 1.2.3"
    runTest "${VRSN_FILE_TYPE}-semantic-patch${VRSN_FLAVOR_SUFFIX}-custom-key-current-version-override" "${VRSN_FIXTURE_DIR}/Sample.${VRSN_FILE_TYPE}" "patch"     "--key ${VRSN_FILE_SEMANTIC_VERSION_KEY} ${VRSN_TEST_FLAVOR_OPTIONS} --current-version 1.2.3"
    runTest "${VRSN_FILE_TYPE}-numerical${VRSN_FLAVOR_SUFFIX}-custom-key-current-version-override"    "${VRSN_FIXTURE_DIR}/Sample.${VRSN_FILE_TYPE}" "--numeric" "--key ${VRSN_FILE_NUMERIC_KEY} ${VRSN_TEST_FLAVOR_OPTIONS} --current-version 1"

    runTest "${VRSN_FILE_TYPE}-semantic-major${VRSN_FLAVOR_SUFFIX}-current-version-override-try" "${VRSN_FIXTURE_DIR}/Sample.${VRSN_FILE_TYPE}" "major"     "${VRSN_TEST_FLAVOR_OPTIONS} --current-version 1.2.3 --try"
    runTest "${VRSN_FILE_TYPE}-semantic-minor${VRSN_FLAVOR_SUFFIX}-current-version-override-try" "${VRSN_FIXTURE_DIR}/Sample.${VRSN_FILE_TYPE}" "minor"     "${VRSN_TEST_FLAVOR_OPTIONS} --current-version 1.2.3 --try"
    runTest "${VRSN_FILE_TYPE}-semantic-patch${VRSN_FLAVOR_SUFFIX}-current-version-override-try" "${VRSN_FIXTURE_DIR}/Sample.${VRSN_FILE_TYPE}" "patch"     "${VRSN_TEST_FLAVOR_OPTIONS} --current-version 1.2.3 --try"
    runTest "${VRSN_FILE_TYPE}-numerical${VRSN_FLAVOR_SUFFIX}-current-version-override-try"    "${VRSN_FIXTURE_DIR}/Sample.${VRSN_FILE_TYPE}" "--numeric" "${VRSN_TEST_FLAVOR_OPTIONS} --current-version 1 --try"

    runTest "${VRSN_FILE_TYPE}-semantic-major${VRSN_FLAVOR_SUFFIX}-custom-key-current-version-override-try" "${VRSN_FIXTURE_DIR}/Sample.${VRSN_FILE_TYPE}" "major"     "--key ${VRSN_FILE_SEMANTIC_VERSION_KEY} ${VRSN_TEST_FLAVOR_OPTIONS} --current-version 1.2.3 --try"
    runTest "${VRSN_FILE_TYPE}-semantic-minor${VRSN_FLAVOR_SUFFIX}-custom-key-current-version-override-try" "${VRSN_FIXTURE_DIR}/Sample.${VRSN_FILE_TYPE}" "minor"     "--key ${VRSN_FILE_SEMANTIC_VERSION_KEY} ${VRSN_TEST_FLAVOR_OPTIONS} --current-version 1.2.3 --try"
    runTest "${VRSN_FILE_TYPE}-semantic-patch${VRSN_FLAVOR_SUFFIX}-custom-key-current-version-override-try" "${VRSN_FIXTURE_DIR}/Sample.${VRSN_FILE_TYPE}" "patch"     "--key ${VRSN_FILE_SEMANTIC_VERSION_KEY} ${VRSN_TEST_FLAVOR_OPTIONS} --current-version 1.2.3 --try"
    runTest "${VRSN_FILE_TYPE}-numerical${VRSN_FLAVOR_SUFFIX}-custom-key-current-version-override-try"    "${VRSN_FIXTURE_DIR}/Sample.${VRSN_FILE_TYPE}" "--numeric" "--key ${VRSN_FILE_NUMERIC_KEY} ${VRSN_TEST_FLAVOR_OPTIONS} --current-version 1 --try"
}

function runTestsForFileType() {
    VRSN_FILE_TYPE="${1}"
    VRSN_FILE_SEMANTIC_VERSION_KEY="${2}"
    VRSN_FILE_NUMERIC_KEY="${3}"

    if [[ $VRSN_TRAVIS_BUILD -eq 1 ]]; then
        echo "travis_fold:start:${VRSN_FILE_TYPE}"
        echo "${VRSN_FILE_TYPE} tests:"
        echo
    fi

    runTestFlavor "" ""
    runTestFlavor "read" "--read"
    runTestFlavor "metadata" "--metadata some.meta-data.123"
    runTestFlavor "identifier" "--identifier some.prerelease-identifier.123"
    runTestFlavor "identifier-metadata" "--identifier some.prerelease-identifier.123 --metadata some.meta-data.123"

    if [[ $VRSN_TRAVIS_BUILD -eq 1 ]]; then
        echo "travis_fold:end:${VRSN_FILE_TYPE}"
    fi
}

function runOtherTest() {
	VRSN_ARGUMENTS="${1}"
	VRSN_COMMAND="vrsn ${VRSN_ARGUMENTS}"
	echo
}

runTestsForFileType "plist" "CFBundleShortVersionString" "CFBundleVersion"
runTestsForFileType "xcconfig" "CURRENT_PROJECT_VERSION" "DYLIB_CURRENT_VERSION"
runTestsForFileType "podspec" "version" "version"
runTestsForFileType "gemspec" "version" "version"

if [[ $VRSN_FAILED -eq 1 ]]; then
	exit 1
fi
