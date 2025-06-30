import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/widget/form/convertors/convertor.dart';
import 'package:sqldbui2/core/widget/utils/alert.dart';
import 'package:sqldbui2/main.dart';
import 'package:sqldbui2/page/translate.dart';
import 'package:sqldbui2/model/view.dart' as model;

// ignore: must_be_immutable
class CommentBoxWidget extends StatefulWidget {
  int index = 0;
  String label;
  Map<String, dynamic> cache;
  model.SchemaField field;
  Map<String, model.SchemaField> schema;
  bool isCached;
  String message;
  Function()? call;
  CommentBoxWidget ({ super.key, 
    required this.message, 
    required this.schema,
    required this.label,
    required this.field,
    required this.cache,
    required this.isCached,
    required this.call,
  });
  @override CommentBoxWidgetState createState() => CommentBoxWidgetState();
}
class CommentBoxWidgetState extends State<CommentBoxWidget> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
    var w = await Convertor.formFieldByType(
      widget.cache, context, "", widget.schema, 
      widget.field.type, widget.label, widget.field.label, 
      widget.field.description, widget.field.require, widget.field.readonly, 
      null, 
              widget.field.actionPath, widget.field.valuesPath, 
              "", null, currentView?.isEmpty ?? false, widget.field.autoFill,  widget.field.translatable, null);
              widgets.add(
                Container( 
                  width: currentWidth / 1.5,
                  padding: EdgeInsets.all(10),
                  child: w)
              );
    return AlertWidget(
      widget: Column(
        mainAxisSize: MainAxisSize.min, 
      children: [
      Padding(padding: EdgeInsets.only(top:20, left: 20, right:20), 
        child :  Text(widget.message.toUpperCase(), overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 25, color: Theme.of(context).primaryColor))),
      SizedBox( height: MediaQuery.of(context).size.height / 1.7,
        child: SingleChildScrollView( child: Form( key: formKey, 
        autovalidateMode: AutovalidateMode.always, 
        child: Column(
        children: widgets,
      )))),
      Padding( padding: EdgeInsets.only(top: 20), 
      child: Row( mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding( padding: EdgeInsets.only(right: 10), 
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5), // Change this value
            ),
          ),
          onPressed: widget.call,
        child: Padding( padding: EdgeInsets.symmetric(horizontal: 20), 
          child: Text((await getOnFlow(TranslateConstants.send)).toUpperCase(), 
          style: TextStyle(color: Colors.white, fontSize: 15))))),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5), // Change this value
            ),
          ),
          onPressed: () {
            context.pop();
            navigate = true;
            globalMainViewKey.currentState?.setState(() { });
        },
        child: Padding( padding: EdgeInsets.symmetric(horizontal: 20), 
          child: Text((await getOnFlow(TranslateConstants.filterCancel)).toUpperCase(), 
          style: TextStyle(color: Colors.white, fontSize: 15))))
      ]))
    ],));
  }
}
