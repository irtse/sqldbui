import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ignore: must_be_immutable
class ConfirmBoxWidget extends StatefulWidget {
  String purpose = ""; 
  Function validate = () {};
  ConfirmBoxWidget ({ super.key, required this.purpose, required this.validate });
  @override ConfirmBoxWidgetState createState() => ConfirmBoxWidgetState();
}
class ConfirmBoxWidgetState extends State<ConfirmBoxWidget> {
  @override Widget build(BuildContext context) {
    return AlertDialog(
        content: Padding(padding: EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Center(child: Padding( padding: EdgeInsets.only(bottom: 10), 
        child: Icon(Icons.help_outline_outlined, size: 80, color: Colors.grey,))),
      Center(child: Text("Are you sure ?", style: TextStyle(fontSize: 25, color: Theme.of(context).primaryColor),)),
      Center(child: Text("Do you really want to ${widget.purpose.toUpperCase()} ?", 
        style: const TextStyle(fontSize: 12.5, color: Colors.grey),)),
      const Center(child: Text("You will not able to undo this action.", 
        style: TextStyle(fontSize: 12.5, color: Colors.grey),)),
      Padding( padding: EdgeInsets.only(top: 20), child: Row( mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding( padding: EdgeInsets.only(right: 10), child: TextButton(onPressed: () {
          widget.validate();
          context.pop();
        }, style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Theme.of(context).primaryColor)), 
        child: Padding( padding: EdgeInsets.symmetric(horizontal: 20), child: Text("YES", style: TextStyle(color: Colors.white, fontSize: 15),)))),
        TextButton(onPressed: () => context.pop(), style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Theme.of(context).splashColor)), 
        child: Padding( padding: EdgeInsets.symmetric(horizontal: 20), child: Text("NO", style: TextStyle(color: Colors.white, fontSize: 15),)))]))
    ],)));
  }
}