#!/bin/sh
set -e

# Script to grab binaries that are going to be bundled with windows installer.
# Note to maintainers: Update versions used below with newer releases

boot2dockerIso=1.8.0-rc2
docker=1.8.0-rc2
dockerMachine=0.4.0-rc2
kitematic=0.8.0-rc4
vbox=5.0.0
vboxRev=101573
msysGit=1.9.5-preview20150319
installer=1.8.0-rc5
mixpanel=c306ae65c33d7d09fe3e546f36493a6e

boot2dockerIsoSrc=tianon
dockerBucket=test.docker.com

set -x
rm -rf bundle
mkdir bundle
cd bundle

echo "{\"event\":\"Installer Started\",\"properties\":{\"token\":\"$mixpanel\",\"version\":\"$installer\",\"os\":\"win32\"}}" > out.txt
certutil -encode out.txt started-cert.txt
cat started-cert.txt | sed '/^-----/ d' | tr -d '\n' > started.txt
rm started-cert.txt

echo "{\"event\":\"Installer Finished\",\"properties\":{\"token\":\"$mixpanel\",\"version\":\"$installer\",\"os\":\"win32\"}}" > out.txt
certutil -encode out.txt finished-cert.txt
cat finished-cert.txt | sed '/^-----/ d' | tr -d '\n' > finished.txt
rm finished-cert.txt

(
	mkdir -p docker
	cd docker

	curl -fsSL -o docker.exe "https://${dockerBucket}/builds/Windows/x86_64/docker-${docker}.exe"
	curl -fsSL -o docker-machine.exe "https://github.com/docker/machine/releases/download/v${dockerMachine}/docker-machine_windows-amd64.exe"
)

(
	mkdir -p kitematic
	cd kitematic

	curl -fsSL -o kitematic-setup.exe "https://github.com/kitematic/kitematic/releases/download/v${kitematic}/KitematicSetup-${kitematic}-Windows-Alpha.exe"
)

(
	mkdir -p Boot2Docker
	cd Boot2Docker

	curl -fsSL -o boot2docker.iso "https://github.com/${boot2dockerIsoSrc}/boot2docker/releases/download/v${boot2dockerIso}/boot2docker.iso"
)

(
	mkdir -p msysGit
	cd msysGit

	curl -fsSL -o Git.exe "https://github.com/msysgit/msysgit/releases/download/Git-${msysGit}/Git-${msysGit}.exe"
)

(
	mkdir -p VirtualBox
	cd VirtualBox

	# http://www.virtualbox.org/manual/ch02.html
	curl -fsSL -o virtualbox.exe "http://download.virtualbox.org/virtualbox/${vbox}/VirtualBox-${vbox}-${vboxRev}-Win.exe"

	virtualbox.exe -extract -silent -path .
	rm virtualbox.exe # not neeeded after extraction

	rm *x86.msi # not needed as we only install 64-bit
	mv *_amd64.msi VirtualBox_amd64.msi # remove version number
)
