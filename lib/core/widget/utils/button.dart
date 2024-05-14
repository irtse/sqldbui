import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/services/action.dart';
import 'package:sqldbui2/core/widget/actionbar.dart';

class ButtonWidget extends StatefulWidget {
  Color color;
  String text;
  String method;
  ButtonWidget ({ Key? key, required this.text, required this.method, required this.color}): super(key: key);
  @override ButtonWidgetState createState() => ButtonWidgetState();
}
class ButtonWidgetState extends State<ButtonWidget> {
  bool states = false;
  void loading() { setState(() { states= true; });}
  void loaded() { setState(() { states= false; });}

  @override Widget build(BuildContext context) {
    if (states) {
            return Column(children: [Padding( padding: const EdgeInsets.only(left: 5, right: 5), child: TextButton(
                style: ButtonStyle(  
                  padding: MaterialStateProperty.resolveWith((states) => EdgeInsets.symmetric(horizontal: widget.text.length * 10, vertical: 15)),
                  backgroundColor: MaterialStateColor.resolveWith((states) => Colors.green) ,
                  overlayColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.pressed)) { return Colors.green; }
                  return Colors.green;
                }), ), onPressed: (){}, child: const SpinKitCircle(color: Colors.white, size: 15.0,))),],
              );
    }
    return Column(children: [Padding( padding: const EdgeInsets.only(left: 5, right: 5), child: TextButton(
                style: ButtonStyle(  
                  padding: MaterialStateProperty.resolveWith((states) => const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                  backgroundColor: MaterialStateColor.resolveWith((states) => widget.color) ,
                  overlayColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.pressed)) { return Colors.green; }
                  return Theme.of(context).primaryColor;
                }), ), onPressed: ActionService.pressed(this, false, currentView!.schemaName,  currentView!.actionPath, 
                  <String>["id"], currentView!.schema, widget.method, context), child: Text(widget.text, style: TextStyle( fontSize: 12, color: Theme.of(context).highlightColor)))),],
              );
  }
}