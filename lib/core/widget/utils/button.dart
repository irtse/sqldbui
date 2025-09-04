import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/services/action.dart';
import 'package:sqldbui2/page/translate.dart';

// ignore: must_be_immutable
class ButtonWidget extends StatefulWidget {
  Color color;
  String text;
  String method;
  bool explicitDraft = false; 
  bool isDraft;
  bool avoidConsent = false;
  bool noRedirection = false;
  void Function()? overrideFunc;
  IconData? icon;
  ButtonWidget ({ super.key,
    this.noRedirection = false,
    required this.text, this.icon, this.overrideFunc, this.explicitDraft =false,
    required this.method, required this.color, this.avoidConsent = false, this.isDraft = false});
  @override ButtonWidgetState createState() => ButtonWidgetState();
}
class ButtonWidgetState extends State<ButtonWidget> {
  bool states = false;
  void loading() { setState(() { states= true; });}
  void loaded() { setState(() { states= false; });}

  @override Widget build(BuildContext context) {
  return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
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
              <String>["id"], currentView!.schema, widget.method, widget.isDraft, context, {}, false, widget.explicitDraft, widget.avoidConsent, false, widget.noRedirection), 
            child: widget.icon != null ? Tooltip( message: widget.text.toLowerCase(),
              child: Icon( widget.icon, color: Colors.white)) : Text(
                (await getOnFlow(widget.text)).toUpperCase(), 
              style: TextStyle( fontSize: 12, color: Theme.of(context).highlightColor))))
            ],
    );
  }
}