import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:go_router/go_router.dart';

class TableViewPage extends StatefulWidget {
  const TableViewPage({super.key, this.id});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String? id;

  @override
  State<TableViewPage> createState() => _TableViewPagePageState();
}

class _TableViewPagePageState extends State<TableViewPage> {
  Future<Map<String, dynamic>> getTableView(String id) async {
    final response =
        await http.get(Uri.http('127.0.0.1:8080', "/v1/ui/tableview/$id"));
    return json.decode(response.body);
  }

  dynamic response;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return FutureBuilder<Map<String, dynamic>>(
        future: getTableView(
            widget.id!), // a previously-obtained Future<String> or null
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, dynamic>> snapshot) {
          Widget child;
          if (snapshot.hasData) {
            var listview = snapshot.data!;
            child = Scaffold(
                appBar: AppBar(
                  // Here we take the value from the MyHomePage object that was created by
                  // the App.build method, and use it to set our appbar title.
                  title: Text(listview["title"]),
                  leading: IconButton(
                    onPressed: () {
                      context.go('/tableviews');
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                ),
                body: ListView.builder(
                  itemCount: listview["items"].length,
                  itemBuilder: (ctx, index) => ListTile(
                    title: Text(listview["items"][index]['name']),
                    contentPadding: const EdgeInsets.only(bottom: 20.0),
                    onTap: () => {
                      context.go('/form/' '|tableview|'+widget.id!.toString()+'/'+
                          listview["form_id"].toString() +
                          "/" +
                          listview["items"][index]['id'].toString())
                    },
                  ),
                ));
          } else if (snapshot.hasError) {
            child = Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            child = const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            );
          }
          return child;
        });
  }
}
