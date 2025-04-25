import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/services/trigger_cache.dart';
import 'package:sqldbui2/core/widget/form/convertors/convertor.dart';
import 'package:sqldbui2/core/widget/utils/alert.dart';
import 'package:sqldbui2/main.dart';
import 'package:sqldbui2/model/view.dart';
import 'package:sqldbui2/page/translate.dart';

// ignore: must_be_immutable
class TriggerBoxWidget extends StatefulWidget {
  String title;
  int index = 1;

  bool isCached;
  List<Trigger> triggers;
  Map<String, dynamic> body;
  Map<String, SchemaField> schema;
  String actionPath;
  TriggerBoxWidget ({ super.key, required this.body, required this.schema, 
    required this.isCached,
    required this.title, required this.actionPath, required this.triggers });
  @override TriggerBoxWidgetState createState() => TriggerBoxWidgetState();
}
class TriggerBoxWidgetState extends State<TriggerBoxWidget> {
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
    List<String> order = widget.body.keys.toList();
    order.sort( (a, b) => (widget.schema[a]?.index ?? 0) - (widget.schema[b]?.index ?? 0) );
    for (var k in order) {
      if (widget.schema[k] != null) {
        var scheme = widget.schema[k];
        if (!scheme!.readonly) {
          try {
            print("$k ${widget.schema[k]} ${widget.schema[k]?.readonly} ${widget.schema[k]?.type}");
            var w = await Convertor.formFieldByType(
              widget.body, context, "", widget.schema, scheme.type, k, scheme.label, 
              scheme.description, scheme.require, scheme.readonly, widget.body[k], "", "", 
              "", null, currentView?.isEmpty ?? false, scheme.autoFill, scheme.translatable);
            widgets.add(
              Container( 
                width: currentWidth / 1.5,
                padding: EdgeInsets.all(10),
                child: w)
            );
          } catch(e,s) {
            print(e);
            print(s);
          }
          
          
        }
      }
    }
    return AlertWidget(
      widget: Column(
        mainAxisSize: MainAxisSize.min, 
      children: [
        Text("${await getOnFlow(widget.title.toUpperCase())} ${widget.index}/${widget.triggers.length}", 
          style: TextStyle(fontSize: 25, color: Theme.of(context).primaryColor)),
      Container( height: MediaQuery.of(context).size.height / 1.5,
        child: SingleChildScrollView( child: Column(
        children: widgets,
      ))),
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
          onPressed: () {
            APIService().post(widget.actionPath, widget.body, context);
            if (widget.isCached) {
              TriggerCacheService.deleteTriggers(widget.index - 1);
            }
            if (widget.index + 1 < widget.triggers.length) {
              widget.index++;
            }
            isTriggerOpen = false;
            context.pop();
            globalMainViewKey.currentState?.setState(() { });
        },
        child: Padding( padding: EdgeInsets.symmetric(horizontal: 20), 
          child: Text(TranslateConstants.send.toUpperCase(), 
          style: TextStyle(color: Colors.white, fontSize: 15))))),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).splashColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5), // Change this value
            ),
          ),
          onPressed: () {
            TriggerCacheService.triggers = [];
            isTriggerOpen = false;
            context.pop();
            globalMainViewKey.currentState?.setState(() { });
        },
        child: Padding( padding: EdgeInsets.symmetric(horizontal: 20), 
          child: Text(TranslateConstants.filterCancel.toUpperCase(), 
          style: TextStyle(color: Colors.white, fontSize: 15))))
      ]))
    ],));
  }
}