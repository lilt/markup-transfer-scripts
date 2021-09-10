#!/bin/bash

set -ex

SCRIPT_DIR="${0%/*.sh}"
BASE_DIR="${SCRIPT_DIR}/.."
TEXT_DIR="${BASE_DIR}/text"
FASTALIGN_OUT="${SCRIPT_DIR}/fastalign"

for lang_pair in ende ; do  # enfi enfr enja ennl enru enzh; do
  mkdir -p ${FASTALIGN_OUT}/${lang_pair}

  paste ${TEXT_DIR}/${lang_pair}/${lang_pair:0:2}_train.removedtags.bpe ${TEXT_DIR}/${lang_pair}/${lang_pair:2}_train.removedtags.bpe | sed -E 's/\t/ ||| /g' > ${FASTALIGN_OUT}/${lang_pair}/train.txt
  paste ${TEXT_DIR}/${lang_pair}/${lang_pair:0:2}_dev.onlytags.removedtags.bpe ${TEXT_DIR}/${lang_pair}/${lang_pair:2}_dev.onlytags.removedtags.bpe | sed -E 's/\t/ ||| /g' > ${FASTALIGN_OUT}/${lang_pair}/dev.txt
  
  dev_lines=`wc -l < ${FASTALIGN_OUT}/${lang_pair}/dev.txt`

  cat ${FASTALIGN_OUT}/${lang_pair}/train.txt ${FASTALIGN_OUT}/${lang_pair}/dev.txt > ${FASTALIGN_OUT}/${lang_pair}/all.txt
  ${FASTALIGN_DIR}/build/fast_align -i ${FASTALIGN_OUT}/${lang_pair}/all.txt -p ${FASTALIGN_OUT}/${lang_pair}/fastalign.model -d -o -v > ${FASTALIGN_OUT}/${lang_pair}/all.talp 2> ${FASTALIGN_OUT}/${lang_pair}/fastalign.error
  tail -n $dev_lines ${FASTALIGN_OUT}/${lang_pair}/all.talp > ${FASTALIGN_OUT}/${lang_pair}/dev.talp
done

