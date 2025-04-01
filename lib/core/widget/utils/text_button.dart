
// ignore: must_be_immutable
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class TextButtonWidget extends StatefulWidget {
  List<Widget> rows = [];
  void Function() onPressed;
  TextButtonWidget ({ 
    super.key, 
    required this.rows, 
    required this.onPressed,
  });
  @override ButtonWidgetState createState() => ButtonWidgetState();
}
class ButtonWidgetState extends State<TextButtonWidget> {
  @override Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5), 
      child: TextButton(
        onPressed: widget.onPressed,
        child: Row(children: widget.rows),  
      )
    );
  }
}