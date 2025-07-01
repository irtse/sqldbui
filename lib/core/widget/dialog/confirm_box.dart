import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/widget/form/convertors/convertor.dart';
import 'package:sqldbui2/core/widget/utils/alert.dart';
import 'package:sqldbui2/main.dart';
import 'package:sqldbui2/model/view.dart';
import 'package:sqldbui2/page/translate.dart';

// ignore: must_be_immutable
class ConfirmBoxWidget extends StatefulWidget {
  String? name;
  Map<String, dynamic>? cache;
  SchemaField? field;
  Map<String, SchemaField>? schema;

  String purpose = ""; 
  Function validate = () {};
  ConfirmBoxWidget ({ super.key, this.cache, this.name, this.field, this.schema, required this.purpose, required this.validate });
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
    List<Widget> widgets = [];
    if (widget.field != null && widget.schema != null && widget.cache != null && widget.name != null) {
      var w = await Convertor.formFieldByType(
        widget.cache!, context, "", widget.schema!, 
        widget.field!.type, widget.name!, widget.field!.label, 
        widget.field!.description, widget.field!.require, widget.field!.readonly, 
        null, widget.field!.actionPath, widget.field!.valuesPath, 
        "", null, currentView?.isEmpty ?? false, widget.field!.autoFill,  widget.field!.translatable, null);
      widgets.add(
        Container( 
          width: currentWidth / 2,
          padding: EdgeInsets.all(10),
          child: w
        )
      );
    }
   
    return AlertWidget(
        widget: Column(mainAxisSize: MainAxisSize.min, children: [
      Center(child: Padding( padding: EdgeInsets.only(bottom: 10), 
        child: Icon(Icons.help_outline_outlined, size: 80, color: Colors.grey))),
      Center(child: Text((await getOnFlow(TranslateConstants.sure)).toUpperCase(), 
        style: TextStyle(fontSize: 25, color: Theme.of(context).primaryColor),)),
      Wrap( alignment: WrapAlignment.center, children : [
        Text("${(await getOnFlow("Do you really want to")).toLowerCase()} ${(await getOnFlow(widget.purpose)).toUpperCase()} ? ", 
        style: const TextStyle(fontSize: 12.5, color: Colors.grey)),
        Text(await getOnFlow(TranslateConstants.undoAction), 
        style: TextStyle(fontSize: 12.5, color: Colors.grey))
      ]),
      widgets.isEmpty ? Container() : Center( child: SingleChildScrollView( child: SizedBox( height: currentHeigth / 2, child: Row(children: widgets)))),
      Padding( padding: EdgeInsets.only(top: 20), child: Row( mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding( padding: EdgeInsets.only(right: 10), child: TextButton(onPressed: () {
          widget.validate();
          context.pop();
        }, style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Theme.of(context).primaryColor)), 
        child: Padding( padding: EdgeInsets.symmetric(horizontal: 20), child: Text(
          (await getOnFlow(TranslateConstants.yes)).toUpperCase(), 
          style: TextStyle(color: Colors.white, fontSize: 15),)))),
        TextButton(onPressed: () => context.pop(), 
          style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.grey)), 
        child: Padding( padding: EdgeInsets.symmetric(horizontal: 20), child: Text(
          (await getOnFlow(TranslateConstants.no)).toUpperCase(), 
          style: TextStyle(color: Colors.white, fontSize: 15),)))]))
    ]));
  }
}