import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:json_to_form/json_schema.dart';
import 'package:http/http.dart' as http;

import 'package:go_router/go_router.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key, required this.from, this.formId, this.id});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String from;
  final String? formId;
  final String? id;

  @override
  State<FormPage> createState() => _FormPagePageState();
}

class _FormPagePageState extends State<FormPage> {
  Future<String> getAccessForm(String formId, String id) async {
    final response =
        await http.get(Uri.http('127.0.0.1:8080', "/v1/ui/form/$formId/$id"));
    return utf8.decode(response.bodyBytes);
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
    return  FutureBuilder<String>(
                future: getAccessForm(widget.formId!, widget.id!), // a previously-obtained Future<String> or null
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  Widget child;
                  if (snapshot.hasData) {
                    child = Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title:  const Text("Generic Form"),
          leading: IconButton(
            onPressed: () {
              context.go(widget.from.replaceAll("|", "/"));
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child:Column(children: <Widget>[
                      JsonSchema(
                        form: snapshot.data,
                        onChanged: (dynamic response) {
                          this.response = response;
                          print(jsonEncode(response));
                        },
                        actionSave: (data) async {
                          print("SAVE!!!");
                          print(jsonEncode(data));

                          response = await http.post(
                            Uri.parse(
                                "http://127.0.0.1:8080/v1/ui/form/${widget.formId}/${widget.id}"),
                            headers: <String, String>{
                              'Content-Type': 'application/json; charset=UTF-8',
                            },
                            body: jsonEncode(data),
                          );
                          print(response.toString());
                          context.go(widget.from.replaceAll("|", "/"));
                        },
                        autovalidateMode: AutovalidateMode.always,
                        buttonSave: Container(
                          height: 40.0,
                          color: Colors.blueAccent,
                          child: const Center(
                            child: Text("Save",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ]))));
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
                })
         ;
  }
}
