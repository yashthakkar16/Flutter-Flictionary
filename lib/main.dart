import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flictionary',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String _url = "https://owlbot.info/api/v4/dictionary/";
  final String _token = "fa966b0057f03557496558292d1112a0da2284cb";

  final TextEditingController _controller = TextEditingController();

  late StreamController _streamController;
  late Stream _stream;

  // late Timer _debounce;

  _search() async {
    if (_controller.text.isEmpty) {
      _streamController.add(null);
      return;
    }

    _streamController.add("waiting");
    Response response = await get(Uri.parse(_url + _controller.text.trim()), headers: {"Authorization": "Token " + _token});
    _streamController.add(json.decode(response.body));
  }

  @override
  void initState() {
    super.initState();

    _streamController = StreamController();
    _stream = _streamController.stream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child:Text("Flictionary")),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 12.0, bottom: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: TextFormField(
                    onChanged: (String text) {
                      // if (_debounce?.isActive ?? false) _debounce.cancel();
                      // _debounce = Timer(const Duration(milliseconds: 1000), () {
                      //   _search();
                      // });
                    },
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Search for a word",
                      contentPadding: EdgeInsets.only(left: 24.0),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                onPressed: () {
                  _search();
                },
              )
            ],
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(8.0),
        child: StreamBuilder(
          stream: _stream,
          builder: (BuildContext ctx, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return const Center(
                child: Text("Enter a search word"),
              );
            }

            if (snapshot.data == "waiting") {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return ListView.builder(
              itemCount: snapshot.data["definitions"].length,
              itemBuilder: (BuildContext context, int index) {
                return ListBody(
                  children: <Widget>[
                    Container(
                      color: Colors.grey[300],
                      child: ListTile(
                        leading: snapshot.data["definitions"][index]["image_url"] == null
                            ? null
                            : CircleAvatar(
                                backgroundImage: NetworkImage(snapshot.data["definitions"][index]["image_url"]),
                              ),
                        title: Text(_controller.text.trim() + "(" + snapshot.data["definitions"][index]["type"] + ")"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(snapshot.data["definitions"][index]["definition"]),
                    )
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}