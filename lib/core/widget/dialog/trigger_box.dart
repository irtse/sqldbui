import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/services/action.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/services/trigger_cache.dart';
import 'package:sqldbui2/core/widget/form/convertors/convertor.dart';
import 'package:sqldbui2/core/widget/utils/alert.dart';
import 'package:sqldbui2/main.dart';
import 'package:sqldbui2/model/view.dart';
import 'package:sqldbui2/page/translate.dart';
import 'package:sqldbui2/model/view.dart' as model;

// ignore: must_be_immutable
class TriggerBoxWidget extends StatefulWidget {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
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
        var scheme = widget.triggers.first.schema[k];
        if (!scheme!.readonly) {
          try {
            print("$k ${scheme.actionPath}, ${scheme.valuesPath}, ");
            var w = await Convertor.formFieldByType(
              widget.body, context, "", widget.schema, scheme.type, k, scheme.label, 
              scheme.description, scheme.require, scheme.readonly, widget.body[k] == "" ? null : widget.body[k], 
              scheme.actionPath, scheme.valuesPath, 
              "", null, currentView?.isEmpty ?? false, scheme.autoFill, scheme.translatable, null);
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
    var trigsNav = [];
    for (var (i,_) in widget.triggers.indexed) {
      trigsNav.add(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: InkWell( 
            onTap: () => setState(() {
              widget.index = i + 1;
            }),
            child: Container(
              width: 10, height: 10, 
              decoration: BoxDecoration(
                color: i + 1 == widget.index ? Theme.of(context).primaryColor : Colors.grey, 
                borderRadius: BorderRadius.all(Radius.circular(30))
              ),
          )))
      );
    }
    return AlertWidget(
      widget: Column(
        mainAxisSize: MainAxisSize.min, 
      children: [
      Padding(padding: EdgeInsets.all(20), 
        child :  Text((await getOnFlow(widget.title)).toUpperCase(), overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 25, color: Theme.of(context).primaryColor))),
      Padding( 
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row( mainAxisAlignment: MainAxisAlignment.center, 
        children : [...trigsNav]
      )),
      Container( height: MediaQuery.of(context).size.height / 1.7,
        child: SingleChildScrollView( child: Form( key: widget.formKey, 
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
          onPressed: () async {
            var trigger = widget.triggers[widget.index -1];
            if (!(widget.formKey.currentState?.validate() ?? false)) {
              return;
            }
            var body = await ActionService.getBody("POST", {...widget.body }, {}, trigger.schema, context);
            var files = await ActionService.getFiles("POST", {...widget.body }, trigger.schema, context);
            await APIService().post<model.View>(widget.actionPath, body, context).then( (e) {
                if (e.data != null && e.data!.isNotEmpty) {
                  ActionService.onSuccessMethod("POST", e.data!.first, {...widget.body }, trigger.schema, files, context);
                }
              }).catchError( (e) => ActionService.listSubForms(trigger.schema, {...widget.body }, "POST", trigger.name ?? "", "", context, true)
            );
            if (widget.isCached) {
              TriggerCacheService.deleteTriggers(widget.index - 1);
            }
            widget.triggers.removeAt(widget.index - 1);
            widget.index = 1;
            if (widget.triggers.isEmpty) {
              isTriggerOpen = false;
              context.pop();
              globalMainViewKey.currentState?.setState(() { });
            } else {
              setState(() {});
            }
        },
        child: Padding( padding: EdgeInsets.symmetric(horizontal: 20), 
          child: Text(TranslateConstants.send.toUpperCase(), 
          style: TextStyle(color: Colors.white, fontSize: 15))))),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.grey,
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