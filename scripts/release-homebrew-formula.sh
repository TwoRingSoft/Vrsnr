#!/bin/bash

pushd submodules/tworingsoft/homebrew-formulae
git fetch
git reset --hard origin/master

# the brew fetch command gets the SHA256 digest of origin/master/HEAD, to insert into the homebrew spec's sha256 field
vrsn --key sha256 --file Formula/vrsn.rb --custom $(brew fetch tworingsoft/homebrew-formulae/vrsn --HEAD --build-from-source | grep SHA256 | awk '{print $2};')

make release SPEC=vrsn VERSION=$(vrsn --read --file ../../../Vrsnr/Config/Project.xcconfig)
popd
