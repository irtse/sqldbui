import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/services/action.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/services/trigger_cache.dart';
import 'package:sqldbui2/core/widget/dialog/confirm_box.dart';
import 'package:sqldbui2/core/widget/form/convertors/convertor.dart';
import 'package:sqldbui2/core/widget/form/form.dart';
import 'package:sqldbui2/core/widget/utils/alert.dart';
import 'package:sqldbui2/main.dart';
import 'package:sqldbui2/model/view.dart';
import 'package:sqldbui2/page/translate.dart';
import 'package:sqldbui2/model/view.dart' as model;

// ignore: must_be_immutable
class TriggerBoxWidget extends StatefulWidget {
  int index = 0;

  bool isCached;
  List<Trigger> triggers;
  TriggerBoxWidget ({ super.key,  
    required this.isCached,
    required this.triggers });
  @override TriggerBoxWidgetState createState() => TriggerBoxWidgetState();
}
class TriggerBoxWidgetState extends State<TriggerBoxWidget> {
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
    List<String> order = widget.triggers[widget.index].body.keys.toList();
    order.sort( (a, b) => (widget.triggers[widget.index].schema[a]?.index ?? 0) - (widget.triggers[widget.index].schema[b]?.index ?? 0) );
    Map<String, dynamic> b = {};
    for (var k in order) {
      if (widget.triggers[widget.index].schema[k] != null) {
        var scheme = widget.triggers.first.schema[k];
        if (!scheme!.readonly) {
          try {
            var w = await Convertor.formFieldByType(
              b, context, "", widget.triggers[widget.index].schema, scheme.type, k, scheme.label, 
              scheme.description, scheme.require, scheme.readonly, widget.triggers[widget.index].body[k] == "" ? null : widget.triggers[widget.index].body[k], 
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
              widget.index = i;
            }),
            child: Container(
              width: 10, height: 10, 
              decoration: BoxDecoration(
                color: i == widget.index ? Theme.of(context).primaryColor : Colors.grey, 
                borderRadius: BorderRadius.all(Radius.circular(30))
              ),
          )))
      );
    }
    try {
    return AlertWidget(
      widget: SingleChildScrollView( child: Column(
      mainAxisSize: MainAxisSize.min, 
      children: [
      Padding(padding: EdgeInsets.only(top:20, left: 20, right:20), 
        child :  Text(widget.triggers[widget.index].name == null ? "" : (await getOnFlow(widget.triggers[widget.index].name ?? "")).toUpperCase(), overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 25, color: Theme.of(context).primaryColor))),
      if (widget.triggers[widget.index].description != null && widget.triggers[widget.index].description != "")
        Padding(padding: EdgeInsets.only(left: 20, right:20), 
            child :  Text((await getOnFlow(widget.triggers[widget.index].description ?? "")).toLowerCase(), overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 15, color: Colors.grey))),
      Padding( 
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row( mainAxisAlignment: MainAxisAlignment.center, 
        children : [...trigsNav]
      )),
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
          onPressed: () async {
            var trigger = widget.triggers[widget.index];
            if (!(formKey.currentState?.validate() ?? false)) {
              return;
            }
            var body = await ActionService.getBody("POST", {...b }, {}, trigger.schema, {}, context);
            var files = await ActionService.getFiles("POST", {...b }, trigger.schema, context);
            for (var bb in widget.triggers[widget.index].body.keys) {
              if (body[bb] == null) {
                body[bb] =  widget.triggers[widget.index].body[bb];
              }
            }
            for (var pathFile in files.keys) {
              await submitFile(pathFile, files[pathFile]!, context);
            }
            await APIService().post<model.View>(widget.triggers[widget.index].actionPath, body, context).then( (e) {
                if (e.data != null && e.data!.isNotEmpty) {
                  ActionService.onSuccessMethod("POST", e.data!.first, body, trigger.schema, context);
                }
              }).catchError( (e) {});
            if (widget.isCached) {
              TriggerCacheService.deleteTriggers(widget.index);
            }
            try{
              widget.triggers.removeAt(widget.index);
            } catch(e) {}
            
            widget.index = 0;
            if (widget.triggers.isEmpty) {
              isTriggerOpen = false;
              context.pop();
            } else {
              setState(() {});
            }
        },
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
            TriggerCacheService.triggers = [];
            isTriggerOpen = false;
            context.pop();
            navigate = true;
            confirmCache = {};
        },
        child: Padding( padding: EdgeInsets.symmetric(horizontal: 20), 
          child: Text((await getOnFlow(TranslateConstants.filterCancel)).toUpperCase(), 
          style: TextStyle(color: Colors.white, fontSize: 15))))
      ]))
    ])));
    } catch(e,s) {
      print(e);
      print(s);
      return Container();
    }
  }
}
