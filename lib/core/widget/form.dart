import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:sqldbui2/core/widget/convertors/manytomany.dart';
import 'package:sqldbui2/core/widget/convertors/onetomany.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/convertors/convertor.dart';
import 'package:sqldbui2/core/services/api_service.dart';

GlobalKey<FormWidgetState> mainForm = GlobalKey<FormWidgetState>();
List<GlobalKey<FormState>> globalFormsKey = <GlobalKey<FormState>>[];
// ignore: must_be_immutable
class DataFormWidget extends StatefulWidget {
  List<Map<String, dynamic>> cacheForm = [];
  List<DataFormWidget>wrappers = <DataFormWidget>[];
  final model.View? view;
  bool scroll;
  String superFormSchemaName;
  bool subForm;
  Map<String, String> wrappersURL = <String, String>{};
  List<DataFormWidget> existingOneToManiesForm = <DataFormWidget>[];
  List<DataFormWidget> oneToManiesForm = <DataFormWidget>[];
  List<DataFormWidget> oneToManiesFormDelete = <DataFormWidget>[];
  final formKey = GlobalKey<FormState>();
  DataFormWidget ({ Key? key, this.view, this.scroll = true, this.subForm = false, this.superFormSchemaName = "" }): super(key: key);
  @override FormWidgetState createState() => FormWidgetState();
}
class FormWidgetState extends State<DataFormWidget> {
    List<Widget> additionnal = <Widget>[];
    @override Widget build(BuildContext context) {
      additionnal = [];
      List<Widget> fields = <Widget>[];
      List<Widget> bottomFields = <Widget>[];
      String name = "Unknown Name";
      String description = "no description";
      if (widget.view != null && widget.view!.items.isNotEmpty) {
        var refItem = widget.view!.items[0];
        name = widget.view!.name.toUpperCase().replaceAll("DB", "").replaceAll("_", " ");
        description = widget.view!.description.toLowerCase().replaceAll("db", "").replaceAll("_", " ");
        if (refItem.values.containsKey("name") && refItem.values["name"] != null) {
          name += ": ${refItem.values["name"].toUpperCase()}";
        }
        if (refItem.values.containsKey("description") && refItem.values["description"] != null) {
          description = refItem.values["description"].toLowerCase();
        }
        if (refItem.dataPath != "") { widget.wrappersURL["relatedDatas"] = refItem.dataPath; }
        var schema = widget.view!.schema;
        if (name != "") {
          fields.add(Center( child: Container( height: 30, 
                margin: EdgeInsets.only(bottom: 5 , left: widget.subForm ? 30 : 0),
                width: MediaQuery.of(context).size.width - 400,
                child: Text(name, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20))),
              ));   
        }
        if (description != "" && !description.contains("no description")) {
            fields.add(
              Center(child: Container( height: 20, 
                  margin: EdgeInsets.only(bottom: 15, left: widget.subForm ? 50 : 0),
                  width: MediaQuery.of(context).size.width - 400,
                  child: Text(description, style: TextStyle(color: Theme.of(context).primaryColor)))
              ));
        }
        widget.wrappers = [];
        additionnal = [];
        for (var url in widget.wrappersURL.values) {
          additionnal.add(Container(
            margin: const EdgeInsets.only(top: 15),
            width: MediaQuery.of(context).size.width - 200,
            child: FutureBuilder<APIResponse<model.View>>(
              future: APIService().get<model.View>(url, firstAPI, null), 
              builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.View>> snap) {
                if (snap.hasData && snap.data!.data != null && snap.data!.data!.isNotEmpty) {
                  for (var data in snap.data!.data!) {
                    var newView = model.View(name: "Form",
                      linkPath: data.linkPath, schema: data.schema, order: data.order, 
                      actionPath: data.actionPath.contains(data.schemaName) ? data.actionPath : data.linkPath,
                      actions: data.actions, readOnly: data.readOnly, schemaName: data.schemaName, 
                      items: data.items.isNotEmpty && !widget.view!.isEmpty ? data.items : <model.Item>[model.Item()] );
                    newView.isEmpty = widget.view!.isEmpty;
                    var w = DataFormWidget(view: newView, scroll: false,);
                    widget.wrappers.add(w);
                    return w;
                  }
                }
                return const SizedBox(width: 10, height: 10, child: Text(""));
              }
          )));
        } 
        var newCacheEntry = <String,dynamic>{"id" : refItem.values["id"]};
        for (var fieldName in widget.view!.order) {
          if (schema[fieldName] == null || (widget.superFormSchemaName != "" && fieldName.contains(widget.superFormSchemaName))) { continue; }
          var field = schema[fieldName]!; 
          var value = refItem.values.containsKey(fieldName) ? refItem.values[fieldName] : null;
          if (refItem.valuesShallow.containsKey(fieldName)) { 
            var v = refItem.valuesShallow[fieldName]!;
            value = v.label ?? v.name ?? v.id;
          }
          if (refItem.valuesMany.containsKey(fieldName)) { value = refItem.valuesMany[fieldName]!; }
          if (refItem.valuesManyPath.containsKey(fieldName)) { value = refItem.valuesManyPath[fieldName]!; }
          var readOnly = (field.readonly || mainForm.currentState!.widget.view!.readOnly) && !widget.view!.isEmpty;
          if (newCacheEntry[fieldName] == null) { newCacheEntry[fieldName]=value; } 
          if ((fieldName == "name" && field.readonly && (refItem.values.containsKey("name") && refItem.values["name"] != null))
          || (fieldName == "description" && field.readonly && (refItem.values.containsKey("description") && refItem.values["description"] != null)) ) { continue; }
          String? url;
          if (!readOnly && field.valuesPath != "") { url = field.valuesPath; }
          if(!(readOnly && value == null)) {
            var f = Convertor.formFieldByType(newCacheEntry, context, widget.view!.schemaName, field.type, 
                                              fieldName, field.label, field.description, field.require, 
                                              readOnly, value, url, this);
            if (f != null && f.runtimeType != OneToManyWidget && f.runtimeType != ManyToManyWidget) {
              var w = Padding(padding: EdgeInsets.only(left: 50.0, right: 50.0, 
              top: field.type.contains("bool") ? 0 : 11.0 , bottom: 11.0),
              child: SizedBox(width:  field.type.contains("bool") ? 150 : 500, height: 30, child: f));
              fields.add(w);
            }
            if ((f.runtimeType == OneToManyWidget || f.runtimeType == ManyToManyWidget) 
            && !(widget.view!.isEmpty && !widget.view!.actions.contains("post"))) { 
              bottomFields.add(
                Padding(padding: const EdgeInsets.only(bottom: 30), 
                  child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).splashColor,
                  ),
                  child: Padding(padding: const EdgeInsets.all(10), child: f!,)))); 
            }
          } 
        }
        widget.cacheForm.add(newCacheEntry);
      }
      globalFormsKey.add(widget.formKey);
      var form = Form( key: widget.formKey, 
        autovalidateMode: AutovalidateMode.always,
        child: Wrap(
            alignment: WrapAlignment.center,
            children: [Padding( padding: EdgeInsets.only(left: 30, right: 30, bottom: widget.subForm ? 30 : 0), child: Divider(color: widget.subForm ? Colors.grey : Colors.transparent, ),)]..addAll(fields)..add(
                  Container(height: 10)
                )..addAll(bottomFields)..add(
              Padding( padding: const EdgeInsets.only(top: 20), child: Divider(color: widget.subForm ? Colors.transparent : Theme.of(context).primaryColor),)
              )..addAll(additionnal)));
      return widget.scroll ? Container(
                color: widget.subForm ? Colors.transparent : Theme.of(context).highlightColor,
                width: MediaQuery.of(context).size.width - 250,
                height: MediaQuery.of(context).size.height - 110,
                child: SingleChildScrollView( scrollDirection: Axis.vertical, 
                  child: Padding( padding: const EdgeInsets.all(50), child: form) ))
              : Container(
                color: widget.subForm ? Colors.transparent : Theme.of(context).highlightColor,
                width: MediaQuery.of(context).size.width - 260,
                child: form,
              );
    }
}