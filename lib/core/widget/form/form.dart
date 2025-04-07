import 'package:flutter/material.dart';
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/services/action.dart';
import 'package:sqldbui2/core/widget/form/convertors/manytomany.dart';
import 'package:sqldbui2/core/widget/form/convertors/onetomany.dart';
import 'package:sqldbui2/core/widget/dialog/confirm_box.dart';
import 'package:sqldbui2/core/widget/utils/button.dart';
import 'package:sqldbui2/core/widget/workflow/workflowPanel.dart';
import 'package:sqldbui2/core/widget/workflow/workflowbar.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/form/convertors/convertor.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/page/translate.dart';

GlobalKey<FormWidgetState> mainForm = GlobalKey<FormWidgetState>();
Map<String, List<Map<String, dynamic>>> flashedForm = <String, List<Map<String, dynamic>>>{};
// ignore: must_be_immutable
class DataFormWidget extends StatefulWidget {
  Map<String, dynamic> cacheForm = {};
  List<DataFormWidget>wrappers = <DataFormWidget>[];
  List<GlobalKey<FormWidgetState>>wrappersGlobalKey = <GlobalKey<FormWidgetState>>[];
  final model.View? view;
  bool scroll;
  bool subForm;
  bool isSplitted;
  bool detectChange = false;
  String superFormSchemaName;
  Map<String, String> wrappersURL = <String, String>{};
  List<DataFormWidget> existingOneToManiesForm = <DataFormWidget>[];
  Map<DataFormWidget, OneToManyState> oneToManiesStateForm = <DataFormWidget, OneToManyState>{};
  List<DataFormWidget> oneToManiesForm = <DataFormWidget>[];
  List<DataFormWidget> oneToManiesFormDelete = <DataFormWidget>[];
  final formKey = GlobalKey<FormState>();
  DataFormWidget ({ super.key, 
    this.view, 
    this.scroll = true, 
    this.subForm = false, 
    this.isSplitted = false,
    this.superFormSchemaName = "" });
  @override FormWidgetState createState() => FormWidgetState();
}
class FormWidgetState extends State<DataFormWidget> {
    bool show = true;
    List<Widget> additionnal = <Widget>[];
    Map<String, WorkflowBarWidget> workflowBars = {};
    @override Widget build(BuildContext context) {
      return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
      widget.detectChange = false;
      additionnal = [];
      List<Widget> header = [];
      List<Widget> head = [];
      List<Widget> fields = <Widget>[];
      List<Widget> bottomFields = <Widget>[];
      List<Widget> positionnedBar = [];
      String name = "Unknown Name";
      String description = "no description";
      model.Workflow? wf;
      bool isSplitted = (widget.isSplitted || (widget.view?.isWrapper ?? false)) && !currentView!.isEmpty;
      double ratioSplit = isSplitted ? 0.7 : 1;
      if (widget.view != null && widget.view!.items.isNotEmpty) {
        var refItem = widget.view!.items[0];
        if (refItem.workflow != null) { 
          wf = refItem.workflow; 
          header.add(WorkflowBarWidget(workflow: refItem.workflow!));
          header.add(WorkflowPanelWidget(key: globalWorkflowPanelWidgetKey, 
            workflow: refItem.workflow!, readOnly: refItem.readonly));  
        }
        name = widget.view!.name.toUpperCase().replaceAll("DB", "").replaceAll("_", " ");
        description = widget.view!.description.toLowerCase().replaceAll("db", "").replaceAll("_", " ");
        if (refItem.values.containsKey("name") && refItem.values["name"] != null) { 
          name += ": ${refItem.values["name"].toUpperCase()}"; }
        if (refItem.values.containsKey("description") && refItem.values["description"] != null) { 
          description = refItem.values["description"].toLowerCase(); }
        if (refItem.dataPath != "") { widget.wrappersURL["relatedDatas"] = refItem.dataPath; }
        var schema = widget.view!.schema;
        List<Widget> states = [];
        widget.wrappers = [];
        additionnal = [];
        if (currentView != null && currentView!.isEmpty && widget.subForm) { widget.wrappersURL = {}; }
        widget.wrappersGlobalKey = [];
        if (widget.wrappersURL.isEmpty && widget.view!.isEmpty && !widget.subForm) {
          additionnal.add(Container( decoration: BoxDecoration(
            color: Theme.of(context).splashColor,
            borderRadius: BorderRadius.circular(10)
          ),
          padding: const EdgeInsets.all(20), 
          width: MediaQuery.of(context).size.width - menuSize - 80 > 0 ? MediaQuery.of(context).size.width - menuSize - 80 : 0,
          child:  Wrap( 
            alignment: WrapAlignment.center,
            children: [
              Padding( padding: const EdgeInsets.all(20), 
                child: Container( 
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  width: MediaQuery.of(context).size.width / 3, height: 40 )),
              Padding( padding: const EdgeInsets.all(20), child: Container( 
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10)
                  ),
                width: MediaQuery.of(context).size.width / 3, height: 40 )),
              Padding( padding: const EdgeInsets.all(20), child: Container( 
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10)
                  ),
                width: MediaQuery.of(context).size.width / 3, height: 40)),
              Padding( padding: const EdgeInsets.all(20), child: Container( 
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10)
                  ),
                width: MediaQuery.of(context).size.width / 3, height: 40 )),
              Padding( padding: const EdgeInsets.all(20), child: Container( 
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10)
                  ),
                width: MediaQuery.of(context).size.width / 3, height: 40 )),
            ],
          )));
        }
        for (var url in widget.wrappersURL.values) {
          additionnal.add(Container( decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.only(top: 15),
            width: MediaQuery.of(context).size.width - menuSize - 80 > 0 ? MediaQuery.of(context).size.width - menuSize - 80 : 0,
            child: Padding( padding: const EdgeInsets.only(bottom: 30), child: FutureBuilder<APIResponse<model.View>>(
              future: APIService().get<model.View>(url, firstAPI, null), 
              builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.View>> snap) {
               
                if (snap.hasData && snap.data!.data != null && snap.data!.data!.isNotEmpty) {
                  for (var data in snap.data!.data!) {
                    if (data.workflow != null && !workflowBars.containsKey(url)) { 
                      Future.delayed(const Duration(seconds: 1), () { setState(() { workflowBars[url] = WorkflowBarWidget(workflow: data.workflow!); }); } );
                    }  
                    var newView = model.View(name: "${widget.view!.isEmpty ? "empty " : ""}${widget.view!.isEmpty ? data.name : data.schemaName.replaceAll("_", " ").replaceAll("db", "")} formulary",
                      workflow: data.workflow,
                      linkPath: data.linkPath, schema: data.schema, order: data.order, 
                      actionPath: data.actionPath.contains(data.schemaName) ? data.actionPath : data.linkPath,
                      actions: data.actions, readOnly: widget.view!.readOnly || refItem.readonly || data.readOnly, 
                      schemaName: data.schemaName, 
                      items: data.items.isNotEmpty && !widget.view!.isEmpty ? data.items : <model.Item>[model.Item()] );
                    newView.isEmpty = widget.view!.isEmpty;
                    GlobalKey<FormWidgetState> newViewKey = GlobalKey<FormWidgetState>();
                    var w = DataFormWidget(key: newViewKey, view: newView, scroll: false, isSplitted: isSplitted, subForm: true);
                    widget.wrappersGlobalKey.add(newViewKey);
                    widget.wrappers.add(w);
                    return w;
                  }
                }
                return const SizedBox(width: 10, height: 10, child: Text(""));
              }
          ))));
          if (workflowBars.containsKey(url) && !widget.subForm) { header = [ workflowBars[url]! ]; }
        } 
        var newCacheEntry = <String,dynamic>{"id" : refItem.values["id"]};
        double counter = 0;
        for (var fieldName in widget.view!.order) {
          if (schema[fieldName] == null || (widget.superFormSchemaName != "" && fieldName.contains(widget.superFormSchemaName))) { continue; }
          counter++;
        }
        for (var fieldName in widget.view!.order) {
          if (schema[fieldName] == null || ["id", "description"].contains(fieldName) ||
          (widget.superFormSchemaName != "" && fieldName.contains(widget.superFormSchemaName))) { continue; }
          var field = schema[fieldName]!; 
          var value = refItem.values.containsKey(fieldName) ? refItem.values[fieldName] : null;
          String path = "";
          if (refItem.valuesShallow.containsKey(fieldName)) { 
            var v = refItem.valuesShallow[fieldName]!;
            value = v.label ?? v.name ?? v.id;
            path = v.ref ?? "";
          }
          if (refItem.valuesMany.containsKey(fieldName)) { value = refItem.valuesMany[fieldName]!; }
          if (refItem.valuesManyPath.containsKey(fieldName)) { value = refItem.valuesManyPath[fieldName]!; }
          print("${field.readonly} ${widget.view!.readOnly} ${refItem.readonly}");
          var readOnly = (field.readonly || widget.view!.readOnly || refItem.readonly) && !widget.view!.isEmpty;
          readOnly = readOnly || !((widget.view!.actions.contains("post") && widget.view!.isEmpty) || widget.view!.actions.contains("put"));
          if (field.label == "state") {
            readOnly = true; 
            if (widget.view!.actions.contains("put") && !widget.view!.isEmpty && value != "completed" && value != "dismiss" && value != "refused") {
                positionnedBar.add(Padding( padding: const EdgeInsets.only(left: 20, right: 20), child: FloatingActionButton(
                  tooltip: TranslateConstants.validate.toLowerCase(),
                  onPressed: () {
                  showDialog(context: context, builder: (builder) => ConfirmBoxWidget(purpose: "validate task", validate: () {
                      widget.detectChange = true;
                      widget.cacheForm[fieldName] = "completed";
                      ActionService.pressed(null, false, currentView!.schemaName, currentView!.actionPath, <String>["id"], currentView!.schema, "put", context)();
                    }));
                }, backgroundColor: Colors.green, child: const Icon(Icons.check, color: Colors.white))));
                positionnedBar.add(Padding( padding: const EdgeInsets.only(right: 20), child: FloatingActionButton(
                  tooltip: TranslateConstants.dismiss.toLowerCase(),
                  onPressed: () {
                    showDialog(context: context, builder: (builder) => ConfirmBoxWidget(purpose: "dismiss task", validate: () {
                      widget.detectChange = true;
                      widget.cacheForm[fieldName] = "dismiss";
                      ActionService.pressed(null, false, currentView!.schemaName, currentView!.actionPath, <String>["id"], currentView!.schema, "put", context)();
                    }));
                }, backgroundColor: Colors.orange, child: const Icon(Icons.restore, color: Colors.white))));
                positionnedBar.add(FloatingActionButton(
                  tooltip: TranslateConstants.filterCancel.toLowerCase(),
                  onPressed: () {
                    showDialog(context: context, builder: (builder) => ConfirmBoxWidget(purpose: "refused task", validate: () {
                      widget.detectChange = true;
                      widget.cacheForm[fieldName] = "refused";
                      ActionService.pressed(null, false, currentView!.schemaName, currentView!.actionPath, <String>["id"], currentView!.schema, "put", context)();
                    }));
                }, backgroundColor: Colors.red, child: const Icon(Icons.close, color: Colors.white)));  
            }
            states.add(Padding(padding: const EdgeInsets.only(top: 3, left: 12), child: Container( padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                decoration: BoxDecoration( borderRadius: BorderRadius.circular(30), color: value == "completed" ? Colors.green : (value == "dismiss" ? Colors.red : Colors.orange)),
                child: Text((await getOnFlow(value)).toLowerCase(), style: const TextStyle(color: Colors.white, fontSize: 10)))));
            continue;
          } // to remove if change its mind
          if (newCacheEntry[fieldName] == null) { newCacheEntry[fieldName]=value; } 
          if ((fieldName == "name" && field.readonly && (refItem.values.containsKey("name") && refItem.values["name"] != null))
          || (fieldName == "description" && field.readonly && (refItem.values.containsKey("description") && refItem.values["description"] != null)) ) { continue; }
          String? url;
          if (!readOnly && field.valuesPath != "") { url = field.valuesPath; }
          if(!(readOnly && value == null)) { 
            double max = (counter > 1 ?
                  ((MediaQuery.of(context).size.width - menuSize - 100 > 0 ? MediaQuery.of(context).size.width - menuSize - 100 : 1) / (
                    (isSplitted && (MediaQuery.of(context).size.width - menuSize < (widget.subForm ? 1000 : 800)) ? 1 : 3)))
                  : MediaQuery.of(context).size.width - menuSize - 100  > 0 ? MediaQuery.of(context).size.width - menuSize - 100 : 1);
            var f = await Convertor.formFieldByType(newCacheEntry, context, widget.view!.schemaName, field.type, fieldName, field.label, field.description, 
                                              field.require, readOnly, widget.view!.isEmpty ? null : value, url, path, max, this);
            if (f != null && f.runtimeType != OneToManyWidget && f.runtimeType != ManyToManyWidget && show) {
              var w = Padding(padding: EdgeInsets.only(left: field.type.contains("bool") ? ((widget.subForm ? max - 230 : max - 180) / 2) : 10.0, 
                right: field.type.contains("bool") ? ((widget.subForm ? max - 230 : max - 180) / 2) : 10.0,  top: 11.0 , bottom: 11.0),
              child: SizedBox( width: field.type.contains("bool") ? 200 : (widget.subForm ? max - 50 : max), 
                height: field.type.contains("text") ? 100 : 30, child: f));
              fields.add(w);
            }
            if (((f.runtimeType == OneToManyWidget || f.runtimeType == ManyToManyWidget) && show) 
            && !(widget.view!.isEmpty && !widget.view!.actions.contains("post"))) { 
              bottomFields.add(Padding(padding: const EdgeInsets.only(bottom: 30, left: 30, right: 30), 
                  child: Container( decoration: BoxDecoration(  borderRadius: BorderRadius.circular(10), color: Theme.of(context).splashColor,
                  ), child: Padding(padding: const EdgeInsets.all(10), child: f!,)))); 
            }
          }
        }
        List<Widget> title = [];
        int len = (MediaQuery.of(context).size.width - menuSize) ~/ 20;
        title.add(Padding( padding: const EdgeInsets.only(left: 53), child: Row( 
          children: [ Flexible( 
            child: Text( (await getOnFlow(name + (len > name.length ? "" : "...").toLowerCase())),
            style: TextStyle(color: Theme.of(context).primaryColor, fontSize: widget.subForm ? 30 : 19))), ...states ])));
        if (description != "" && !description.contains("no description")) {
            title.add(Padding( padding: const EdgeInsets.only(left: 50), child: Row( 
                children: [ Padding( padding: const EdgeInsets.only(right: 10), child: Icon(Icons.description, size: 20 , color: Theme.of(context).splashColor)), 
                  Flexible( child: Text((await getOnFlow( description )).toLowerCase(), 
                    overflow: TextOverflow.ellipsis,  
                    style: const TextStyle(color: Colors.grey, fontSize: 12)))] )));
        }
        widget.cacheForm = newCacheEntry;
        List<Widget> actions = [];
        if (!widget.subForm) {
          if (widget.view != null && !widget.view!.readOnly) {
            if ((widget.view!.actions.contains("post") && widget.view!.isEmpty) || widget.view!.actions.contains("put")) {
              actions.add(ButtonWidget(method: !widget.view!.actions.contains("put") || widget.view!.isEmpty ? "post" : "put", 
                text: !widget.view!.actions.contains("put") || widget.view!.isEmpty ? TranslateConstants.submit.toUpperCase()
                : TranslateConstants.filterSave.toUpperCase(), 
                color: Theme.of(context).primaryColor));
            }
            if (widget.view!.actions.contains("delete") && !widget.view!.isEmpty) {
              actions.add(ButtonWidget(method: "delete", text: TranslateConstants.delete.toUpperCase(), color: Colors.grey));
            }
          }   
          head.add( 
            Container( width: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0, 
            height: wf == null && header.isEmpty ? 112 : ( wf != null &&  wf.currentHub ? 203 : 152),
              decoration: BoxDecoration( color: Colors.white, boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), spreadRadius: 0, blurRadius: 3, offset: const Offset(3, 3) ),
              ]), child: Stack(children: [ Padding(padding: EdgeInsets.only(top: 40, bottom: wf == null && header.isEmpty ? 25 :  0), 
                child: Column(children: [...title, ...header],)), Positioned(top: 50, right: 50, child : Row( children : actions))]), )
          );
        } else if (name != "") {
          head.add(Padding( padding: const EdgeInsets.only(left: 30, top: 20, bottom: 10),
                child: Stack( children: [ Row( children: [ Padding(padding: const EdgeInsets.only(right: 15, top: 1), 
                    child: Icon(Icons.document_scanner, color: Theme.of(context).splashColor, size: 20,)), 
                    Flexible( child: Text(
                      (await getOnFlow("${name[0].toUpperCase()}${name.substring(1).toLowerCase()}")).toLowerCase(), 
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontSize: 15))) ]),
                  fields.isEmpty ? Container() : Positioned(right: 20, top: -17.5, child: IconButton(onPressed: () => { setState(() => show = !show )}, 
                    icon: Icon(show ?  Icons.arrow_drop_down_sharp : Icons.arrow_drop_up_sharp, 
                  color: Theme.of(context).splashColor, size: 40,),
                  splashColor: Colors.transparent, highlightColor: Colors.transparent, hoverColor: Colors.transparent,))
                ])));
          head.add(Divider(thickness: 1, color: Colors.grey,));
        }
      }
      var form = Form( key: widget.formKey, 
        autovalidateMode: AutovalidateMode.always, 
        child: Wrap( 
          alignment: WrapAlignment.center,
          children: [ 
            Padding( padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30), 
              child: Container( 
                padding: EdgeInsets.only(top: widget.subForm || (!widget.subForm && isSplitted) ? 0 : 30), 
                child: Wrap( alignment: WrapAlignment.center, children : fields))
            ),
            ...bottomFields, 
            ...(isSplitted ? [] : additionnal)
          ]
        )
      );
      if (!widget.scroll) {
        return Container( margin: EdgeInsets.only(bottom: widget.subForm ? 30 : 0, top: 10,
          left: widget.subForm ? 30 : 0, right: widget.subForm ? 30 : 0,),
        decoration: BoxDecoration(boxShadow: [ 
          BoxShadow( color: Colors.grey.withOpacity(0.5), spreadRadius: 0, blurRadius: 3, offset: const Offset(0, 3))
        ],
        color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(widget.subForm ? 10 : 0),)),
        child: Column( children: [...head, fields.isEmpty ? Container() : form]));
      }
      
      Widget formWrap = Container( decoration: BoxDecoration(color: Theme.of(context).highlightColor ),
        width: ((MediaQuery.of(context).size.width - menuSize) * ratioSplit) > 0 ? 
          ((MediaQuery.of(context).size.width - menuSize) * ratioSplit) : 0,
        child: Container(
          margin: EdgeInsets.only(top: wf == null && header.isEmpty ? 112 : ( wf != null && wf.currentHub ? 200 :  152)), 
          height: MediaQuery.of(context).size.height - (wf == null && header.isEmpty ? 112 : ( wf != null && wf.currentHub ? 200 :  152)) > 0 ? 
            MediaQuery.of(context).size.height - (wf == null && header.isEmpty ? 112 : ( wf != null && wf.currentHub ? 200 :  152)) : 0,
          child: SingleChildScrollView(  scrollDirection: Axis.vertical, 
            child: isSplitted ? Wrap( alignment: WrapAlignment.center,  children: additionnal) : form)
        )
      );

      return Stack( children: [ 
        Row(children: [
          formWrap,
          ...(isSplitted ? [
            Container( 
              margin: EdgeInsets.only(top: wf == null && header.isEmpty ? 112 : ( wf != null && wf.currentHub ? 198 :  148)), 
              height: MediaQuery.of(context).size.height - (wf == null && header.isEmpty ? 182 : ( wf != null && wf.currentHub ? 260 :  210)) > 0 ? 
                MediaQuery.of(context).size.height - (wf == null && header.isEmpty ? 182 : ( wf != null && wf.currentHub ? 260 :  210)) : 0,
              decoration: BoxDecoration(color: Theme.of(context).highlightColor, 
                border: Border( left: BorderSide(color: Theme.of(context).splashColor, width: 1))),
              width: ((MediaQuery.of(context).size.width - menuSize) * (1 - ratioSplit)) > 0 ? 
                ((MediaQuery.of(context).size.width - menuSize) * (1 - ratioSplit)) : 0,
              child: SingleChildScrollView(  scrollDirection: Axis.vertical,  child : Column( children: [
                Padding( padding: const EdgeInsets.only(top: 25, bottom: 5),
                  child: Text((await getOnFlow(currentView?.schemaName.replaceAll("db", "").toUpperCase() ?? "")).toLowerCase(),
                    style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 20),
                  )), 
                Padding( padding: const EdgeInsets.only(bottom: 60), child: form)] )
            ))
          ] : [])
        ]), 
        ...head, 
        Positioned( bottom: 30, right: 0, 
          child: Container(width: (MediaQuery.of(context).size.width - menuSize) * (1 - ratioSplit), 
          alignment: Alignment.center, child: Row( mainAxisAlignment: MainAxisAlignment.center, children: positionnedBar)))
      ]);
    }
}