import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:sqldbui2/core/sections/menu.dart';
import 'package:sqldbui2/model/view.dart' as model;
class WorkflowPanelWidget extends StatefulWidget {
  final model.Workflow workflow;
  final bool readOnly;
  const WorkflowPanelWidget ({ Key? key, required this.workflow, this.readOnly = false }): super(key: key);
  @override WorkflowPanelWidgetState createState() => WorkflowPanelWidgetState();
}
GlobalKey<WorkflowPanelWidgetState> globalWorkflowPanelWidgetKey = GlobalKey<WorkflowPanelWidgetState>();
class WorkflowPanelWidgetState extends State<WorkflowPanelWidget> {
  bool change = false;
  Map<String, ValueNotifier<bool>> hubs = {};
  @override Widget build(BuildContext context) {
    List<Widget> items = [];
    if (widget.workflow.currentHub && widget.workflow.steps.containsKey(widget.workflow.current)) {
      try {
        for(var hub in widget.workflow.steps["${int.parse(widget.workflow.current) + 1}"]!) {
          if (hub.workflow == null) { continue; }
          hubs[hub.workflow!.id] = ValueNotifier<bool>(hub.isSet);
          items.add(
            Padding( padding: const EdgeInsets.symmetric(horizontal: 5), child: AdvancedSwitch(
              initialValue: hub.isSet,
              controller: hubs[hub.workflow!.id],
              enabled: hub.optionnal && !widget.readOnly,
              activeColor: Colors.green,
              inactiveColor: Colors.grey,
              activeChild: Text(hub.name),
              inactiveChild: Text(hub.name), 
              borderRadius:  const BorderRadius.all(Radius.circular(15)),
              width: hub.name.length * 10,
              height: 30.0,
              disabledOpacity: 0.5,
              onChanged: (value) => change = true,
            )));
      }
      return Container( width: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0, decoration: BoxDecoration(color: Theme.of(context).splashColor,
          border: const Border(top: BorderSide(color: Colors.white, width: 1))),
        padding: const EdgeInsets.all(10), child: 
            Wrap(alignment: WrapAlignment.center, 
            children: [
              const Padding( padding: EdgeInsets.only(right: 10, top: 5), child: Icon(Icons.account_tree, color: Colors.grey)),
              const Padding( padding: EdgeInsets.only(right: 20, top: 5), child: Text("next optionnal steps:", style: TextStyle(color: Colors.grey, fontSize: 15))), ...items]));
      } catch(e) { /* empty */ } 
    }
    return Container(width: 0,);
  }
}