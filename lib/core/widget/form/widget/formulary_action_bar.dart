import 'package:flutter/material.dart';
import 'package:sqldbui2/core/services/action.dart';
import 'package:sqldbui2/core/widget/dialog/confirm_box.dart';
import 'package:sqldbui2/core/widget/form/form.dart';
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
  model.Workflow? workflow;
  Map<String, dynamic> cacheForm;
  Map<String, model.SchemaField> schema;
  
  final formKey = GlobalKey<FormState>();
  FormularyActionBarWidget ({ 
    super.key, 
    required this.workflow,
    required this.cacheForm,
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
    List<Widget> positionnedBar = [];
    if (widget.view.schemaName.contains("task")) {
      var value = widget.refItem.values["state"];
      if (widget.view.actions.contains("put") && !widget.view.isEmpty && value != "completed" && value != "dismiss" && value != "refused") {
        for (var state in { "completed" : { "purpose": "validate task", "color": Colors.green, "icon": Icons.check },
                            "dismiss" :  { "purpose": "dismiss task", "color": Colors.orange, "icon": Icons.back_hand_outlined }, 
                            "refused":  { "purpose": "refused task", "color": Colors.red, "icon": Icons.close}, }.entries) {
          if ((widget.isFirst || !(widget.workflow?.isDismissable ?? true)) && state.key == "dismiss") {
            continue;
          }
          var purpose = await getOnFlow("${widget.refItem.values["override_state_${state.key}"] ?? state.value["purpose"]}");
          positionnedBar.add(Padding( padding: const EdgeInsets.only(left: 20), child: FloatingActionButton(
            tooltip: purpose.toLowerCase(),
            mini: true,
            onPressed: () {
              Map<String, dynamic> cache = { "state": state.key, "closing_comment": confirmCache?["closing_comment"] };
              showDialog(context: context, builder: (builder) => ConfirmBoxWidget(
                name: "closing_comment",
                schema: widget.schema,
                field: widget.schema["closing_comment"],
                cache: cache,

                purpose: purpose, 
                validate: () {
                  widget.component.widget.detectChange = true;
                  //mainForm.currentState!.widget.cacheForm["state"] = state.key;
                  ActionService.pressed(null, false, widget.view.schemaName, widget.view.actionPath, <String>["id"], 
                    widget.view.schema, "put", false, context, cache, true, true, state.key == "dismiss" || state.key == "refused", 
                    state.key == "dismiss" || state.key == "refused", false)();
              }));
            }, 
            backgroundColor: state.value["color"] as Color, 
            child: Icon(state.value["icon"] as IconData?, size: 18,
            color: Colors.white))));
        }
      }
      return Positioned( bottom: 30, left: 0, 
        child: Container(
          width: 180, 
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