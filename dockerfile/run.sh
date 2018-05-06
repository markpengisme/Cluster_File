#!/bin/bash
set -eu -o pipefail
## init
apt-get update
apt-get upgrade -y
apt-get install vim git software-properties-common wget -y

# install build deps
add-apt-repository ppa:ethereum/ethereum -y
apt-get update -y
apt-get install -y build-essential unzip libdb-dev libleveldb-dev libsodium-dev zlib1g-dev libtinfo-dev solc sysvbanner wrk psmisc

# install constellation
CVER="0.3.2"
CREL="constellation-$CVER-ubuntu1604"
wget -q https://github.com/jpmorganchase/constellation/releases/download/v$CVER/$CREL.tar.xz
tar xfJ $CREL.tar.xz
cp $CREL/constellation-node /usr/local/bin && chmod 0755 /usr/local/bin/constellation-node
rm -rf $CREL $CREL.*

# install golang
GOREL="go1.9.3.linux-amd64.tar.gz"
wget -q https://dl.google.com/go/$GOREL
tar xfz $GOREL
mv go /usr/local/go
rm -f $GOREL
PATH=$PATH:/usr/local/go/bin
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc

# make/install quorum
git clone https://github.com/jpmorganchase/quorum.git
pushd quorum >/dev/null
git checkout tags/v2.0.1
make all
cp build/bin/geth /usr/local/bin
cp build/bin/bootnode /usr/local/bin
popd >/dev/null
mv quorum /home/quorum

# install Porosity
wget -q https://github.com/jpmorganchase/quorum/releases/download/v1.2.0/porosity
mv porosity /usr/local/bin && chmod 0755 /usr/local/bin/porosity
