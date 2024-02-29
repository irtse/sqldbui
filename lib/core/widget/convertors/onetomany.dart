import 'package:flutter_login/flutter_login.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/form.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
class OneToManyWidget extends StatefulWidget {
  final String schemaName;
  final dynamic name;
  bool readOnly;
  bool canPost = false;
  final bool require;
  dynamic value;
  final FormWidgetState component;
  final String? url;
  final String type;
  final String label;
  var isFilled = true;
  OneToManyWidget ({ Key? key, required this.schemaName, required this.name,
                      required this.readOnly, required this.value, required this.label,
                      required this.require, required this.type, required this.url, required this.component}): super(key: key);
  @override
  _OneToManyState createState() => _OneToManyState();
}
class _OneToManyState extends State<OneToManyWidget> {
  List<DataFormWidget> widgets = <DataFormWidget>[];
  @override Widget build(BuildContext context) {
    var schema =  widget.component.widget.view!.schema;
    var scheme = schema[widget.name];
    if (scheme == null) { return Container(); }

    if (widget.value != null) {
      return FutureBuilder<APIResponse<model.View>>(
        future: APIService().get(widget.value, firstAPI, null), 
        builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.View>> snap) {
          List<Widget> items = <Widget>[];
          if (snap.data != null) {
            for (var data in snap.data!.data!) {
              var isDeleted = false; var isFounded = false;
              var w = widget.component.widget.oneToManiesFormDelete;
              if (w[widget.schemaName] != null) {
                for (var deleted in w[widget.schemaName]!) {
                  if (deleted.view!.id == data.id) { isDeleted = true; break; }
                }
              }
              var of = widget.component.widget.oneToManiesForm;
              if (of[widget.schemaName] != null) {
                for (var setted in of[widget.schemaName]!) {
                  if (setted.view!.items.isNotEmpty && setted.view!.items[0].values["id"] == data.id) { isFounded = true; break; }
                }
              }
              if (isDeleted || isFounded) { continue; }
              widget.readOnly = (!data.actions.contains("put") || mainForm.currentState!.widget.view!.readOnly);
              widget.canPost = data.actions.contains("post");
              for (var item in data.items) {
                var view = model.View(name: data.name, readOnly: widget.readOnly,
                                  actions: data.actions, actionPath: data.actionPath, schemaName: data.schemaName,
                                  schema: data.schema, order: data.order, isEmpty: false, items: <model.Item>[item]);
                var dataForm = DataFormWidget(view: view, scroll: false, subForm: true, superFormSchemaName: widget.schemaName,);
                if (!widget.readOnly && data.actions.contains("delete")) {
                  var w = Stack(children: [dataForm,
                            Positioned(top: 50, left: MediaQuery.of(context).size.width - 450, child: IconButton(onPressed: () {
                              setState(() {
                                var w = widget.component.widget.oneToManiesFormDelete;
                                if (!w.containsKey(widget.schemaName)) { 
                                  w[widget.schemaName]=[dataForm]; 
                                } else { w[widget.schemaName]!.add(dataForm); }
                              });
                            }, icon: const Icon(Icons.delete))),],);
                  items.add(w);
                } else {  items.add(dataForm); }
                var e = widget.component.widget.existingOneToManiesForm;
                if (e[widget.schemaName] == null) { e[widget.schemaName] = [dataForm];
                } else { e[widget.schemaName]!.add(dataForm); }
              }
            }
          }
          return Column(children: [Row(children: controlButtons(widget.readOnly, widget.canPost, scheme),)]..addAll(items)..addAll(widgets),);
      });
    }
    return Column(children: [Row(children: controlButtons(widget.readOnly, widget.canPost, scheme),)]..addAll(widgets),);
  }

  List<Widget> controlButtons(bool readOnly, bool canPost, model.SchemaField scheme) {
    List<Widget> rows = [Padding( child: Text("${widget.label.toLowerCase().toLowerCase().toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')} related ${widget.require ? '*' : ''}:"), 
                        padding: EdgeInsets.only(left: 30, top: !readOnly && canPost ? 0 : 20, bottom: !readOnly && canPost ? 0 : 20)),]; 
    if (!readOnly && canPost) {
        rows.add(IconButton(icon: const Icon(Icons.add), onPressed: (){ 
          var mapped = <String, dynamic>{};
          List<String> order = <String>[];
          for (var fieldName in scheme.schema.keys) { 
            mapped[fieldName] = null; 
            order.add(fieldName);
          }
          var newView = model.View(name: "${widget.label} ${widgets.length + 1}", actions: scheme.actions, actionPath: scheme.actionPath,
                                  schema: scheme.schema, order: order, isEmpty: true, items: <model.Item>[model.Item(values: mapped)]);
          setState(() { 
            widgets.add(DataFormWidget(view: newView, scroll: false, subForm: true, superFormSchemaName: widget.schemaName)); 
            widget.component.widget.oneToManiesForm[widget.schemaName] = widgets; 
          });
        },));
        if (widgets.isNotEmpty) {
          rows.add(IconButton(icon: const Icon(Icons.remove), onPressed: (){ 
          setState(() { 
            widgets.remove(widgets.last); 
            widget.component.widget.oneToManiesForm[widget.schemaName] = widgets; 
          }); },));
        }
    }
    return rows;
  }
}