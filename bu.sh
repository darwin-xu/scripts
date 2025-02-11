#!/bin/zsh

export PATH=/opt/homebrew/bin:/opt/homebrew/sbin:$PATH
./try brew update && ./try brew upgrade && ./try brew cleanup
