import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:sqldbui2/core/sections/menu.dart';
import 'package:sqldbui2/core/widget/convertors/manytomany.dart';
import 'package:sqldbui2/core/widget/convertors/onetomany.dart';
import 'package:sqldbui2/core/widget/workflowPanel.dart';
import 'package:sqldbui2/core/widget/workflowbar.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/convertors/convertor.dart';
import 'package:sqldbui2/core/services/api_service.dart';

GlobalKey<FormWidgetState> mainForm = GlobalKey<FormWidgetState>();
Map<String, List<Map<String, dynamic>>> flashedForm = <String, List<Map<String, dynamic>>>{};
// ignore: must_be_immutable
class DataFormWidget extends StatefulWidget {
  Map<String, dynamic> cacheForm = {};
  List<DataFormWidget>wrappers = <DataFormWidget>[];
  final model.View? view;
  bool scroll;
  bool subForm;
  bool detectChange = false;
  String superFormSchemaName;
  Map<String, String> wrappersURL = <String, String>{};
  List<DataFormWidget> existingOneToManiesForm = <DataFormWidget>[];
  Map<DataFormWidget, OneToManyState> oneToManiesStateForm = <DataFormWidget, OneToManyState>{};
  List<DataFormWidget> oneToManiesForm = <DataFormWidget>[];
  List<DataFormWidget> oneToManiesFormDelete = <DataFormWidget>[];
  final formKey = GlobalKey<FormState>();
  DataFormWidget ({ Key? key, this.view, this.scroll = true, this.subForm = false, this.superFormSchemaName = "" }): super(key: key);
  @override FormWidgetState createState() => FormWidgetState();
}
class FormWidgetState extends State<DataFormWidget> {
    bool show = true;
    List<Widget> additionnal = <Widget>[];
    Map<String, WorkflowBarWidget> workflowBars = {};
    @override Widget build(BuildContext context) {
      widget.detectChange = false;
      additionnal = [];
      List<Widget> header = [];
      List<Widget> fields = <Widget>[];
      List<Widget> bottomFields = <Widget>[];
      String name = "Unknown Name";
      String description = "no description";
      if (widget.view != null && widget.view!.items.isNotEmpty) {
        if (widget.view!.isList) { return Container(
          width: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0, 
          height: MediaQuery.of(context).size.height - 95 > 0 ? MediaQuery.of(context).size.height - 95 : 0, 
          decoration: BoxDecoration(
              color: Theme.of(context).highlightColor,
              borderRadius:  const BorderRadius.only(bottomLeft: Radius.circular(7),)),
          child: null); }
        var refItem = widget.view!.items[0];
        if (refItem.workflow != null) { 
          header.add(WorkflowBarWidget(workflow: refItem.workflow!));
          header.add(WorkflowPanelWidget(key: globalWorkflowPanelWidgetKey, workflow: refItem.workflow!));  
        }
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
        List<Widget> title = [];
        if (name != "") {
          title.add(Padding( padding: const EdgeInsets.only(left: 130), child: Row( 
            children: [ 
              Flexible( child: Text(name, overflow: TextOverflow.ellipsis, 
                style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 25))) 
          ])));
        }
        if (description != "" && !description.contains("no description")) {
            title.add(
              Padding( padding: const EdgeInsets.only(left: 130), child: Row( 
                children: [ Icon(Icons.description, size: 20, color: Theme.of(context).splashColor), 
                    Flexible( child: Text(overflow: TextOverflow.ellipsis, description, 
                      style: TextStyle(color: Theme.of(context).selectedRowColor)))] ))
              );
        }
        widget.wrappers = [];
        additionnal = [];
        for (var url in widget.wrappersURL.values) {
          additionnal.add(Container( decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.only(top: 15),
            width: MediaQuery.of(context).size.width - menuSize - 80 > 0 ? MediaQuery.of(context).size.width - menuSize - 80 : 0,
            child: Padding( padding: const EdgeInsets.only(bottom: 30), child: FutureBuilder<APIResponse<model.View>>(
              future: APIService().get<model.View>(url, firstAPI, null), 
              builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.View>> snap) {
                if (snap.hasData && snap.data!.data != null && snap.data!.data!.isNotEmpty) {
                  for (var data in snap.data!.data!) {
                    developer.log("THERE", name: "data");
                    if (data.workflow != null && !workflowBars.containsKey(url)) { 
                      Future.delayed(const Duration(seconds: 1), () { 
                        setState(() { workflowBars[url] = WorkflowBarWidget(workflow: data.workflow!); }); }
                      );
                    }  
                    var newView = model.View(name: "${widget.view!.isEmpty ? "empty " : ""}${data.schemaName.replaceAll("_", " ").replaceAll("db", "")} formulary",
                      workflow: data.workflow,
                      linkPath: data.linkPath, schema: data.schema, order: data.order, 
                      actionPath: data.actionPath.contains(data.schemaName) ? data.actionPath : data.linkPath,
                      actions: data.actions, readOnly: data.readOnly, schemaName: data.schemaName, 
                      items: data.items.isNotEmpty && !widget.view!.isEmpty ? data.items : <model.Item>[model.Item()] );
                    newView.isEmpty = widget.view!.isEmpty;
                    var w = DataFormWidget(view: newView, scroll: false, subForm: true,);
                    widget.wrappers.add(w);
                    return w;
                  }
                }
                return const SizedBox(width: 10, height: 10, child: Text(""));
              }
          ))));
          if (workflowBars.containsKey(url) && !widget.subForm) { header = [ workflowBars[url]! ]; }
        } 
        if (!widget.subForm) {
          fields.add( 
            Container( width: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0,
              margin: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration( color: Colors.white, boxShadow: [
                BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 0, blurRadius: 3,
                        offset: const Offset(3, 3), // changes position of shadow
                      ),
              ]), child: Column(children: [ Padding(padding: EdgeInsets.only(top: 50, bottom: header.isEmpty ? 30 : 0), 
                child: Column(children: title,)),...header]), )
          );
        } else if (name != "") {
          fields.add(SizedBox( height: 30, 
                child:  Stack( children: [ Row( children: [ Padding(padding: const EdgeInsets.only(right: 15, top: 1), 
                    child: Icon(Icons.document_scanner, color: Theme.of(context).splashColor, size: 30,)), 
                    Flexible( child: Text(name[0].toUpperCase() + name.substring(1).toLowerCase(), overflow: TextOverflow.ellipsis,
                      style:TextStyle(color: Theme.of(context).secondaryHeaderColor, fontSize: 18))) ]),
                  Positioned(right: -20, top: -15, child: IconButton(onPressed: () => { setState(() => show = !show)}, 
                    icon: Icon(show ?  Icons.arrow_drop_down_sharp : Icons.arrow_drop_up_sharp, 
                  color: Theme.of(context).primaryColor, size: 45,),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,  
                  hoverColor: Colors.transparent,))
                ])));
          fields.add(Divider(thickness: 1, color: Theme.of(context).splashColor,));
        }
        var newCacheEntry = <String,dynamic>{"id" : refItem.values["id"]};
        double counter = 0;
        for (var fieldName in widget.view!.order) {
          if (schema[fieldName] == null || (widget.superFormSchemaName != "" && fieldName.contains(widget.superFormSchemaName))) { continue; }
          counter++;
        }
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
                                              readOnly, widget.view!.isEmpty ? null : value, url, this);
            if (f != null && f.runtimeType != OneToManyWidget && f.runtimeType != ManyToManyWidget && show) {
              var w = Padding(padding: EdgeInsets.only(left: 10.0, right: 10.0, 
              top: field.type.contains("bool") ? 0 : 11.0 , bottom: field.type.contains("bool") ? 30 : 11.0),
              child: SizedBox( width:  field.type.contains("bool") ? 150 : (counter > 1 ?
                  ((MediaQuery.of(context).size.width - menuSize - 100 > 0 ? MediaQuery.of(context).size.width - menuSize - 100 : 1) / 2.3)
                  : MediaQuery.of(context).size.width - menuSize - 100  > 0 ? MediaQuery.of(context).size.width - menuSize - 100 : 1), 
                height: field.type.contains("text") ? 100 : 30, child: f));
              fields.add(w);
            }
            if (((f.runtimeType == OneToManyWidget || f.runtimeType == ManyToManyWidget) && show) 
            && !(widget.view!.isEmpty && !widget.view!.actions.contains("post"))) { 
              bottomFields.add(
                Padding(padding: const EdgeInsets.only(bottom: 30), 
                  child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).splashColor,
                  ), child: Padding(padding: const EdgeInsets.all(10), child: f!,)))); 
            }
          } 
        }
        widget.cacheForm = newCacheEntry;
      }
      List<Widget> divider = widget.subForm ? [] : [Padding( padding: const EdgeInsets.only(top: 20, bottom: 20), child: Divider(color: Theme.of(context).splashColor),)];
      var form = Padding(padding: EdgeInsets.all(widget.subForm ? 40 : 0), 
      child: Form( key: widget.formKey, 
        autovalidateMode: AutovalidateMode.always,
        child: Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(7),),
            ),
            child: Wrap(
               alignment: WrapAlignment.center,
              children: [...fields, ...bottomFields, ...divider, ...additionnal]))));
      return widget.scroll ? Container( decoration: BoxDecoration(
                  color: Theme.of(context).highlightColor,
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(7),),
                ),
                // color: widget.subForm ? Colors.transparent : Theme.of(context).highlightColor,
                width: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0,
                height: MediaQuery.of(context).size.height - 95 > 0 ? MediaQuery.of(context).size.height - 95 : 0,
                child: Padding( padding: const EdgeInsets.only(bottom: 5), 
                  child: SingleChildScrollView( scrollDirection: Axis.vertical, 
                    child: Padding( padding: const EdgeInsets.all(0), child: form) )))
              : Container( decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 0, blurRadius: 3,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(widget.subForm ? 10 : 0),),
                ),
                width: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0,
                child: form,
              );
    }
}