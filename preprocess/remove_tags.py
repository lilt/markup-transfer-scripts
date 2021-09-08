#!/usr/bin/env python3

import json
import argparse
from typing import List, NamedTuple

class Tag(NamedTuple):
    content: str
    opening_pos: int
    closing_pos: int

    def is_closing_tag(self) -> bool:
        return self.content.startswith("</")

    def is_self_closing_tag(self) -> bool:
        return self.content.endswith("/>")


class TagPair(NamedTuple):
    opening_tag: Tag
    closing_tag: Tag
    wrapped_text: str

def parse_args():
    parser = argparse.ArgumentParser("Parses json file and extract segment with tags.")
    parser.add_argument("input", help="Path to input file")
    parser.add_argument("output", help="Path to output file")
    return parser.parse_args()


def extract_tags(sentence: str) -> str:
    pos_stack: List[int] = []
    tag_stack: List[Tag] = []
    tag_pair_list: List[TagPair] = []

    plain_sentence: List[str] = []
    last_tag_end_pos = 0
    for i, c in enumerate(sentence):
        if c == '<':
            pos_stack.append(i)
            plain_sentence.append(sentence[last_tag_end_pos:i])
        elif c == '>':
            last_tag_end_pos = i + 1
            if len(pos_stack) == 1:
                opening_pos = pos_stack.pop()
                tag = Tag(sentence[opening_pos:i+1], opening_pos, i+1)

                if tag.is_closing_tag():
                    if len(tag_stack) == 0:
                        return []
                    opening_tag = tag_stack.pop()
                    text = sentence[opening_tag.closing_pos:tag.opening_pos]
                    tag_pair = TagPair(opening_tag, tag, text)
                    tag_pair_list.append(tag_pair)
                elif tag.is_self_closing_tag():
                    tag_pair_list.append(TagPair(tag, tag, ""))
                else:
                    tag_stack.append(tag)
            else:
                raise ValueError(f"Inconsistent usage of <> in prefix: {sentence[:i+1]}")
    plain_sentence.append(sentence[last_tag_end_pos:])

    if len(tag_stack) != 0:
        raise ValueError(f"Number of opening and closing tags don't match for {sentence=}")

    return "".join(plain_sentence)


if __name__ == '__main__':
    args = parse_args()
 
    with open(args.input, 'r') as fi, open(args.output, 'w') as fo:
        for line in fi:
            fo.write(extract_tags(line.strip()))
            fo.write('\n')

