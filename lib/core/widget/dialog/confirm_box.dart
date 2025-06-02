import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sqldbui2/core/widget/utils/alert.dart';
import 'package:sqldbui2/page/translate.dart';

// ignore: must_be_immutable
class ConfirmBoxWidget extends StatefulWidget {
  String purpose = ""; 
  Function validate = () {};
  ConfirmBoxWidget ({ super.key, required this.purpose, required this.validate });
  @override ConfirmBoxWidgetState createState() => ConfirmBoxWidgetState();
}
class ConfirmBoxWidgetState extends State<ConfirmBoxWidget> {
  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    return AlertWidget(
        widget: Column(mainAxisSize: MainAxisSize.min, children: [
      Center(child: Padding( padding: EdgeInsets.only(bottom: 10), 
        child: Icon(Icons.help_outline_outlined, size: 80, color: Colors.grey,))),
      Center(child: Text((await getOnFlow(TranslateConstants.sure)).toUpperCase(), 
        style: TextStyle(fontSize: 25, color: Theme.of(context).primaryColor),)),
      Center(child: Text(await getOnFlow("Do you really want to ${widget.purpose.toUpperCase()} ?"), 
        style: const TextStyle(fontSize: 12.5, color: Colors.grey),)),
      Center(child: Text(await getOnFlow(TranslateConstants.undoAction), 
        style: TextStyle(fontSize: 12.5, color: Colors.grey),)),
      Padding( padding: EdgeInsets.only(top: 20), child: Row( mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding( padding: EdgeInsets.only(right: 10), child: TextButton(onPressed: () {
          widget.validate();
          context.pop();
        }, style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Theme.of(context).primaryColor)), 
        child: Padding( padding: EdgeInsets.symmetric(horizontal: 20), child: Text(
          (await getOnFlow(TranslateConstants.yes)).toUpperCase(), 
          style: TextStyle(color: Colors.white, fontSize: 15),)))),
        TextButton(onPressed: () => context.pop(), style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Theme.of(context).splashColor)), 
        child: Padding( padding: EdgeInsets.symmetric(horizontal: 20), child: Text(
          (await getOnFlow(TranslateConstants.no)).toUpperCase(), 
          style: TextStyle(color: Colors.white, fontSize: 15),)))]))
    ],));
  }
}