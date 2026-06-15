import 'package:flutter/material.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/widget/dialog/link_box.dart';
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

  late ThemeData _theme;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = Theme.of(context);  // ✔️ sûr ici
  }

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
    description = widget.view.description.toLowerCase().replaceAll("db", "").replaceAll("_", " ");
    var name2Raw = (widget.refItem.values.containsKey("name") && widget.refItem.values["name"] != null)
        ? widget.refItem.values["name"].toUpperCase() as String
        : null;
    if (scheme?.translatable ?? true) {
      try {
        final nameTrad = await Future.wait([
          getOnFlow(name),
          if (name2Raw != null) getOnFlow(name2Raw),
        ]);
        name = nameTrad[0];
        if (name2Raw != null) name2Raw = nameTrad[1];
      } catch(e) {}
    }
    var name2 = name2Raw ?? "";
    List<String> desc = [];
    if (widget.refItem.values.containsKey("description") && widget.refItem.values["description"] != null) {
      description = widget.refItem.values["description"].toLowerCase();
      final descParts = description.split(":");
      try {
        desc = (await Future.wait(descParts.map((d) => getOnFlow(d).catchError((_) => d)))).toList();
      } catch(e) { }
    }
    final stateValue = widget.refItem.values["state"] != null
        ? (widget.refItem.valuesShallow["state"]?.label ?? widget.refItem.valuesShallow["state"]?.name ?? widget.refItem.values["state"]).toString().replaceAll(" (pending)", "").replaceAll(" (completed)", "").replaceAll(" (refused)", "").replaceAll(" (running)", "")
        : null;
    final headerTrad = await Future.wait([
      getOnFlow(TranslateConstants.draftT),
      getOnFlow("created : "),
      getOnFlow("by"),
      getOnFlow("last update : "),
      if (stateValue != null) getOnFlow(stateValue),
    ]);
    if (widget.refItem.isDraft) {
      states.add(Padding(
        padding: const EdgeInsets.only(top: 3, left: 12),
        child: Container( padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.grey
          ),
          child: Text(headerTrad[0].toLowerCase(),
            style: const TextStyle(color: Colors.white, fontSize: 10)))
        )
      );
    }
    if (stateValue != null) {
      states.add(Padding(
        padding: const EdgeInsets.only(top: 3, left: 12),
        child: Container( padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: stateValue == "completed" ? Colors.green : (stateValue == "dismiss" ? Colors.red : Colors.orange)),
          child: Text(headerTrad[4].toLowerCase(), style: const TextStyle(color: Colors.white, fontSize: 10)))
        )
      );
    }
    final metaTrad = [headerTrad[1], headerTrad[2], headerTrad[3]];
    title.add(Container(
      padding: const EdgeInsets.only(left: 53),
      child: Row(
        children: [
           if (widget.refItem.sharedTo.isNotEmpty)
            Padding(  padding: const EdgeInsets.only(right: 10),
              child: FutureBuilder(future: getOnFlow("shared to "), builder: (a,s) {
                if (s.data != null) {
                   return Tooltip( message: "${s.data} ${widget.refItem.sharedTo.join(",")}", child: Icon(Icons.share, size: 18, color: Theme.of(context).primaryColor));
                }
                return  Tooltip( message: widget.refItem.sharedTo.join(","), child: Icon(Icons.share, size: 18, color: Theme.of(context).primaryColor));
              })),
          if (widget.refItem.sharedBy.isNotEmpty)
            Padding(  padding: const EdgeInsets.only(right: 10),
              child: FutureBuilder(future: getOnFlow("shared by "), builder: (a,s) {
                if (s.data != null) {
                   return Tooltip( message: "${s.data} ${widget.refItem.sharedBy.join(",")}", child: Icon(Icons.share, size: 18, color: Colors.grey));
                }
                return  Tooltip( message: widget.refItem.sharedBy.join(","), child: Icon(Icons.share, size: 18, color: Colors.grey));
              })),
          Container( constraints:  BoxConstraints(maxWidth: widget.width / 2),
          child : Text( name.toUpperCase(), overflow: TextOverflow.ellipsis,
            style: TextStyle(color: _theme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: widget.subForm ? 30 : 19))),
          /*widget.canUpdate ? Padding(
            padding: EdgeInsets.only(left: 10),
            child: InkWell( onTap: () => setState(() {
              widget.edit = !widget.edit;
            }),
              child: Icon(widget.edit ? Icons.edit_off : Icons.edit, color: _theme.primaryColor ))
          ) : Container(),*/
          ...states,
          if (!widget.view.isEmpty)
            SizedBox(  width: widget.width / 3,
            child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [
              widget.refItem.metadata?.creationUser == "" ? Container() : Padding( padding: const EdgeInsets.only(left: 20), child: Row(
            children: [
              if (widget.refItem.metadata != null)
                Text("${metaTrad[0]} ${widget.refItem.metadata!.creationDate} ${metaTrad[1]} ${widget.refItem.metadata!.creationUser}".toLowerCase(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 11))
              ] )),
              widget.refItem.metadata?.updateUser == "" ? Container()
              : Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  children: [
                    if (widget.refItem.metadata != null)
                      Text("${metaTrad[2]} ${widget.refItem.metadata!.updateDate} ${metaTrad[1]} ${widget.refItem.metadata!.updateUser}".toLowerCase(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey, fontSize: 11))

                  ]
                )
              )
            ]))
        ])
      )
    );
    
    if (desc.isNotEmpty && !desc.contains("no description")) {
      title.add(Padding( padding: const EdgeInsets.only(left: 50), child: Row( 
        children: [ 
          Padding( 
            padding: const EdgeInsets.only(right: 10), 
            child: Icon(Icons.info_outline, size: 15, color: _theme.splashColor)), 
          Text(desc.join(":").toLowerCase(), 
                overflow: TextOverflow.ellipsis,  
                style: const TextStyle(color: Colors.grey, fontSize: 10))
              
        ] )));
    } 
    try {
      final actionTrad = await Future.wait([
        getOnFlow(TranslateConstants.draft),
        getOnFlow(TranslateConstants.publish),
        getOnFlow(TranslateConstants.update),
        getOnFlow(TranslateConstants.delete),
      ]);
      TranslateConstants.draft = actionTrad[0];
      TranslateConstants.publish = actionTrad[1];
      TranslateConstants.update = actionTrad[2];
      TranslateConstants.delete = actionTrad[3];
    } catch (e) {}
    List<Widget> actions = [];
    if (!widget.subForm) {
      if (!widget.view.readOnly) {
        if ((widget.view.actions.contains("post") && widget.view.isEmpty) || widget.view.actions.contains("put")) {
          if (widget.view.actions.contains("post") && widget.view.isEmpty ) {
            actions.add(ButtonWidget( method: "post",
              text: (TranslateConstants.draft).toUpperCase(), color: Colors.grey, isDraft: true, explicitDraft: true, avoidConsent: true));
          }
          if (widget.view.items.isNotEmpty && widget.view.items[0].isDraft) {
            actions.add(ButtonWidget(method: "put",
              text: TranslateConstants.publish.toUpperCase(), color: Colors.grey, explicitDraft: true, avoidConsent: false));
          }
          if (!widget.onlyDraft) {
            actions.add(ButtonWidget(
              method: !widget.view.actions.contains("put") || widget.view.isEmpty ? "post" : "put",
              text: (!widget.view.actions.contains("put") || widget.view.isEmpty ? TranslateConstants.publish
                  : TranslateConstants.update).toUpperCase(),
                  // ignore: use_build_context_synchronously
              color: _theme.primaryColor, isDraft: widget.view.items.isNotEmpty && widget.view.items[0].isDraft,
              avoidConsent: !(!widget.view.actions.contains("put") || widget.view.isEmpty), noRedirection: !widget.view.isEmpty));
          }
        }
        if ((widget.view.actions.contains("delete") || widget.view.actions.contains("put") && (currentView?.schemaName ?? "" ).contains("task")) && !widget.view.isEmpty) {
          if (!((currentView?.workflow?.isClose ?? false) || (currentView?.items.first.workflow?.isClose ?? false))) {
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
          
          border: Border(bottom: BorderSide(color: _theme.splashColor)),
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
              child: Icon(Icons.document_scanner, color: _theme.splashColor, size: 20 )
            ), 
            Container(
          constraints: BoxConstraints( maxWidth:  widget.width / 3.5),
            // ignore: use_build_context_synchronously
          child:Text(
              name.toLowerCase(), 
              overflow: TextOverflow.ellipsis,
              // ignore: use_build_context_synchronously
              style: TextStyle(color: _theme.secondaryHeaderColor, fontSize: 15))),
              if (widget.refItem.sharing != null)
                LinkBoxWidget(
                        isDelete: false,
                        color: Colors.grey,
                        path: "@${widget.view.schemaID}:${widget.view.id}",
                        sharing: widget.refItem.sharing,
                      ),
              if (widget.refItem.sharing != null)
                LinkBoxWidget(
                        isDelete: true,
                        color: Colors.grey,
                        path: "@${widget.view.schemaID}:${widget.view.id}",
                        sharing: widget.refItem.sharing,
                      ),
              
            ]
          )),
          Row( children: [
            if (widget.refItem.sharedTo.isNotEmpty)
            Padding(  padding: const EdgeInsets.only(right: 10), 
              child: FutureBuilder(future: getOnFlow("shared to "), builder: (a,s) {
                if (s.data != null) {
                   return Tooltip( message: "${s.data} ${widget.refItem.sharedTo.join(",")}", child: Icon(Icons.share, size: 18, color: Theme.of(context).primaryColor));
                }
                return  Tooltip( message: widget.refItem.sharedTo.join(","), child: Icon(Icons.share, size: 18, color: Theme.of(context).primaryColor));
              })),
          if (widget.refItem.sharedBy.isNotEmpty)
            Padding(  padding: const EdgeInsets.only(right: 10), 
              child: FutureBuilder(future: getOnFlow("shared by "), builder: (a,s) {
                if (s.data != null) {
                   return Tooltip( message: "${s.data} ${widget.refItem.sharedBy.join(",")}", child: Icon(Icons.share, size: 12, color: Colors.grey)); 
                }
                return  Tooltip( message: widget.refItem.sharedBy.join(","), child: Icon(Icons.share, size: 12, color: Colors.grey));
              })),
             name2.toLowerCase() != name.toLowerCase() ? Text(
                name2.toLowerCase(), 
                overflow: TextOverflow.ellipsis,
                // ignore: use_build_context_synchronously
                style: TextStyle(color: Colors.grey, fontSize: 12)) : Container(),
          ]),
      ])));
    }
    return Stack( children: widgets);
    } catch (e) {
        return Container();
      }
  }
}