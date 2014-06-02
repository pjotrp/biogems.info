#! /bin/bash

if [ ! -e 'data/biogems.yaml' ]; then
  echo "Update biogems.yaml first!"
  exit 1
fi

mkdir -p data/repositories

./bin/fetch-repositories.rb data/biogems.yaml

