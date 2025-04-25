
import 'package:flutter/material.dart';
import 'package:sqldbui2/main.dart';

// ignore: must_be_immutable
class PopupButtonWidget extends StatefulWidget {
  double? width; 
  Color? color;
  String tooltip;
  IconData icon;
  Widget widget;

  PopupButtonWidget ({ 
    super.key,
    required this.tooltip,
    required this.icon,
    required this.widget,
    this.color,
    this.width
  });
  @override
  PopupButtonWidgetState createState() => PopupButtonWidgetState();
}
class PopupButtonWidgetState extends State<PopupButtonWidget> {
  bool change = false;

  @override Widget build(BuildContext context) {
    return PopupMenuButton(
      constraints: BoxConstraints.tightFor( width: widget.width ?? currentWidth / 1.1),
      color: widget.color ?? Theme.of(context).secondaryHeaderColor, 
      padding: const EdgeInsets.all(0),
      tooltip: widget.tooltip,
      icon: Icon(widget.icon, 
        size: 20, 
        color: Theme.of(context).highlightColor
      ), 
      splashRadius: 1,
      onSelected: (value) { },
      itemBuilder: (BuildContext bc) {
        return [ 
          PopupMenuItem(enabled: false, child: StatefulBuilder(  builder: (BuildContext context, StateSetter setState) {
            return widget.widget; 
          })) 
        ]; 
      }
    );
  }
}