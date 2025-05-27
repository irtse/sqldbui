import 'package:flutter/material.dart';
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/core/widget/utils/button.dart';
import 'package:sqldbui2/model/view.dart';

import 'package:sqldbui2/core/widget/workflow/workflowPanel.dart';
import 'package:sqldbui2/core/widget/workflow/workflowbar.dart';
import 'package:sqldbui2/main.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/page/translate.dart';

// ignore: must_be_immutable
class FormularyHeaderWidget extends StatefulWidget {
  bool show;
  bool subForm;
  bool canUpdate;
  model.View view;
  bool edit = false;
  model.Item refItem;
  model.Workflow? workflow;
  Map<String, model.SchemaField> schema;
  
  final formKey = GlobalKey<FormState>();
  FormularyHeaderWidget ({ 
    super.key, 
    required this.show,
    required this.view, 
    required this.schema,
    required this.refItem,
    required this.subForm, 
    required this.workflow,
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
    name = await getOnFlow(widget.view.name.toUpperCase().replaceAll("DB", "").replaceAll("_", " "));
    description = widget.view.description.toLowerCase().replaceAll("db", "").replaceAll("_", " ");
    if (widget.refItem.values.containsKey("name") && widget.refItem.values["name"] != null) { 
      name += ": ${await getOnFlow(widget.refItem.values["name"].toUpperCase())}"; 
    }
    if (widget.refItem.values.containsKey("description") && widget.refItem.values["description"] != null) { 
      description = widget.refItem.values["description"].toLowerCase(); 
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
      var value = widget.refItem.values["state"];
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
    title.add(Padding( padding: const EdgeInsets.only(left: 53), 
      child: Row( 
        children: [ Flexible( 
          child: Text( name.toLowerCase(), overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Theme.of(context).primaryColor, fontSize: widget.subForm ? 30 : 19))), 
          widget.canUpdate ? Padding(
            padding: EdgeInsets.only(left: 10),
            child: InkWell( onTap: () => setState(() {
              widget.edit = !widget.edit;
            }),
              child: Icon(widget.edit ? Icons.edit_off : Icons.edit, color: Theme.of(context).primaryColor ))
          ) : Container(),
          ...states 
        ])
      )
    );
    if (description != "" && !description.contains("no description")) {
      title.add(Padding( padding: const EdgeInsets.only(left: 50), child: Row( 
        children: [ 
          Padding( 
            padding: const EdgeInsets.only(right: 10), 
            child: Icon(Icons.info_outline, size: 20 , color: Theme.of(context).splashColor)), 
              Flexible( child: Text((await getOnFlow( description )).toLowerCase(), 
                overflow: TextOverflow.ellipsis,  
                style: const TextStyle(color: Colors.grey, fontSize: 12))
              )
        ] )));
    }
    List<Widget> actions = [];
    if (!widget.subForm) {
      if (!widget.view.readOnly) {
        if ((widget.view.actions.contains("post") && widget.view.isEmpty) 
        || widget.view.actions.contains("put")) {
          if (widget.view.actions.contains("post") && widget.view.isEmpty ) {
            actions.add(ButtonWidget( method: "post", 
                  text: (await getOnFlow(TranslateConstants.draft)).toUpperCase(), color: Colors.grey, isDraft: true));
          }
          if (widget.view.items.isNotEmpty && widget.view.items[0].isDraft) {
            actions.add(ButtonWidget(method: "put",
              text: TranslateConstants.publish.toUpperCase(), color: Colors.grey));
          }
          actions.add(ButtonWidget(
            method: !widget.view.actions.contains("put") || widget.view.isEmpty ? "post" : "put", 
            text: (await getOnFlow(!widget.view.actions.contains("put") || widget.view.isEmpty ? TranslateConstants.publish
                : TranslateConstants.update)).toUpperCase(), 
                // ignore: use_build_context_synchronously
            color: Theme.of(context).primaryColor, isDraft: widget.view.items.isNotEmpty && widget.view.items[0].isDraft));
        }
        if (widget.view.actions.contains("delete") && !widget.view.isEmpty) {
          actions.add(ButtonWidget(method: "delete", text: (await getOnFlow(TranslateConstants.delete)).toUpperCase(), color: Colors.red));
        }
      }   
      widgets.add( 
          Container( 
            width: currentWidth - menuSize > 0 ? currentWidth - menuSize : 0, 
            height: widget.workflow == null && !widget.view.isEmpty ? 112 : (widget.workflow?.currentHub ?? false ? 203 : 152),
            decoration: BoxDecoration( 
              color: Colors.white, boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.3), spreadRadius: 0, blurRadius: 3, offset: const Offset(3, 3) ),
            ]), 
            child: Stack(children: [ 
              Padding(
                padding: EdgeInsets.only(top: 40, bottom: widget.workflow == null && !widget.view.isEmpty ? 25 : 0), 
                child: Column(children: [
                  ...title, 
                  widget.workflow != null ? WorkflowBarWidget(workflow: widget.workflow!) 
                  : ( widget.view.isEmpty ? WorkflowBarWidget(workflow: Workflow()) : Container()),
                  widget.workflow != null ?  WorkflowPanelWidget(key: globalWorkflowPanelWidgetKey, 
                    workflow: widget.workflow!, readOnly: widget.refItem.readonly) 
                  : ( widget.view.isEmpty ?  WorkflowPanelWidget(key: globalWorkflowPanelWidgetKey, 
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
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.only(left: 30, top: 20, bottom: 20),
        child: Stack( children: [ 
          Row( children: [ 
            Padding(
              padding: const EdgeInsets.only(right: 15, top: 1), 
              // ignore: use_build_context_synchronously
              child: Icon(Icons.document_scanner, color: Theme.of(context).splashColor, size: 20 )
            ), 
            Flexible( child: Text(
              (await getOnFlow(name)).toLowerCase(), 
              overflow: TextOverflow.ellipsis,
              // ignore: use_build_context_synchronously
              style: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontSize: 15))) ]),
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