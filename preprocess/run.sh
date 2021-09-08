#!/bin/bash

set -e

export LC_ALL=en_US.UTF-8

BASE_DIR=${0%/preprocess/run.sh}
BPE_DIR=${BASE_DIR}/bpe
TEXT_DIR=${BASE_DIR}/text

mkdir -p $BPE_DIR $TEXT_DIR

# user-defined symbols to reflect tags in https://www.aclweb.org/anthology/attachments/W19-5212.Supplementary.pdf
TAGS="<ph>,</ph>,<xref>,</xref>,<uicontrol>,</uicontrol>,<b>,</b>,<codeph>,</codeph>,<parmname>,</parmname>,<i>,</i>,<title>,</title>,<menucascade>,</menucascade>,<varname>,</varname>,<userinput>,</userinput>,<filepath>,</filepath>,<term>,</term>,<systemoutput>,</systemoutput>,<cite>,</cite>,<li>,</li>,<ul>,</ul>,<p>,</p>,<note>,</note>,<indexterm>,</indexterm>,<u>,</u>,<fn>,</fn>"

if ! command -v spm_train; then
  echo "spm_train command not working. Please install sentencepiece."
  exit 1
fi

for lang_pair in ende  enfi enfr enja ennl enru enzh; do
  echo "Running for language pair ${lang_pair}"
  # Create text files
  mkdir -p ${TEXT_DIR}/${lang_pair}
  for lang in ${lang_pair:0:2} ${lang_pair:2}; do
    for dset in "dev" "train"; do
      ${BASE_DIR}/preprocess/json2text.py $LOCALIZATION_XML_DIR/data/${lang_pair}/${lang_pair}_${lang}_${dset}.json ${TEXT_DIR}/${lang_pair}/${lang}_${dset}.txt
      ${BASE_DIR}/preprocess/remove_tags.py ${TEXT_DIR}/${lang_pair}/${lang}_${dset}.txt ${TEXT_DIR}/${lang_pair}/${lang}_${dset}.removedtags.txt
      grep "<" ${TEXT_DIR}/${lang_pair}/${lang}_${dset}.txt > ${TEXT_DIR}/${lang_pair}/${lang}_${dset}.onlytags.txt
      ${BASE_DIR}/preprocess/remove_tags.py ${TEXT_DIR}/${lang_pair}/${lang}_${dset}.onlytags.txt ${TEXT_DIR}/${lang_pair}/${lang}_${dset}.onlytags.removedtags.txt
    done
  done


  # Create bpe files
  cat ${TEXT_DIR}/${lang_pair}/${lang_pair:0:2}_${dset}.txt ${TEXT_DIR}/${lang_pair}/${lang_pair:2}_train.txt > ${BPE_DIR}/${lang_pair}.tmp
  spm_train \
    --input_sentence_size      100000000 \
    --model_type               bpe \
    --num_threads              4 \
    --split_by_unicode_script  1 \
    --split_by_whitespace      1 \
    --remove_extra_whitespaces 0 \
    --normalization_rule_name  identity \
    --character_coverage       1.0 \
    --add_dummy_prefix         1 \
    --add_numbers              1 \
    --add_punctuation          1 \
    --vocab_size               10000 \
    --input                    ${BPE_DIR}/${lang_pair}.tmp \
    --model_prefix             ${BPE_DIR}/${lang_pair} \
    --user_defined_symbols "&amp;,&lt;,&gt;,|||,$TAGS"

  for file_path in ${BASE_DIR}/text/${lang_pair}/*.txt; do
    spm_encode --model ${BASE_DIR}/bpe/${lang_pair}.model < ${file_path} > ${file_path%.txt}.bpe
  done

done

