import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/page/translate.dart';

// ignore: must_be_immutable
class WorkflowPanelWidget extends StatefulWidget {
  final model.Workflow workflow;
  final bool readOnly;
  double width;
  WorkflowPanelWidget ({ super.key, required this.width, required this.workflow, this.readOnly = false });
  @override WorkflowPanelWidgetState createState() => WorkflowPanelWidgetState();
}
GlobalKey<WorkflowPanelWidgetState> globalWorkflowPanelWidgetKey = GlobalKey<WorkflowPanelWidgetState>();
class WorkflowPanelWidgetState extends State<WorkflowPanelWidget> {
  bool change = false;
  Map<String, ValueNotifier<bool>> hubs = {};
  @override Widget build(BuildContext context) {
  return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
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
      return Container( width: widget.width, decoration: BoxDecoration(color: Theme.of(context).splashColor,
          border: const Border(top: BorderSide(color: Colors.white, width: 1))),
        padding: const EdgeInsets.all(10), child: 
            Wrap(alignment: WrapAlignment.center, 
            children: [
              const Padding( padding: EdgeInsets.only(right: 10, top: 5), child: Icon(Icons.account_tree, color: Colors.grey)),
              Padding( padding: EdgeInsets.only(right: 20, top: 5), 
                child: Text((await getOnFlow(TranslateConstants.nextOpt)).toLowerCase(), style: TextStyle(color: Colors.grey, fontSize: 15))), ...items]));
      } catch(e) { /* empty */ } 
    }
    return Container(width: 0);
  }
}