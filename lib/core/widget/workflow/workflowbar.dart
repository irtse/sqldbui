import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:sqldbui2/core/sections/menu.dart';
import 'package:sqldbui2/model/view.dart' as model;
// ignore: must_be_immutable
class WorkflowBarWidget extends StatefulWidget{
  final model.Workflow workflow;
  const WorkflowBarWidget ({ Key? key, required this.workflow, }): super(key: key);
  @override WorkflowBarWidgetState createState() => WorkflowBarWidgetState();
}
class WorkflowBarWidgetState extends State<WorkflowBarWidget> {
  @override Widget build(BuildContext context) {
    double max = MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0;
    var itemWidth = (max - 200) / widget.workflow.steps.length;
    List<Widget> items = [];
    var curr = 0;
    try { curr = int.parse(widget.workflow.current);  } catch(e) { /* */ }
    var pos = 0;
    try { pos = int.parse(widget.workflow.position);  } catch(e) { /* */ }
    if (widget.workflow.steps.isNotEmpty) {
      var active = false;
      try { active = widget.workflow.position != "" && int.parse(widget.workflow.position) >= 0;  } catch(e) { /* */ }
      items.add(StepWidget(content : const Icon(Icons.adjust, color: Colors.white,), 
        width: 100, gotBefore: false,
        current: widget.workflow.current != "" && curr == 0,
        doing: widget.workflow.position != "" && pos == 0,
        isDismissible: widget.workflow.isDismiss, beforeDismissible: widget.workflow.isDismiss, 
        active: active));
    }
    for (var i = 0; i < widget.workflow.steps.length; i++) {
      items.add(StepWidget( content: Text("step ${ i + 1 }", style: const TextStyle(color: Colors.white)),
        width: itemWidth, gotBefore: true, 
        steps: widget.workflow.steps.containsKey("${ i + 1 }") ? widget.workflow.steps["${ i + 1 }"] : null,
        beforeDoing: widget.workflow.position != "" && pos > ( i - 1 ),
        beforeCurrent: !widget.workflow.isClose && widget.workflow.current != "" && curr == i,
        current: widget.workflow.current != "" && curr == i + 1 && !widget.workflow.isClose,
        beforeActive: widget.workflow.isClose || widget.workflow.current != "" && curr >= i + 1,
        isDismissible: widget.workflow.isDismiss || widget.workflow.currentDismiss && widget.workflow.current != "" && curr == i + 1, 
        beforeDismissible: widget.workflow.isDismiss || widget.workflow.currentDismiss && widget.workflow.current != "" && curr >= i + 1,
        doing: widget.workflow.position != "" && pos > ( i ),
        active: widget.workflow.isClose || widget.workflow.position != "" && pos > ( i + 1 )));
    }
    if (widget.workflow.steps.isNotEmpty) {
      items.add(StepWidget(content : Padding(padding: const EdgeInsets.only(left: 10), 
      child:Icon(widget.workflow.isDismiss ? Icons.close : Icons.check, color: Colors.white,)), width: 100, gotBefore: true, 
      beforeCurrent: widget.workflow.current != "" && curr == widget.workflow.steps.length && !widget.workflow.isClose,
      beforeDismissible: widget.workflow.isDismiss,
      isDismissible: widget.workflow.isDismiss,
      beforeActive: widget.workflow.isClose && !widget.workflow.isDismiss, 
      active: widget.workflow.isClose && !widget.workflow.isDismiss));
    } else {
      items.add(SizedBox( width: MediaQuery.of(context).size.width - menuSize > 0 ? MediaQuery.of(context).size.width - menuSize : 0,
        child: Center(child: Text("no workflow related !", style: const TextStyle(color: Colors.white)),)));
    }
    return Container(  margin: const EdgeInsets.only(top: 25), width: max,
      height: 40, color: widget.workflow.steps.isEmpty ? Theme.of(context).splashColor : Colors.white,
      child: Row(children: items,),);
  }
}

// ignore: must_be_immutable
class StepWidget extends StatefulWidget{
  final Widget content; final double width; 
  final bool gotBefore;
  bool beforeDoing = false;
  bool beforeActive = false;
  bool active = false;

  bool beforeCurrent = false;
  bool current = false;
  bool beforeDismissible = false;
  bool isDismissible = false;
  bool doing = false;
  List<model.Step>? steps = [];
  StepWidget ({ Key? key, required this.content, this.beforeDoing = false,
    required this.width, this.steps, required this.gotBefore,
    this.beforeActive = false, this.active = false, this.doing = false, this.beforeCurrent = false, this.current = false, 
    this.isDismissible = false, this.beforeDismissible = false }): super(key: key);
  @override StepWidgetState createState() => StepWidgetState();
}
class StepWidgetState extends State<StepWidget> {
  @override Widget build(BuildContext context) {
    List<Widget> icons = [];
    if (widget.steps != null && widget.steps!.isNotEmpty) {
      double maxLength = 0;
      for ( var step in widget.steps!.where( (step) => step.name.length > maxLength) ) { 
        maxLength = step.name.length.toDouble();
      }
      icons.add(Positioned(
        left: widget.width - 50,
        child: PopupMenuButton(
              constraints: BoxConstraints(maxWidth: maxLength * 15,),
              color: Colors.white,
              icon: const Icon(Icons.menu, color: Colors.white, size: 20,),
              onSelected: (value) { },
              itemBuilder: (BuildContext bc) {
                List<PopupMenuItem> rows = [];
                for ( var step in widget.steps! ) {
                  List<Widget> additionnal = [];
                  if (step.isClose) {
                    additionnal.add(Padding(padding: const EdgeInsets.only(left: 20), 
                      child: Transform.rotate( angle: step.isDismiss ? 0.7854 : 0, // 45 degrees in radians
                    child:  Icon(step.isDismiss ? Icons.control_point : Icons.check_circle_outline, 
                        color: step.isDismiss ? Colors.red : Colors.green,))));
                  } else if (step.isCurrent) {
                    additionnal.add(const Padding(padding: EdgeInsets.only(left: 20), child: Icon(Icons.refresh)));
                  }
                  rows.add(PopupMenuItem(enabled: false, 
                  child: StatefulBuilder( builder: (BuildContext context, StateSetter setState) {
                    return SizedBox(
                    width: maxLength * 100,
                    child: Row( children : [ Padding(padding: const EdgeInsets.only(left: 20), child:  Icon(step.optionnal ? Icons.link_off : Icons.link,)), 
                      Padding(padding: const EdgeInsets.only(left: 10), child: Text(step.name)), ... additionnal]),); })));
                }
                return rows; 
            })));
    }
    if (widget.gotBefore) {
      icons.addAll([Positioned(
        child: RotatedBox( quarterTurns: 3,
          child: ClipPath(
            clipper: TriangleClipper(),
            child: Container(
              color: Colors.white,
              height: 20,
              width: 40,
            ),
          ))),
      Positioned(
        top: 5,
        left: 1,
        child: RotatedBox( quarterTurns: 3,
          child: ClipPath(
            clipper: TriangleClipper(),
            child: Container(
              color: widget.beforeCurrent ? Theme.of(context).primaryColor : ( 
                widget.beforeDismissible ? Colors.red : ( widget.beforeDoing ? Colors.orange : (
                   widget.beforeActive ? Colors.green : Theme.of(context).splashColor))),
              height: 14,
              width: 30,
            ),
          ))) ]);
    }
    return Stack( 
      children : [
      Container(
          width: widget.width,
          height: 40,
          decoration: BoxDecoration(
            border: const Border(right: BorderSide(width: 2, color: Colors.white),),
            color: widget.current ? Theme.of(context).primaryColor : (
              widget.isDismissible ? Colors.red : (
                 widget.active ?  Colors.green : (widget.doing ? Colors.orange : Theme.of(context).splashColor))),
          ),
          child: Center(child: widget.content,), ),
      ...icons,
    ]);
  }
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, 0.0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(TriangleClipper oldClipper) => false;
}