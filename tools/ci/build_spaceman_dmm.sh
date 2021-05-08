#!/bin/bash
set -euo pipefail

source dependencies.sh

mkdir -p "$HOME/SpacemanDMM"
cd $HOME/SpacemanDMM

if [ ! -d .git ]
then
	git init
	git remote add origin https://github.com/SpaceManiac/SpacemanDMM.git
fi

git fetch origin --depth=1 $SPACEMAN_DMM_COMMIT_HASH
git reset --hard FETCH_HEAD

#Builds dmdoc and dreamchecker at once, they'll use same github actions cache
cargo build --release --bin dreamchecker --bin dmdoc

chmod +x target/release/dreamchecker
cp target/release/dreamchecker .

chmod +x target/release/dmdoc
cp target/release/dmdoc .
