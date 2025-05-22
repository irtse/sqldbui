// ignore: must_be_immutable
import 'package:flutter/material.dart';
import 'package:sqldbui2/page/translate.dart';

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
      child: FutureBuilder( future: getOnFlow(widget.value), builder: (a, b) { 
        if (b.data != null) {
          return Text( b.data!.toUpperCase(), overflow: TextOverflow.ellipsis, 
                   style: TextStyle(color: Theme.of(context).primaryColor, fontSize: widget.fontSize));
        }
        return Text( widget.value.toUpperCase(), overflow: TextOverflow.ellipsis, 
                   style: TextStyle(color: Theme.of(context).primaryColor, fontSize: widget.fontSize));
    }));
  }
}