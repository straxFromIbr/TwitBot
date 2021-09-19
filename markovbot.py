import re
import sys

import markovify
import MeCab
import neologdn

parser = MeCab.Tagger("-d /usr/lib/x86_64-linux-gnu/mecab/dic/mecab-ipadic-neologd")


def gettext():
    textlist = list(sys.stdin.read())
    return split_input_text("".join(textlist))


def split_input_text(text):

    splitted_text = ""
    words = [
        morph.split("\t")[0]
        for morph in parser.parse(neologdn.normalize(text)).split("\n")
        if len(morph) != 0 and morph != "EOS"
    ]

    for word in words:
        word = re.sub(r"[（）「」『』｛｝【】＠”’｜・]", "", word)
        word = re.sub(r"[()\[\]{}@\'\"|~-]", "", word)
        word = re.sub(r"\s", "", word)
        word = re.sub(r"。", "。\n", word)
        word += " "
        splitted_text += word

    return splitted_text


if __name__ == "__main__":
    text_model = markovify.NewlineText(gettext(), state_size=3)
    sys.stdout.write(
        text_model.make_short_sentence(
            140,
            tries=100,
        ).replace(" ", ""),
    )
