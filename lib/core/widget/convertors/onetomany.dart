import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/form.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

// ignore: must_be_immutable
class OneToManyWidget extends StatefulWidget {
  final String schemaName;
  final dynamic name;
  bool readOnly;
  bool canPost = false;
  final bool require;
  dynamic value;
  final String? url;
  final String type;
  final String label;
  var isFilled = true;
  var flashed = <int, DataFormWidget>{};
  final FormWidgetState component;
  OneToManyWidget ({ Key? key, required this.schemaName, required this.name,
                      required this.readOnly, required this.value, required this.label,
                      required this.require, required this.type, required this.url, required this.component}): super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  OneToManyState createState() => OneToManyState();
}
class OneToManyState extends State<OneToManyWidget> {
  @override Widget build(BuildContext context) {
    var schema =  widget.component.widget.view!.schema;
    var scheme = schema[widget.name];
    if (scheme == null) { return Container(); }
    var filtered = widget.component.widget.oneToManiesForm.where((element) => element.view!.name.contains(widget.label));
    if (widget.value != null) {
      return FutureBuilder<APIResponse<model.View>>(
        future: APIService().get(widget.value, firstAPI, null), 
        builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.View>> snap) {
          List<Widget> items = <Widget>[];
          if (snap.data != null) {
            for (var data in snap.data!.data!) {
              widget.readOnly = (!data.actions.contains("put") || mainForm.currentState!.widget.view!.readOnly);
              widget.canPost = data.actions.contains("post");
              for (var item in data.items) {
                var isDeleted = false;
                var w = widget.component.widget.oneToManiesFormDelete;
                for (var deleted in w) {
                  if ("${deleted.view!.id}" == "${item.values["id"]}") { isDeleted = true; break; }
                }
                if (isDeleted) { continue; }
                var view = model.View(id: int.parse(item.values["id"]), name: data.name, readOnly: widget.readOnly,
                                  actions: data.actions, actionPath: data.actionPath, schemaName: data.schemaName,
                                  schema: data.schema, order: data.order, isEmpty: false, items: <model.Item>[item]);
                var dataForm = widget.flashed.containsKey(int.parse(item.values["id"])) ? widget.flashed[int.parse(item.values["id"])]! 
                : DataFormWidget(view: view, scroll: false, subForm: true, superFormSchemaName: widget.schemaName,);
                widget.flashed[dataForm.view!.id] = dataForm;
                if (!widget.readOnly && data.actions.contains("delete")) {
                  var w = Stack(children: [dataForm,
                            Positioned(top: 50, left: MediaQuery.of(context).size.width - 450, 
                            child: IconButton(onPressed: () {
                              widget.component.widget.detectChange = true;
                              setState(() {
                                var w = widget.component.widget.oneToManiesFormDelete;
                                w.add(dataForm);
                              });
                            }, icon: const Icon(Icons.delete)))],);
                  items.add(w);
                } else {  items.add(dataForm); }
                var e = widget.component.widget.existingOneToManiesForm;
                e.add(dataForm);
              }
            }
          }
          return Column(children: [Row(children: controlButtons(widget.readOnly, widget.canPost, scheme),)]..addAll(items)..addAll(filtered),);
      });
    }
    return Column(children: [Row(children: controlButtons(widget.readOnly, widget.canPost, scheme),)]..addAll(filtered),);
  }

  List<Widget> controlButtons(bool readOnly, bool canPost, model.SchemaField scheme) {
    List<Widget> rows = [Padding( padding: EdgeInsets.only(left: 30, top: !readOnly && canPost ? 0 : 20, bottom: !readOnly && canPost ? 0 : 20), 
                                  child: Text("related ${widget.label.toLowerCase().toLowerCase().toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')} ${widget.require ? '*' : ''}:")),]; 
    
    if (!readOnly && canPost || widget.component.widget.view != null && widget.component.widget.view!.isEmpty) {
        var filtered = widget.component.widget.oneToManiesForm.where((element) => element.view!.name.contains(widget.label));
        rows.add(IconButton(icon: const Icon(Icons.add), onPressed: (){ 
          widget.component.widget.detectChange = true;
          var mapped = <String, dynamic>{};
          List<String> order = <String>[];
          for (var fieldName in scheme.schema.keys) { 
            mapped[fieldName] = null; 
            order.add(fieldName);
          }
          var newView = model.View(name: "${widget.label} ${filtered.length + 1}", actions: scheme.actions, actionPath: scheme.actionPath,
                                  schema: scheme.schema, order: order, isEmpty: true, items: <model.Item>[model.Item(values: mapped)]);
          setState(() { 
            var k = GlobalKey<FormWidgetState>();
            widget.component.widget.oneToManiesForm.add(DataFormWidget(key: k, view: newView, scroll: false, subForm: true, superFormSchemaName: widget.schemaName)); 
            widget.component.widget.oneToManiesStateForm[widget.component.widget.oneToManiesForm.last]=this; 
          });
        },));
        if (filtered.isNotEmpty) {
          rows.add(IconButton(icon: const Icon(Icons.remove), onPressed: (){ 
            widget.component.widget.detectChange = true;
            setState(() { 
              var val = widget.component.widget.oneToManiesForm.where((element) => element.view!.name.contains(widget.label));
              if (val.isNotEmpty) {
                widget.component.widget.oneToManiesForm.remove(val.last); 
                try { widget.component.widget.oneToManiesStateForm.remove(val.last); 
                } catch(e) { /* EMPTY and proud to be */ } 
              }
            });},));
        }
    }
    return rows;
  }
}
// TODO FILTER