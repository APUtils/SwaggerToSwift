#!/bin/bash

base_dir=$(dirname "$0")
cd "$base_dir"

sh makeModels.sh -o Models -p "SwaggerToSwift" -u "Anton Plebanovich" -c "Anton Plebanovich"
