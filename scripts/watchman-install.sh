#!/bin/bash
sudo apt install libcrypto++-dev libssl-dev
git clone https://github.com/facebook/watchman.git -b v4.9.0 --depth 1 ~/.builds/
cd ~/.builds/watchman || exit
./autogen.sh
./configure
make
sudo make install

