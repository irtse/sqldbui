import 'package:flutter/material.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/widget/utils/button.dart';
import 'package:sqldbui2/model/view.dart';

import 'package:sqldbui2/core/widget/workflow/workflowPanel.dart';
import 'package:sqldbui2/core/widget/workflow/workflowbar.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/page/translate.dart';

// ignore: must_be_immutable
class FormularyHeaderWidget extends StatefulWidget {
  bool show;
  bool subForm;
  double width;
  bool canUpdate;
  model.View view;
  bool edit = false;
  model.Item refItem;
  bool onlyDraft = false;
  model.Workflow? workflow;
  Map<String, model.SchemaField> schema;
  
  final formKey = GlobalKey<FormState>();
  FormularyHeaderWidget ({ 
    super.key, 
    required this.show,
    required this.view, 
    required this.width,
    required this.schema,
    required this.refItem,
    required this.subForm, 
    required this.workflow,
    required this.onlyDraft,
    required this.canUpdate,
  });
  @override FormularyHeaderWidgetState createState() => FormularyHeaderWidgetState();
}
class FormularyHeaderWidgetState extends State<FormularyHeaderWidget> {
  String name = "Unknown Name";
  String description = "no description";
  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    try {
    List<Widget> widgets = [];
    List<Widget> states = [];
    List<Widget> title = [];    
    name = (widget.view.label ?? widget.view.name).toUpperCase().replaceAll("DB", "").replaceAll("_", " ");
    var scheme = widget.schema["name"];
    if (scheme?.translatable ?? true) {
      try {
        name = await getOnFlow(name);
      } catch(e) {}
    }
    description = widget.view.description.toLowerCase().replaceAll("db", "").replaceAll("_", " ");
    var name2 = "";
    if (widget.refItem.values.containsKey("name") && widget.refItem.values["name"] != null) { 
      name2 = widget.refItem.values["name"].toUpperCase(); 
      if (scheme?.translatable ?? true) {
        try {
          name2 = await getOnFlow(name2);
        } catch(e) {}
      } 
    }
    List<String> desc = [];
    if (widget.refItem.values.containsKey("description") && widget.refItem.values["description"] != null) { 
      description = widget.refItem.values["description"].toLowerCase(); 
      for (var d in description.split(":")) {
        try { desc.add(await getOnFlow(d));
        } catch(e) { print(e); }
      } 
    }
    if (widget.refItem.isDraft) {
      states.add(Padding(
        padding: const EdgeInsets.only(top: 3, left: 12), 
        child: Container( padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          decoration: BoxDecoration( 
            borderRadius: BorderRadius.circular(30), 
            color: Colors.grey
          ),
          child: Text((await getOnFlow(TranslateConstants.draftT)).toLowerCase(), 
            style: const TextStyle(color: Colors.white, fontSize: 10)))
        )
      );
    }
    if (widget.refItem.values["state"] != null) {
      var value = (widget.refItem.valuesShallow["state"]?.label ?? widget.refItem.valuesShallow["state"]?.name ?? widget.refItem.values["state"]).toString().replaceAll(" (pending)", "").replaceAll(" (completed)", "").replaceAll(" (refused)", "").replaceAll(" (progressing)", "");;
      states.add(Padding(
        padding: const EdgeInsets.only(top: 3, left: 12), 
        child: Container( padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          decoration: BoxDecoration( 
            borderRadius: BorderRadius.circular(30), 
            color: value == "completed" ? Colors.green : (value == "dismiss" ? Colors.red : Colors.orange)),
          child: Text((await getOnFlow(value)).toLowerCase(), style: const TextStyle(color: Colors.white, fontSize: 10)))
        )
      );
    }
    title.add(Container( 
      padding: const EdgeInsets.only(left: 53), 
      child: Row( 
        children: [ 
          Container( constraints:  BoxConstraints(maxWidth: widget.width / 2), 
          child : Text( name.toUpperCase(), overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Theme.of(context).primaryColor, 
              fontWeight: FontWeight.bold,
              fontSize: widget.subForm ? 30 : 19))), 
          /*widget.canUpdate ? Padding(
            padding: EdgeInsets.only(left: 10),
            child: InkWell( onTap: () => setState(() {
              widget.edit = !widget.edit;
            }),
              child: Icon(widget.edit ? Icons.edit_off : Icons.edit, color: Theme.of(context).primaryColor ))
          ) : Container(),*/
          ...states,

          SizedBox(  width: widget.width / 3, 
           child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [
            widget.refItem.metadata?.creationUser == "" ? Container() : Padding( padding: const EdgeInsets.only(left: 20), child: Row( 
          children: [ 
            if (widget.refItem.metadata != null)
              Text("${await getOnFlow("created : ")} ${widget.refItem.metadata!.creationDate} ${await getOnFlow("by")} ${widget.refItem.metadata!.creationUser}".toLowerCase(), 
                  overflow: TextOverflow.ellipsis,  
                  style: const TextStyle(color: Colors.grey, fontSize: 11))
            ] )),
            widget.refItem.metadata?.updateUser == "" ? Container() : Padding( padding: const EdgeInsets.only(left: 20), child: Row( 
            children: [ 
              if (widget.refItem.metadata != null)
                Text("${await getOnFlow("last update : ")} ${widget.refItem.metadata!.updateDate} ${await getOnFlow("by")} ${widget.refItem.metadata!.updateUser}".toLowerCase(), 
                    overflow: TextOverflow.ellipsis,  
                    style: const TextStyle(color: Colors.grey, fontSize: 11))
              
            ] ))
          ]))
        ])
      )
    );
    
    if (desc.isNotEmpty && !desc.contains("no description")) {
      title.add(Padding( padding: const EdgeInsets.only(left: 50), child: Row( 
        children: [ 
          Padding( 
            padding: const EdgeInsets.only(right: 10), 
            child: Icon(Icons.info_outline, size: 20 , color: Theme.of(context).splashColor)), 
          Text(desc.join(":").toLowerCase(), 
                overflow: TextOverflow.ellipsis,  
                style: const TextStyle(color: Colors.grey, fontSize: 12))
              
        ] )));
    } 
    List<Widget> actions = [];
    if (!widget.subForm) {
      if (!widget.view.readOnly) {
        if ((widget.view.actions.contains("post") && widget.view.isEmpty) || widget.view.actions.contains("put")) {
          if (widget.view.actions.contains("post") && widget.view.isEmpty ) {
            try {  TranslateConstants.draft = await getOnFlow(TranslateConstants.draft);
          } catch (e) {}
            actions.add(ButtonWidget( method: "post", 
              text: (TranslateConstants.draft).toUpperCase(), color: Colors.grey, isDraft: true, explicitDraft: true, avoidConsent: true));
          }
          try {
            TranslateConstants.publish = await getOnFlow(TranslateConstants.publish);
          } catch (e) {}
          if (widget.view.items.isNotEmpty && widget.view.items[0].isDraft) {
            actions.add(ButtonWidget(method: "put",
              text: TranslateConstants.publish.toUpperCase(), color: Colors.grey, explicitDraft: true, avoidConsent: false));
          }
          if (!widget.onlyDraft) {
            try {
              TranslateConstants.update = await getOnFlow(TranslateConstants.update);
            } catch (e) {}
            actions.add(ButtonWidget(
              method: !widget.view.actions.contains("put") || widget.view.isEmpty ? "post" : "put", 
              text: (!widget.view.actions.contains("put") || widget.view.isEmpty ? TranslateConstants.publish
                  : TranslateConstants.update).toUpperCase(), 
                  // ignore: use_build_context_synchronously
              color: Theme.of(context).primaryColor, isDraft: widget.view.items.isNotEmpty && widget.view.items[0].isDraft, 
              avoidConsent: true, noRedirection: !widget.view.isEmpty));
          }
        }
        if ((widget.view.actions.contains("delete") || widget.view.actions.contains("put") && (currentView?.schemaName ?? "" ).contains("task")) && !widget.view.isEmpty) {
          if (!((currentView?.workflow?.isClose ?? false) || (currentView?.items.first.workflow?.isClose ?? false))) {
            try {
              TranslateConstants.delete = await getOnFlow(TranslateConstants.delete);
            } catch (e) {}
            actions.add(ButtonWidget(
              method: "delete", 
              text: (TranslateConstants.delete).toUpperCase(), 
              color: Colors.red, 
              avoidConsent: true));
          }
        } 
      }   
      widgets.add( 
          Container( 
            width: widget.width, 
            height: widget.workflow == null && !widget.view.isEmpty ? 112 : (widget.workflow?.currentHub ?? false ? 203 : 152),
            decoration: BoxDecoration( 
              color: Colors.white, boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.3), spreadRadius: 0, blurRadius: 3, offset: const Offset(3, 3) ),
            ]), 
            child: Stack(children: [ 
              Padding(
                padding: EdgeInsets.only(top: 40), 
                child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [
                  SizedBox( height: 47,  child: Column( 
                    mainAxisAlignment: MainAxisAlignment.center,  children: [
                    ...title,
                  ])),
                  widget.workflow != null ? WorkflowBarWidget(workflow: widget.workflow!, width: widget.width ) 
                  : ( widget.view.isEmpty ? WorkflowBarWidget(workflow: Workflow(), width: widget.width) : Container()),
                  widget.workflow != null ?  WorkflowPanelWidget(key: globalWorkflowPanelWidgetKey, width: widget.width,
                    workflow: widget.workflow!, readOnly: widget.refItem.readonly) 
                  : ( widget.view.isEmpty ?  WorkflowPanelWidget(key: globalWorkflowPanelWidgetKey, width: widget.width,
                    workflow: Workflow(), readOnly: widget.refItem.readonly) : Container()),
                ]
              )
          ), Positioned(top: 50, right: 50, child : Row( children : actions))]), )
      );
    } else if (name != "") {
      widgets.add(Container( 
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Theme.of(context).splashColor)),
        ),
        margin: EdgeInsets.only(bottom: widget.subForm ? 20 : 0),
        padding: EdgeInsets.only(left: 30, top: 20, bottom: widget.subForm ? 10 : 0),
        child: Wrap( children: [ 
          Container(
          constraints: BoxConstraints( maxWidth:  widget.width ),
          padding: const EdgeInsets.only(right: 30), 
            // ignore: use_build_context_synchronously
          child: Row( children: [ 
            Padding(
              padding: const EdgeInsets.only(right: 15, top: 1), 
              // ignore: use_build_context_synchronously
              child: Icon(Icons.document_scanner, color: Theme.of(context).splashColor, size: 20 )
            ), 
            Text(
              name.toLowerCase(), 
              overflow: TextOverflow.ellipsis,
              // ignore: use_build_context_synchronously
              style: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontSize: 15)) 
            ]
          )),
          name2.toLowerCase() != name.toLowerCase() ? Text(
              name2.toLowerCase(), 
              overflow: TextOverflow.ellipsis,
              // ignore: use_build_context_synchronously
              style: TextStyle(color: Colors.grey, fontSize: 12)) : Container(),
      ])));
    }
    return Stack( children: widgets);
    } catch (e, s) {
        print(e);
        print(s);
        return Container();
      }
  }
}