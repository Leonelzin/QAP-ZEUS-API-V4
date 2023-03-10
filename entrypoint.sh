#!/usr/bin/env bash
export EXISTING_VARS=$(printenv | awk -F= '{print $1}' | sed 's/^/\$/g' | paste -sd,);
echo "Running tests for following parameters: ${TOKEN}  ${URL_RESPONSE}"

python3 ./Scripts/test_runner.py  ${TOKEN}  ${URL_RESPONSE}
