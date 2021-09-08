#!/usr/bin/env python3

import json
import argparse
from typing import List, NamedTuple


def parse_args():
    parser = argparse.ArgumentParser("Convert json file from https://github.com/salesforce/localization-xml-mt/ to text file.")
    parser.add_argument("json", help="Path to json file")
    parser.add_argument("output", help="Path to output file")
    return parser.parse_args()


if __name__ == '__main__':
    args = parse_args()
 
    with open(args.json, 'r') as f:
        lines = json.load(f)['text'].values()

    with open(args.output, 'w') as f:
        f.write('\n'.join(lines))
        f.write('\n')

