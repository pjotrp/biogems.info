#! /bin/bash

if [ ! -e 'data/biogems.yaml' ]; then
  echo "Update biogems.yaml first!"
  exit 1
fi

./bin/fetch-repositories.rb data/biogems.yaml

