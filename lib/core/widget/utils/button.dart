import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/services/action.dart';

// ignore: must_be_immutable
class ButtonWidget extends StatefulWidget {
  Color color;
  String text;
  String method;
  bool explicitDraft = false; 
  bool isDraft;
  void Function()? overrideFunc;
  IconData? icon;
  ButtonWidget ({ super.key, required this.text, this.icon, this.overrideFunc, this.explicitDraft =false,
    required this.method, required this.color, this.isDraft = false});
  @override ButtonWidgetState createState() => ButtonWidgetState();
}
class ButtonWidgetState extends State<ButtonWidget> {
  bool states = false;
  void loading() { setState(() { states= true; });}
  void loaded() { setState(() { states= false; });}

  @override Widget build(BuildContext context) {
    if (states) {
      return Column(children: [
        Padding( padding: const EdgeInsets.only(left: 5, right: 5), 
          child: TextButton(
            style: ButtonStyle( 
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5), // Change this value
              )), 
              padding: WidgetStateProperty.resolveWith((states) => EdgeInsets.symmetric(horizontal: 30, vertical: widget.icon != null ? 10 : 15)),
              backgroundColor: WidgetStateProperty.resolveWith((states) => Colors.green) ,
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed)) { return Colors.green; }
                return Colors.green;
              })
            ), 
            onPressed: (){}, 
            child: const SpinKitCircle(color: Colors.white, size: 20.0)))
        ],
      );
    }
    return Column(children: [
      Padding( padding: const EdgeInsets.only(left: 5, right: 5), 
        child: TextButton(
          style: ButtonStyle(  
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5), // Change this value
            )),
            padding: WidgetStateProperty.resolveWith((states) => EdgeInsets.symmetric(horizontal: 30, vertical: widget.icon != null ? 10 : 15)),
            backgroundColor: WidgetStateProperty.resolveWith((states) => widget.color) ,
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) { return Colors.green; }
                return Theme.of(context).primaryColor;
              })),
            onPressed: widget.overrideFunc ?? ActionService.pressed(
              this, false, currentView!.schemaName,  currentView!.actionPath, 
              <String>["id"], currentView!.schema, widget.method, widget.isDraft, context, {}, false, widget.explicitDraft), 
            child: widget.icon != null ? Tooltip( message: widget.text.toLowerCase(),
              child: Icon( widget.icon, color: Colors.white)) : Text(widget.text.toUpperCase(), 
              style: TextStyle( fontSize: 12, color: Theme.of(context).highlightColor)))),],
    );
  }
}