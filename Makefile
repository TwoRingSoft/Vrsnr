CUSTOM_DERIVED_DATA_LOCATION?=Build
PREFIX?=/usr/local

all:	vrsn
	
vrsn:
	xcodebuild -project Vrsnr/Vrsnr.xcodeproj -scheme vrsn -configuration Release -derivedDataPath "$(CUSTOM_DERIVED_DATA_LOCATION)" clean build

test:
	xcodebuild -project Vrsnr/Vrsnr.xcodeproj -scheme vrsnTests -configuration Release build

update_baselines:
	find Vrsnr/vrsnTests/results/ -name "*.results" | xargs -I @ mv @ Vrsnr/vrsnTests/baseLines/
