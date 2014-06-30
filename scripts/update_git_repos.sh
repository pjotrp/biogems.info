#! /bin/bash

yaml=$1

if [ ! -e $yaml ]; then
  echo "Update biogems.yaml ($yaml) first!"
  exit 1
fi

mkdir -p data/repositories

./bin/fetch-repositories.rb data/biogems.yaml

