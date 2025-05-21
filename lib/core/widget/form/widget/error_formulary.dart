import 'package:flutter/material.dart';

GlobalKey<ErrorFormularyWidgetState> errorFormKey = GlobalKey<ErrorFormularyWidgetState>();
// ignore: must_be_immutable
class ErrorFormularyWidget extends StatefulWidget {  
  String? error;
  ErrorFormularyWidget ({ 
    this.error,
  }): super(key: errorFormKey);
  @override ErrorFormularyWidgetState createState() => ErrorFormularyWidgetState();
}
class ErrorFormularyWidgetState extends State<ErrorFormularyWidget> {
  @override Widget build(BuildContext context) {
    if ((widget.error ?? "") != "") {
      return Text(widget.error ?? "", style: TextStyle(color: Colors.red), overflow: TextOverflow.ellipsis);
    }
    return Container();
  }
}