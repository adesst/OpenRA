#!/bin/bash

case "$1" in
	bleed)
		exit
		;;
	next | playtest-*)
		TAG=" (playtest)"
		;;
	master | release-*)
		TAG=""
		;;
	*)
		echo "Unknown branch: $1"
		exit
		;;
esac

echo "Updating wiki.openra.net"

SSH_KEY="$HOME"/.ssh/id_rsa

mkdir -p "$(dirname "$SSH_KEY")"
openssl aes-256-cbc -k "$KEY" -in ssh.enc -d -out "$SSH_KEY"
chmod 0600 "$SSH_KEY"

rm -rf "$HOME/openra-wiki"
git clone git@github.com:OpenRA/OpenRA.wiki.git "$HOME/openra-wiki"

mono --debug ../OpenRA.Utility.exe all --settings-docs "$1" > "${HOME}/openra-wiki/Settings${TAG}.md"

pushd "$HOME/openra-wiki" || exit 1
git config --local user.email "orabot@users.noreply.github.com"
git config --local user.name "orabot"
git add "Settings${TAG}.md"
git commit -m "Update user documentation for branch $1" &&
git push origin master
popd || exit

shred -u "$SSH_KEY"
