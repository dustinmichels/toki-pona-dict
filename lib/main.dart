import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'words.dart';

void main() async {
  var dictWords = await loadDict();
  runApp(MyApp(dictWords: dictWords));
}

class MyApp extends StatelessWidget {
  final List<DictWord> dictWords;
  MyApp({Key key, @required this.dictWords}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Toki Pona Dictionary',
        theme: ThemeData(
          primaryColor: Colors.amber[200],
        ),
        home: HomePage(
          dictWords: dictWords,
        ),
        routes: <String, WidgetBuilder>{
          SettingsPage.routeName: (context) => SettingsPage(),
        });
  }
}

// -------------------------
// HOME PAGE
// -------------------------

class HomePage extends StatelessWidget {
  final List<DictWord> dictWords;
  final _biggerFont = const TextStyle(fontSize: 18.0);

  HomePage({Key key, @required this.dictWords}) : super(key: key);

  Widget _buildWordList() {
    return ListView.builder(
      itemCount: dictWords.length,
      itemBuilder: (context, index) {
        return _buildRow(dictWords[index], context, index);
      },
    );
  }

  Widget _buildRow(DictWord word, context, index) {
    return Card(
        child: ListTile(
      title: Text(
        word.word,
        style: _biggerFont,
      ),
      subtitle: Text.rich(
        TextSpan(
            children: word.definitions
                .map((d) => [
                      TextSpan(
                          text: "\n${d.pos}. ",
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.blueGrey.withOpacity(0.9))),
                      TextSpan(text: "${d.def}\n")
                    ])
                .expand((i) => i)
                .toList()),
      ),
      trailing: Text(word.getRootWord(),
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'LinjaPona', fontSize: 18.0)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WordDetailScreen(dictWord: word),
          ),
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Toki Pona Dictionary'),
          actions: <Widget>[
            new IconButton(icon: const Icon(Icons.search), onPressed: null),
            new IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () =>
                    Navigator.of(context).pushNamed(SettingsPage.routeName)),
          ],
        ),
        body: _buildWordList());
  }
}

// -------------------------
// WORD DETAIL PAGE
// -------------------------

class WordDetailScreen extends StatelessWidget {
  // Declare a field that holds the word
  final DictWord dictWord;

  // In the constructor, require a word
  WordDetailScreen({Key key, @required this.dictWord}) : super(key: key);

  Widget _buildDefinitionsList() {
    return ListView.separated(
      itemCount: dictWord.definitions.length,
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, index) {
        final Definition definition = dictWord.definitions[index];
        return ListTile(
            title: Text(
              "${index + 1}. ${definition.pos}",
            ),
            subtitle: Text(definition.def));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final _rootWord = dictWord.getRootWord();

    return Scaffold(
        appBar: AppBar(
          title: Text("${dictWord.word}"),
        ),
        body: Column(children: <Widget>[
          // The word
          Container(
              width: 300,
              alignment: Alignment.center,
              margin: const EdgeInsets.all(10.0),
              child: Text(
                dictWord.word,
                style: TextStyle(fontSize: 40.0),
              )),

          // The glyph
          // Note: difficult to center because Flutter thinks it's longer than it really is
          Container(
              width: 300,
              margin: const EdgeInsets.all(10.0),
              child: Container(
                  margin: EdgeInsets.only(left: 135),
                  child: Text(
                    _rootWord,
                    style: TextStyle(fontFamily: 'LinjaPona', fontSize: 30.0),
                  ))),

          // definitions// definitions
          Expanded(child: _buildDefinitionsList())
        ]));
  }
}

// -------------------------
// SETTINGS PAGE
// -------------------------

class SettingsPage extends StatefulWidget {
  static String routeName = "/settingsPage";
  @override
  _SettingsPageState createState() => new _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var _switchValue = false;

  @override
  void initState() {
    SharedPreferencesHelper.getCompoundWordSetting().then((show) {
      setState(() => this._switchValue = show);
    });
    super.initState();
  }

  Widget _buildSwitch() {
    return Align(
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text("Include common compound words"),
          Switch.adaptive(
              value: _switchValue,
              onChanged: (bool value) {
                SharedPreferencesHelper.setCompoundWordSetting(value);
                setState(() {
                  _switchValue = value;
                });
              }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: Column(children: [
          _buildSwitch(),
          Text(
              "The symbols are rendered using jan Same's linja pona font, a rendition of the \"sitelen pona\” script for toki pona.")
        ]));
  }
}

class SharedPreferencesHelper {
  static final String showCompoundWords = "showCompoundWords";

  static Future<bool> getCompoundWordSetting() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(showCompoundWords) ?? false;
  }

  static Future<bool> setCompoundWordSetting(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(showCompoundWords, value);
  }
}
