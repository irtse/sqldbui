import 'package:flutter/material.dart';

Map<GlobalKey<FormState>, GlobalKey<ErrorFormularyWidgetState>> errorFormKey = {};
// ignore: must_be_immutable
class ErrorFormularyWidget extends StatefulWidget {  
  String? error;
  ErrorFormularyWidget ({ 
    super.key,
    this.error,
  });
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