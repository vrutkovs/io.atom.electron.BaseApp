all: prepare-repo install-deps build update-repo
travis: prepare-repo travis-keep-remotes install-deps travis-restore-cache build travis-save-cache update-repo travis-write-no-gpg

prepare-repo:
	[[ -d repo ]] || ostree init --mode=archive-z2 --repo=repo

travis-keep-remotes:
	[[ -d repo/refs/remotes ]] || mkdir -p repo/refs/remotes && touch repo/refs/remotes/.gitkeep

install-deps:
	flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	flatpak --user install flathub org.freedesktop.Platform/x86_64/1.6 org.freedesktop.Sdk/x86_64/1.6 || true

travis-restore-cache:
	mkdir /build
	cp * -rf /build
	[[ -f .travis-cache/cache.tar ]] && cd /build && tar -xf /source/.travis-cache/cache.tar || true
	ls -la /build

build:
	cd /build && flatpak-builder --verbose --force-clean --ccache --require-changes \
		--delete-build-dirs --disable-rofiles-fuse \
		--subject="Nightly build of Electron Base App, `date`" \
		--repo=/source/repo app io.atom.electron.BaseApp.json

travis-save-cache:
	[[ -d .travis-cache ]] || mkdir .travis-cache
	rm -rf /build/.flatpak-build/build
	cd /build && tar --acls --xattrs -cf /source/.travis-cache/cache.tar .flatpak-builder

update-repo:
	flatpak build-update-repo --prune --prune-depth=20 --generate-static-deltas repo

travis-write-no-gpg:
	echo 'gpg-verify-summary=false' >> repo/config
