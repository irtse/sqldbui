import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/widget/form/form.dart';
import 'package:sqldbui2/core/widget/form/widget/empty_formulary.dart';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:sqldbui2/page/translate.dart';

// ignore: must_be_immutable
class SubFormularyWidget extends StatefulWidget {  
  bool isEmpty = false;
  model.Item item;
  String relatedDatas;
  DataFormWidget component;
  SubFormularyWidget ({ 
    super.key, 
    required this.item,
    required this.isEmpty,
    required this.component,
    required this.relatedDatas,
  });
  @override SubFormularyWidgetState createState() => SubFormularyWidgetState();
}
class SubFormularyWidgetState extends State<SubFormularyWidget> {
  Map<String, String> wrappersURL = <String, String>{};

  @override Widget build(BuildContext context) {
    print("SUB");
    if (wrappersURL.isEmpty && widget.isEmpty && !widget.component.subForm) {
      return EmptyFormularyWidget();
    }
    if (widget.relatedDatas != "") { wrappersURL["relatedDatas"] = widget.relatedDatas; }

    List<Widget> additionnal = [];
    for (var url in wrappersURL.values) {
          Widget w = FutureBuilder<APIResponse<model.View>>(
              future: APIService().get<model.View>(url, firstAPI, null), 
              builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.View>> snap) {
                if (snap.hasData && snap.data!.data != null && snap.data!.data!.isNotEmpty) {
                  for (var data in snap.data!.data!) {
                    if (data.workflow != null && widget.component.reloadWorkflow && !widget.component.subForm ) { 
                      widget.component.reloadWorkflow = false;
                      Future.delayed(const Duration(seconds: 1), () { widget.component.headerKey.currentState?.setState(() { 
                        widget.component.headerKey.currentState?.widget.workflow = data.workflow; 
                      }); } );
                    }
                    var newView = model.View(
                      name: TranslateConstants.dataFormulary,
                      workflow: data.workflow,
                      linkPath: data.linkPath, schema: data.schema, order: data.order, 
                      actionPath: data.actionPath.contains(data.schemaName) ? data.actionPath : data.linkPath,
                      actions: data.actions, 
                      readOnly: data.readOnly, 
                      schemaName: data.schemaName, 
                      consents: data.consents,
                      items: data.items.isNotEmpty && !widget.component.view!.isEmpty ? data.items : <model.Item>[model.Item()] 
                    );
                    newView.isEmpty = widget.component.view!.isEmpty;
                    GlobalKey<SubFormularyWidgetState> newViewKey = GlobalKey<SubFormularyWidgetState>();
                    var w = DataFormWidget(key: newViewKey, view: newView, scroll: false, isSplitted: false, 
                                           subForm: true, subSubForm: widget.component.subForm);
                    widget.component.wrappersGlobalKey.add(newViewKey);
                    widget.component.wrappers.add(w);
                    return w;
                  }
                }
                return Container();
              }
          );
          additionnal.add(Container( 
              decoration: !widget.component.subForm  ? BoxDecoration(borderRadius: BorderRadius.circular(10)) : null,
              width: currentWidth - menuSize - 80 > 0 ? currentWidth - menuSize - 80 : 0,
              child: Padding( padding: const EdgeInsets.only(bottom: 30), child: w)));
    }  
    return Column( children: additionnal);   
  }
}