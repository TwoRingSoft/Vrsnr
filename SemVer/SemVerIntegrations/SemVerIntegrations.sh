#!/bin/sh

#  SemVerIntegrations.sh
#  semver
#
#  Created by Andrew McKnight on 6/29/16.
#  Copyright © 2016 Two Ring Software. All rights reserved.

#  Note: written to be run from the root directory in the repo

SMVR_LOCATION="${1}" # path to the 'semver' executable to use

function startTestCaseOutput() {
    echo "|---------------------------------------------------------"
    echo "|"
}

function endTestCaseOutput() {
    echo "|"
    echo "|---------------------------------------------------------"
    echo
    echo
    echo
}

function runTest() {
    SMVR_TEST_NAME="${1}"
    SMVR_TEST_FILE="${2}"
    SMVR_TEST_SEMVER_COMPONENT="${3}"
    SMVR_TEST_OPTIONS="${4}"

    SMVR_BACKUP_TEST_FILE="${SMVR_TEST_FILE}.orig"

    SMVR_TEST_RESULTS_DIR="SemVerIntegrations/results"
    mkdir -p "${SMVR_TEST_RESULTS_DIR}"

    SMVR_TEST_RESULTS_FILE="${SMVR_TEST_RESULTS_DIR}/${SMVR_TEST_NAME}.results"
    SMVR_TEST_BASELINE_RESULTS_FILE="SemVerIntegrations/baseLines/${SMVR_TEST_NAME}.results"

    startTestCaseOutput

    # make copy of original file
    cp "${SMVR_TEST_FILE}" "${SMVR_BACKUP_TEST_FILE}"

    # perform the command
    SMVR_CMD="semver ${SMVR_TEST_SEMVER_COMPONENT} --file ${SMVR_TEST_FILE} ${SMVR_TEST_OPTIONS}"

    echo "| ${SMVR_TEST_NAME}"
    echo "|"
    echo "| ${SMVR_CMD}"
    echo "|"
    echo $SMVR_CMD > "${SMVR_TEST_RESULTS_FILE}"
    eval "${SMVR_LOCATION}/${SMVR_CMD}" | tee -a "${SMVR_TEST_RESULTS_FILE}" | awk '{print "| " $0}'

    echo >> "${SMVR_TEST_RESULTS_FILE}"
    echo "Before:" >> "${SMVR_TEST_RESULTS_FILE}"
    echo >> "${SMVR_TEST_RESULTS_FILE}"
    cat "${SMVR_BACKUP_TEST_FILE}" >> "${SMVR_TEST_RESULTS_FILE}"

    echo >> "${SMVR_TEST_RESULTS_FILE}"
    echo "After:" >> "${SMVR_TEST_RESULTS_FILE}"
    echo >> "${SMVR_TEST_RESULTS_FILE}"
    cat "${SMVR_TEST_FILE}" >> "${SMVR_TEST_RESULTS_FILE}"

    # compare the modified file to copy of original
    echo >> "${SMVR_TEST_RESULTS_FILE}"
    echo "Difference:" >> "${SMVR_TEST_RESULTS_FILE}"
    echo >> "${SMVR_TEST_RESULTS_FILE}"
    diff "${SMVR_TEST_FILE}" "${SMVR_BACKUP_TEST_FILE}" >> "${SMVR_TEST_RESULTS_FILE}"

    # compare new results to baseline results; they should be identical unless intentionally changing something
    diff "${SMVR_TEST_BASELINE_RESULTS_FILE}" "${SMVR_TEST_RESULTS_FILE}" > /dev/null
    if [[ $? == 0 ]]; then
	    echo "|"
        echo "| Passed :D"
        rm "${SMVR_TEST_RESULTS_FILE}" # don't save results output for cases that pass
    else
        diff "${SMVR_TEST_BASELINE_RESULTS_FILE}" "${SMVR_TEST_RESULTS_FILE}" | awk '{print "| " $0}'
		SMVR_FAILED=1
	    echo "|"
        echo "| Failed D:"
    fi

    endTestCaseOutput

    # reset the file back to its original state
    rm "${SMVR_TEST_FILE}"
    mv "${SMVR_BACKUP_TEST_FILE}" "${SMVR_TEST_FILE}"
}

function runTestFlavor() {
    SMVR_TEST_FLAVOR="${1}"
    SMVR_TEST_FLAVOR_OPTIONS="${2}"

    if [[ -z "${SMVR_TEST_FLAVOR}" ]]; then
        SMVR_FLAVOR_SUFFIX=""
    else
        SMVR_FLAVOR_SUFFIX="-${SMVR_TEST_FLAVOR}"
    fi

    SMVR_FIXTURE_DIR="SemVerIntegrations/Fixtures"

    runTest "${SMVR_FILE_TYPE}-semver-major${SMVR_FLAVOR_SUFFIX}" "${SMVR_FIXTURE_DIR}/Sample.${SMVR_FILE_TYPE}" "major"     "${SMVR_TEST_FLAVOR_OPTIONS}"
    runTest "${SMVR_FILE_TYPE}-semver-minor${SMVR_FLAVOR_SUFFIX}" "${SMVR_FIXTURE_DIR}/Sample.${SMVR_FILE_TYPE}" "minor"     "${SMVR_TEST_FLAVOR_OPTIONS}"
    runTest "${SMVR_FILE_TYPE}-semver-patch${SMVR_FLAVOR_SUFFIX}" "${SMVR_FIXTURE_DIR}/Sample.${SMVR_FILE_TYPE}" "patch"     "${SMVR_TEST_FLAVOR_OPTIONS}"
    runTest "${SMVR_FILE_TYPE}-numerical${SMVR_FLAVOR_SUFFIX}"    "${SMVR_FIXTURE_DIR}/Sample.${SMVR_FILE_TYPE}" "--numeric" "${SMVR_TEST_FLAVOR_OPTIONS}"

    runTest "${SMVR_FILE_TYPE}-semver-major${SMVR_FLAVOR_SUFFIX}-custom-key" "${SMVR_FIXTURE_DIR}/Sample.${SMVR_FILE_TYPE}" "major"     "--key ${SMVR_FILE_SEMVER_KEY} ${SMVR_TEST_FLAVOR_OPTIONS}"
    runTest "${SMVR_FILE_TYPE}-semver-minor${SMVR_FLAVOR_SUFFIX}-custom-key" "${SMVR_FIXTURE_DIR}/Sample.${SMVR_FILE_TYPE}" "minor"     "--key ${SMVR_FILE_SEMVER_KEY} ${SMVR_TEST_FLAVOR_OPTIONS}"
    runTest "${SMVR_FILE_TYPE}-semver-patch${SMVR_FLAVOR_SUFFIX}-custom-key" "${SMVR_FIXTURE_DIR}/Sample.${SMVR_FILE_TYPE}" "patch"     "--key ${SMVR_FILE_SEMVER_KEY} ${SMVR_TEST_FLAVOR_OPTIONS}"
    runTest "${SMVR_FILE_TYPE}-numerical${SMVR_FLAVOR_SUFFIX}-custom-key"    "${SMVR_FIXTURE_DIR}/Sample.${SMVR_FILE_TYPE}" "--numeric" "--key ${SMVR_FILE_NUMERIC_KEY} ${SMVR_TEST_FLAVOR_OPTIONS}"

    runTest "${SMVR_FILE_TYPE}-semver-major${SMVR_FLAVOR_SUFFIX}-try" "${SMVR_FIXTURE_DIR}/Sample.${SMVR_FILE_TYPE}" "major"     "${SMVR_TEST_FLAVOR_OPTIONS} --try"
    runTest "${SMVR_FILE_TYPE}-semver-minor${SMVR_FLAVOR_SUFFIX}-try" "${SMVR_FIXTURE_DIR}/Sample.${SMVR_FILE_TYPE}" "minor"     "${SMVR_TEST_FLAVOR_OPTIONS} --try"
    runTest "${SMVR_FILE_TYPE}-semver-patch${SMVR_FLAVOR_SUFFIX}-try" "${SMVR_FIXTURE_DIR}/Sample.${SMVR_FILE_TYPE}" "patch"     "${SMVR_TEST_FLAVOR_OPTIONS} --try"
    runTest "${SMVR_FILE_TYPE}-numerical${SMVR_FLAVOR_SUFFIX}-try"    "${SMVR_FIXTURE_DIR}/Sample.${SMVR_FILE_TYPE}" "--numeric" "${SMVR_TEST_FLAVOR_OPTIONS} --try"

    runTest "${SMVR_FILE_TYPE}-semver-major${SMVR_FLAVOR_SUFFIX}-custom-key-try" "${SMVR_FIXTURE_DIR}/Sample.${SMVR_FILE_TYPE}" "major"     "--key ${SMVR_FILE_SEMVER_KEY} ${SMVR_TEST_FLAVOR_OPTIONS} --try"
    runTest "${SMVR_FILE_TYPE}-semver-minor${SMVR_FLAVOR_SUFFIX}-custom-key-try" "${SMVR_FIXTURE_DIR}/Sample.${SMVR_FILE_TYPE}" "minor"     "--key ${SMVR_FILE_SEMVER_KEY} ${SMVR_TEST_FLAVOR_OPTIONS} --try"
    runTest "${SMVR_FILE_TYPE}-semver-patch${SMVR_FLAVOR_SUFFIX}-custom-key-try" "${SMVR_FIXTURE_DIR}/Sample.${SMVR_FILE_TYPE}" "patch"     "--key ${SMVR_FILE_SEMVER_KEY} ${SMVR_TEST_FLAVOR_OPTIONS} --try"
    runTest "${SMVR_FILE_TYPE}-numerical${SMVR_FLAVOR_SUFFIX}-custom-key-try"    "${SMVR_FIXTURE_DIR}/Sample.${SMVR_FILE_TYPE}" "--numeric" "--key ${SMVR_FILE_NUMERIC_KEY} ${SMVR_TEST_FLAVOR_OPTIONS} --try"

    runTest "${SMVR_FILE_TYPE}-semver-major${SMVR_FLAVOR_SUFFIX}-current-version-override" "${SMVR_FIXTURE_DIR}/Sample.${SMVR_FILE_TYPE}" "major"     "${SMVR_TEST_FLAVOR_OPTIONS} --current-version 1.2.3"
    runTest "${SMVR_FILE_TYPE}-semver-minor${SMVR_FLAVOR_SUFFIX}-current-version-override" "${SMVR_FIXTURE_DIR}/Sample.${SMVR_FILE_TYPE}" "minor"     "${SMVR_TEST_FLAVOR_OPTIONS} --current-version 1.2.3"
    runTest "${SMVR_FILE_TYPE}-semver-patch${SMVR_FLAVOR_SUFFIX}-current-version-override" "${SMVR_FIXTURE_DIR}/Sample.${SMVR_FILE_TYPE}" "patch"     "${SMVR_TEST_FLAVOR_OPTIONS} --current-version 1.2.3"
    runTest "${SMVR_FILE_TYPE}-numerical${SMVR_FLAVOR_SUFFIX}-current-version-override"    "${SMVR_FIXTURE_DIR}/Sample.${SMVR_FILE_TYPE}" "--numeric" "${SMVR_TEST_FLAVOR_OPTIONS} --current-version 1"

    runTest "${SMVR_FILE_TYPE}-semver-major${SMVR_FLAVOR_SUFFIX}-custom-key-current-version-override" "${SMVR_FIXTURE_DIR}/Sample.${SMVR_FILE_TYPE}" "major"     "--key ${SMVR_FILE_SEMVER_KEY} ${SMVR_TEST_FLAVOR_OPTIONS} --current-version 1.2.3"
    runTest "${SMVR_FILE_TYPE}-semver-minor${SMVR_FLAVOR_SUFFIX}-custom-key-current-version-override" "${SMVR_FIXTURE_DIR}/Sample.${SMVR_FILE_TYPE}" "minor"     "--key ${SMVR_FILE_SEMVER_KEY} ${SMVR_TEST_FLAVOR_OPTIONS} --current-version 1.2.3"
    runTest "${SMVR_FILE_TYPE}-semver-patch${SMVR_FLAVOR_SUFFIX}-custom-key-current-version-override" "${SMVR_FIXTURE_DIR}/Sample.${SMVR_FILE_TYPE}" "patch"     "--key ${SMVR_FILE_SEMVER_KEY} ${SMVR_TEST_FLAVOR_OPTIONS} --current-version 1.2.3"
    runTest "${SMVR_FILE_TYPE}-numerical${SMVR_FLAVOR_SUFFIX}-custom-key-current-version-override"    "${SMVR_FIXTURE_DIR}/Sample.${SMVR_FILE_TYPE}" "--numeric" "--key ${SMVR_FILE_NUMERIC_KEY} ${SMVR_TEST_FLAVOR_OPTIONS} --current-version 1"

    runTest "${SMVR_FILE_TYPE}-semver-major${SMVR_FLAVOR_SUFFIX}-current-version-override-try" "${SMVR_FIXTURE_DIR}/Sample.${SMVR_FILE_TYPE}" "major"     "${SMVR_TEST_FLAVOR_OPTIONS} --current-version 1.2.3 --try"
    runTest "${SMVR_FILE_TYPE}-semver-minor${SMVR_FLAVOR_SUFFIX}-current-version-override-try" "${SMVR_FIXTURE_DIR}/Sample.${SMVR_FILE_TYPE}" "minor"     "${SMVR_TEST_FLAVOR_OPTIONS} --current-version 1.2.3 --try"
    runTest "${SMVR_FILE_TYPE}-semver-patch${SMVR_FLAVOR_SUFFIX}-current-version-override-try" "${SMVR_FIXTURE_DIR}/Sample.${SMVR_FILE_TYPE}" "patch"     "${SMVR_TEST_FLAVOR_OPTIONS} --current-version 1.2.3 --try"
    runTest "${SMVR_FILE_TYPE}-numerical${SMVR_FLAVOR_SUFFIX}-current-version-override-try"    "${SMVR_FIXTURE_DIR}/Sample.${SMVR_FILE_TYPE}" "--numeric" "${SMVR_TEST_FLAVOR_OPTIONS} --current-version 1 --try"

    runTest "${SMVR_FILE_TYPE}-semver-major${SMVR_FLAVOR_SUFFIX}-custom-key-current-version-override-try" "${SMVR_FIXTURE_DIR}/Sample.${SMVR_FILE_TYPE}" "major"     "--key ${SMVR_FILE_SEMVER_KEY} ${SMVR_TEST_FLAVOR_OPTIONS} --current-version 1.2.3 --try"
    runTest "${SMVR_FILE_TYPE}-semver-minor${SMVR_FLAVOR_SUFFIX}-custom-key-current-version-override-try" "${SMVR_FIXTURE_DIR}/Sample.${SMVR_FILE_TYPE}" "minor"     "--key ${SMVR_FILE_SEMVER_KEY} ${SMVR_TEST_FLAVOR_OPTIONS} --current-version 1.2.3 --try"
    runTest "${SMVR_FILE_TYPE}-semver-patch${SMVR_FLAVOR_SUFFIX}-custom-key-current-version-override-try" "${SMVR_FIXTURE_DIR}/Sample.${SMVR_FILE_TYPE}" "patch"     "--key ${SMVR_FILE_SEMVER_KEY} ${SMVR_TEST_FLAVOR_OPTIONS} --current-version 1.2.3 --try"
    runTest "${SMVR_FILE_TYPE}-numerical${SMVR_FLAVOR_SUFFIX}-custom-key-current-version-override-try"    "${SMVR_FIXTURE_DIR}/Sample.${SMVR_FILE_TYPE}" "--numeric" "--key ${SMVR_FILE_NUMERIC_KEY} ${SMVR_TEST_FLAVOR_OPTIONS} --current-version 1 --try"
}

function runTestsForFileType() {
    SMVR_FILE_TYPE="${1}"
    SMVR_FILE_SEMVER_KEY="${2}"
    SMVR_FILE_NUMERIC_KEY="${3}"

    if [[ $SMVR_TRAVIS_BUILD -eq 1 ]]; then
        echo "travis_fold:start:${SMVR_FILE_TYPE}"
        echo "${SMVR_FILE_TYPE} tests:"
        echo
    fi

    runTestFlavor "" ""
    runTestFlavor "read" "--read"
    runTestFlavor "metadata" "--metadata some.meta-data.123"
    runTestFlavor "identifier" "--identifier some.prerelease-identifier.123"
    runTestFlavor "identifier-metadata" "--identifier some.prerelease-identifier.123 --metadata some.meta-data.123"

    if [[ $SMVR_TRAVIS_BUILD -eq 1 ]]; then
        echo "travis_fold:end:${SMVR_FILE_TYPE}"
    fi
}

function runOtherTest() {
	SMVR_ARGUMENTS="${1}"
	SMVR_COMMAND="semver ${SMVR_ARGUMENTS}"
	echo
}

runTestsForFileType "plist" "CFBundleShortVersionString" "CFBundleVersion"
runTestsForFileType "xcconfig" "CURRENT_PROJECT_VERSION" "DYLIB_CURRENT_VERSION"
runTestsForFileType "podspec" "version" "version"

if [[ SMVR_FAILED -eq 1 ]]; then
	exit 1
fi
