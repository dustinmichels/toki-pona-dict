import csv
import json

words: dict = {}
fp = "assets/data/words.json"

with open("toki_pona_dict.csv", newline="") as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        word = row["word"]
        definition = {"pos": row["pos"], "def": row["definition"], "eg": row["example"]}
        if words.get(word):
            words[word]["definitions"].append(definition)
        else:
            words[word] = {"word": word, "definitions": [definition]}


wordsList = list(words.values())
with open(fp, "w") as f:
    json.dump(wordsList, f, indent=2)
