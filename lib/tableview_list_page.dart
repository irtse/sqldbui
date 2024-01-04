import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

class TableViewListPage extends StatelessWidget {
  const TableViewListPage({super.key});


  Future<List<Map<String,dynamic>>> getViewsList() async {
    final response = await http.get(Uri.http('127.0.0.1:8080', '/v1/t/dbtableview'));
    final jsonval = json.decode(response.body);
    List<Map<String,dynamic>> tbls = List.empty(growable: true);
    for (var i = 0; i < jsonval.length; i++) {
      final kv = jsonval[i] as Map;
      tbls.add(kv as Map<String,dynamic>);
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
          title: const Text("Forms"),
        ),
        body: Container(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder(
            future: getViewsList(),
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
                    title: Text(snapshot.data[index]['title']),
                    contentPadding: const EdgeInsets.only(bottom: 20.0),
                    onTap: () => {
                      context.go('/tableview/${snapshot.data[index]['id']}')
                      },
                  ),
                );
              }
            },
          ),
        ));
  }
}
