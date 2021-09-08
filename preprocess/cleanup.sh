#!/bin/bash

set -e

BASE_DIR="${0%/cleanup.sh}/.."

echo rm -r ${BASE_DIR}/bpe
echo rm -r ${BASE_DIR}/text

