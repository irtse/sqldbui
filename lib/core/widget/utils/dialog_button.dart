
// ignore: must_be_immutable
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DialogButtonWidget extends StatefulWidget {
  Widget? widget;
  String tooltip;
  IconData icon;
  double right = 0;
  double left = 0;
  bool barrierDismissible = false;
  void Function(BuildContext)? onChanged;
  DialogButtonWidget ({ 
    super.key, 
    required this.icon,
    this.widget, 
    required this.tooltip,
    this.left = 0,
    this.right = 0,
    this.onChanged,
    this.barrierDismissible = false,
  });
  @override DialogButtonWidgetState createState() => DialogButtonWidgetState();
}
class DialogButtonWidgetState extends State<DialogButtonWidget> {
  @override Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(left: widget.left, right: widget.right), 
      child: IconButton(
        icon: Icon( widget.icon, color: Colors.white ), 
          tooltip: widget.tooltip,
          onPressed: () async => widget.onChanged != null ? widget.onChanged!(context) : showDialog(
            context: context, 
            barrierDismissible: widget.barrierDismissible,
            builder: (BuildContext context) { 
              return widget.widget ?? Container(); 
            }), 
      )
    );
  }
}