Scripts for preprocessing and experiments for the paper Automatic Bilingual Markup Transfer.

# Dependencies
- Python3
- [localization-xml-mt dataset](https://github.com/salesforce/localization-xml-mt)
- [SentencePiece](https://github.com/google/sentencepiece)
- [FastAlign](https://github.com/clab/fast_align) to generate alignments

# Usage
```bash
# Run preprocessing, outputs written to ./bpe and ./text
export LOCALIZATION_XML_DIR="/your/path/localization-xml-mt"
./preprocess/run.sh

# Run FastAlign, outputs written to ./align/fastalign
export FASTALIGN_DIR="/your/path/fast_align"
./align/run_fastalign.sh
```
