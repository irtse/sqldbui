import 'package:flutter/material.dart';
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/core/services/action.dart';
import 'package:sqldbui2/core/widget/dialog/confirm_box.dart';
import 'package:sqldbui2/core/widget/form/form.dart';
import 'package:sqldbui2/main.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/page/translate.dart';

// ignore: must_be_immutable
class FormularyActionBarWidget extends StatefulWidget {
  bool show;
  bool isSplitted;
  model.View view;
  model.Item refItem;
  bool isFirst = false;
  FormWidgetState component;
  Map<String, model.SchemaField> schema;
  
  final formKey = GlobalKey<FormState>();
  FormularyActionBarWidget ({ 
    super.key, 
    required this.show,
    required this.view, 
    required this.schema,
    this.isFirst = false,
    required this.refItem,
    required this.component,
    required this.isSplitted,
  });
  @override FormularyActionBarWidgetState createState() => FormularyActionBarWidgetState();
}
class FormularyActionBarWidgetState extends State<FormularyActionBarWidget> {
  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    double ratioSplit = widget.isSplitted ? 0.7 : 1;
    List<Widget> positionnedBar = [];
    if (widget.refItem.values["state"] != null) {
      var value = widget.refItem.values["state"];
      if (widget.view.actions.contains("put") && !widget.view.isEmpty && value != "completed" && value != "dismiss" && value != "refused") {
        for (var state in { "completed" : { "purpose": "validate task", "color": Colors.green, "icon": Icons.check },
                            "dismiss" :  { "purpose": "dismiss task", "color": Colors.orange, "icon": Icons.back_hand_outlined }, 
                            "refused":  { "purpose": "refused task", "color": Colors.red, "icon": Icons.close}, }.entries) {
          if (widget.isFirst && state.key == "dismiss") {
            continue;
          }
          var purpose = await getOnFlow("${state.value["purpose"]}");
          positionnedBar.add(Padding( padding: const EdgeInsets.only(left: 20), child: FloatingActionButton(
            tooltip: purpose.toLowerCase(),
            onPressed: () {
              showDialog(context: context, builder: (builder) => ConfirmBoxWidget(
                purpose: purpose, 
                validate: () {
                  widget.component.widget.detectChange = true;
                  mainForm.currentState!.widget.cacheForm["state"] = state.key;
                  ActionService.pressed(null, false, widget.view.schemaName, widget.view.actionPath, <String>["id"], 
                    widget.view.schema, "put", false, context, { "state": state.key, }, true, false, state.key == "dismiss" || state.key == "refused")();
              }));
            }, 
            backgroundColor: state.value["color"] as Color, child: Icon(state.value["icon"] as IconData?, color: Colors.white))));
        }
      }
      return Positioned( bottom: 30, right: 0, 
        child: Container(
          width: (currentWidth - menuSize) * (1 - ratioSplit), 
          alignment: Alignment.center, 
          child: Row( 
            mainAxisAlignment: MainAxisAlignment.center, 
            children: positionnedBar
          )
      ));
    }
    return Container();
  }
}