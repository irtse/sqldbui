import 'package:flutter/material.dart';
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/main.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/page/translate.dart';
// ignore: must_be_immutable
class WorkflowBarWidget extends StatefulWidget{
  final model.Workflow workflow;
  const WorkflowBarWidget ({ super.key, required this.workflow, });
  @override WorkflowBarWidgetState createState() => WorkflowBarWidgetState();
}
class WorkflowBarWidgetState extends State<WorkflowBarWidget> {
  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
        if (a.hasData && a.data != null) {
          return a.data!;
        }
        return Container();
      });
  }
  Future<Widget> futureBuild(BuildContext context) async {    double max = currentWidth - menuSize > 0 ? currentWidth - menuSize : 0;
    var itemWidth = (max - 200) / widget.workflow.steps.length;
    List<Widget> items = [];
    var curr = 0;
    try { curr = int.parse(widget.workflow.current);  } catch(e) { /* */ }
    var pos = 0;
    try { pos = int.parse(widget.workflow.position);  } catch(e) { /* */ }
    if (widget.workflow.steps.isNotEmpty) {
      var active = true;
      items.add(StepWidget(content : const Icon(Icons.adjust, color: Colors.white,), 
        width: 100, gotBefore: false,
        current: widget.workflow.current != "" && curr == 0 && !widget.workflow.isClose,
        doing: widget.workflow.position != "" && pos == 0 && !widget.workflow.isClose,
        isDismissible: widget.workflow.isDismiss, 
        beforeDismissible: widget.workflow.isDismiss, 
        active: active));
    }
    for (var i = 0; i < widget.workflow.steps.length; i++) {
      var name = "${(await getOnFlow(TranslateConstants.step)).toLowerCase()} ${ i + 1 }";
      if ((widget.workflow.steps["${ i + 1 }"]?.length ?? 0) == 1) {
        name = widget.workflow.steps["${ i + 1 }"]!.first.name;
      }
      items.add(StepWidget( 
        content: Text(name, style: const TextStyle(color: Colors.white)),
        width: itemWidth, gotBefore: true, 
        steps: widget.workflow.steps.containsKey("${ i + 1 }") ? widget.workflow.steps["${ i + 1 }"] : null,
        beforeDoing: widget.workflow.position != "" && pos > ( i - 1 ),
        beforeCurrent: !widget.workflow.isClose && widget.workflow.current != "" && curr == i,
        current: widget.workflow.current != "" && curr == i + 1,
        beforeActive: widget.workflow.isClose || widget.workflow.current != "" && curr >= i + 1,
        isDismissible: widget.workflow.isDismiss || widget.workflow.currentDismiss && widget.workflow.current != "" && curr == i + 1, 
        beforeDismissible: widget.workflow.isDismiss || widget.workflow.currentDismiss && widget.workflow.current != "" && curr >= i + 1,
        doing: widget.workflow.position != "" && pos > ( i ),
        active: widget.workflow.isClose || widget.workflow.position != "" && pos > ( i + 1 )));
    }
    if (widget.workflow.steps.isNotEmpty) {
      items.add(StepWidget(
        content : Padding(padding: const EdgeInsets.only(left: 10), 
        child: Icon(widget.workflow.isDismiss ? Icons.close : Icons.check, color: Colors.white,)), width: 100, gotBefore: true, 
        beforeCurrent: widget.workflow.current != "" && curr == widget.workflow.steps.length && !widget.workflow.isClose,
        beforeDismissible: widget.workflow.isDismiss,
        isDismissible: widget.workflow.isDismiss,
        beforeActive: widget.workflow.isClose && !widget.workflow.isDismiss, 
        active: widget.workflow.isClose && !widget.workflow.isDismiss
      ));
    } else {
      items.add(SizedBox( width: currentWidth - menuSize > 0 ? currentWidth - menuSize : 0,
        child: Center(child: Text((await getOnFlow(TranslateConstants.noWorkflow)).toLowerCase(), 
          style: const TextStyle(color: Colors.white)),)));
    }
    return Container(  margin: const EdgeInsets.only(top: 25), width: max,
      height: 40, color: widget.workflow.steps.isEmpty ? Colors.grey : Colors.white,
      child: Row(children: items));
  }
}

// ignore: must_be_immutable
class StepWidget extends StatefulWidget{
  final Widget content; 
  final double width; 
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
  
  StepWidget ({ 
    super.key, 
    required this.content, 
    this.beforeDoing = false,
    required this.width, 
    this.steps, 
    required this.gotBefore,
    this.beforeActive = false, 
    this.active = false, 
    this.doing = false, 
    this.beforeCurrent = false, 
    this.current = false, 
    this.isDismissible = false, 
    this.beforeDismissible = false 
  });
  @override StepWidgetState createState() => StepWidgetState();
}
class StepWidgetState extends State<StepWidget> {

  Future<Widget> getState(model.Step step, double maxLength, List<Widget> additionnal) async {
     return SizedBox( width: maxLength * 100,
      child: Row( children : [ Padding(padding: const EdgeInsets.only(left: 20), child:  Icon(step.optionnal ? Icons.link_off : Icons.link,)), 
        Padding(padding: const EdgeInsets.only(left: 10), child: Text(await getOnFlow(step.name))), ... additionnal]),);
  }
  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    List<Widget> icons = [];
    if (widget.steps != null && widget.steps!.isNotEmpty) {
      double maxLength = 0;
      for ( var step in widget.steps!.where( (step) => step.name.length > maxLength) ) { 
        maxLength = step.name.length.toDouble();
      }
      if (widget.steps?.length == 1 && !(currentView?.isEmpty ?? true)) {
        widget.isDismissible = (widget.steps?[0].isDismiss ?? false) || widget.isDismissible;
      }
      if (!(currentView?.isEmpty ?? true)) {
        for ( var step in widget.steps! ) {
          if (step.isCurrent) {
            widget.current = true;
          }
        }
      }
      icons.add(Positioned(
        left: widget.width - 50,
        child: PopupMenuButton(
              tooltip: (await getOnFlow(TranslateConstants.showMenu)).toLowerCase(),
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
                        color: step.isDismiss ? Colors.red : Colors.green))));
                  } else if (step.isCurrent) {
                    additionnal.add(const Padding(padding: EdgeInsets.only(left: 20), child: Icon(Icons.refresh)));
                  }
                  
                  rows.add(PopupMenuItem(enabled: false, 
                  child: StatefulBuilder( builder: (BuildContext context, StateSetter s) {
                    return FutureBuilder<Widget>(future: getState(step, maxLength, additionnal), builder: (s, b) {
                      if (b.data != null) {
                        return b.data!;
                      }
                      return Container();
                    }); })));
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
                widget.beforeDismissible ? Colors.red : ( widget.beforeActive ? Colors.green : (
                   widget.beforeDoing ? Colors.orange : Colors.grey))),
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
            border: const Border(right: BorderSide(width: 2, color: Colors.white) ),
            color: widget.current ? Theme.of(context).primaryColor : (
              widget.isDismissible ? Colors.red : (widget.active ?  Colors.green : (widget.doing ? Colors.orange : Colors.grey))),
          ),
          child: Center(child: widget.content) ),
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