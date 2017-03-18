CUSTOM_DERIVED_DATA_LOCATION?=Build
PREFIX?=/usr/local

all:	vrsn
	
semver:
	xcodebuild -project Vrsnr/Vrsnr.xcodeproj -scheme vrsn -configuration Release -derivedDataPath "$(CUSTOM_DERIVED_DATA_LOCATION)" clean build
