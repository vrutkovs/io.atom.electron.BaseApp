all: prepare-repo install-deps build update-repo

prepare-repo:
	[[ -d repo ]] || ostree init --mode=archive-z2 --repo=repo
	[[ -d repo/refs/remotes ]] || mkdir -p repo/refs/remotes && touch repo/refs/remotes/.gitkeep

install-deps:
	flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	flatpak --user install flathub org.freedesktop.Platform/x86_64/1.6 org.freedesktop.Sdk/x86_64/1.6 || true

build:
	flatpak-builder --verbose --force-clean --ccache --require-changes \
		--delete-build-dirs --disable-rofiles-fuse \
		--subject="Nightly build of Electron Base App, `date`" \
		--repo=repo app io.atom.electron.BaseApp.json

update-repo:
	flatpak build-update-repo --prune --prune-depth=20 --generate-static-deltas repo

travis-write-no-gpg:
	echo 'gpg-verify-summary=false' >> repo/config
