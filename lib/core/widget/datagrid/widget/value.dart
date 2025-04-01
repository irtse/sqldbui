// ignore: must_be_immutable
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class GridValueWidget extends StatefulWidget {
  double fontSize; String value; IconData? icon;
  GridValueWidget ({ super.key, required this.fontSize, this.value = " ", this.icon });
  @override
  GridValueWidgetState createState() => GridValueWidgetState();
}
class GridValueWidgetState extends State<GridValueWidget> {
  @override Widget build(BuildContext context) {
    return widget.value == " " && widget.icon != null ? FittedBox(fit: BoxFit.fitWidth, 
      child: Icon(widget.icon, size: widget.fontSize * 1.5, color: Theme.of(context).primaryColor,))
    : Container( alignment: Alignment.center,
      child: Text( widget.value.toUpperCase(), overflow: TextOverflow.ellipsis, 
                   style: TextStyle(color: Theme.of(context).primaryColor, fontSize: widget.fontSize)));
  }
}