import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

Future<List<DictWord>> loadDict() async {
  var response = await rootBundle.loadString('assets/data/words.json');
  List wordList = json.decode(response);
  var wordObjList = wordList
      .map((w) => DictWord.make(word: w['word'], definitions: w['definitions']))
      .toList();
  return wordObjList;
}

class Definition {
  final String pos; // part of speach
  final String def; // definition
  final String eg; // exmaple
  Definition(this.pos, this.def, this.eg);
}

class DictWord {
  String word;
  List<Definition> definitions;

  DictWord({this.word, this.definitions});

  DictWord.make({String word, List definitions}) {
    this.word = word;
    this.definitions = definitions.map((d) {
      return Definition(d['pos'], d['def'], d['eg']);
    }).toList();
  }

  factory DictWord.fromJson(Map<String, dynamic> json) {
    return DictWord.make(word: json['word'], definitions: json['definitions']);
  }

  @override
  String toString() {
    return "DictWord[$word]";
  }

  String getRootWord() => word.split(' (')[0];
}
