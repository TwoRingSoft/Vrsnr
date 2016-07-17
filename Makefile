CUSTOM_DERIVED_DATA_LOCATION?=Build
PREFIX?=/usr/local

all:	semver
	
semver:
	xcodebuild -project SemVer/SemVer.xcodeproj -scheme semver -configuration Release -derivedDataPath "$(CUSTOM_DERIVED_DATA_LOCATION)" clean build
