#!/bin/bash
#
# apt-get install ruby-dev g++
#
# Set ruby environment with, for example
#
# . ruby-debian-env
#

cd ~/opt/ruby/biogems.info

gem install bundler
bundle
