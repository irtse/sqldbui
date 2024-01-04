import 'package:flutter/material.dart';
import 'sql_table.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TableListPage extends StatelessWidget {
  const TableListPage({super.key});

  Future<SqlTable> getTableSchema() async {
    final response = await http.get(Uri.http('127.0.0.1:8080', '/v1/s/test'));
    if (response.statusCode == 200) {
      return SqlTable.fromJson(json.decode(response.body));
    } else {
      throw Exception('Unable to fetch products from the REST API');
    }
  }

  Future<List<String>> getTableList() async {
    final response = await http.get(Uri.http('127.0.0.1:8080', '/v1/s'));
    final jsonval = json.decode(response.body);
    List<String> tbls = List.empty(growable: true);
    for (var i = 0; i < jsonval.length; i++) {
      final kv = jsonval[i] as Map;
      tbls.add(kv['name']);
    }
    if (response.statusCode == 200) {
      return tbls;
    } else {
      throw Exception('Unable to fetch products from the REST API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Tables"),
        ),
        body: Container(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder(
            future: getTableList(),
            builder: (BuildContext ctx, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return Container(
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (ctx, index) => ListTile(
                    title: Text(snapshot.data[index]),
                    contentPadding: const EdgeInsets.only(bottom: 20.0),
                    //onTap: TableView(snapshot.data[index]),
                  ),
                );
              }
            },
          ),
        ));
  }
}
