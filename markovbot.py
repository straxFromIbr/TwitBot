#!/home/hagayuya/.venvs/general_venv/bin/python3
import sys
import re


import MeCab
import markovify

parser = MeCab.Tagger('-d /usr/lib/x86_64-linux-gnu/mecab/dic/mecab-ipadic-neologd')

def gettext():
    textlist = list(sys.stdin.read())
    return split_input_text("".join(textlist * 10))


def split_input_text(text):

    splitted_text = ""
    words = [
        morph.split("\t")[0]
        for morph in parser.parse(text).split("\n")
        if len(morph) != 0 and morph != "EOS"
    ]

    for word in words:
        word = re.sub(r"[（）「」『』｛｝【】＠”’｜・]", "", word)  # 全角のカッコ、各種記号は削除
        word = re.sub(r"[()\[\]{}@\'\"|~-]", "", word)  # 半角のカッコ、各種記号は削除
        word = re.sub(r"\s", "", word)

        word = re.sub(r"。", "。\n", word)  # 句点は改行コードを追加
        word += " "
        splitted_text += word

    return splitted_text


if __name__ == "__main__":
    splitted_text = gettext()
    text_model = markovify.NewlineText(splitted_text, state_size=3)
    sys.stdout.write(
        text_model.make_short_sentence(
            130,
            tries=100,
        ).replace(" ", ""),
    )
