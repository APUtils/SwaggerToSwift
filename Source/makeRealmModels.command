#!/bin/bash

base_dir=$(dirname "$0")
cd "$base_dir"

sh makeRealmModels.sh -o RealmModels -p "SwaggerToSwift" -u "Anton Plebanovich" -c "Anton Plebanovich"
