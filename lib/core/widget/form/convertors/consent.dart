import 'package:flutter/material.dart';
import 'package:sqldbui2/core/widget/form/form.dart';
import 'package:sqldbui2/main.dart';
import 'package:sqldbui2/page/translate.dart';
import 'package:sqldbui2/model/view.dart' as model;
Map<String, Map<String,bool>> consentErrCache = {};
Map<String, Map<GlobalKey<FormWidgetState>, Map<String,model.Consent>>> consentCache = {};

// ignore: must_be_immutable
class ConsentWidget extends StatefulWidget {
  GlobalKey<FormWidgetState> state;
  model.Consent consent;
  dynamic value;
  ConsentWidget ({ 
    required this.consent,
    required this.state,
    this.value,
  }) : super(key: GlobalKey<ConsentState>()) ;
  @override
  // ignore: library_private_types_in_public_api
  ConsentState createState() => ConsentState();
}
class ConsentState extends State<ConsentWidget> {
  bool error = true;

  @override Widget build(BuildContext context) {
    if (consentCache[viewID ?? ""] == null) {
      consentCache[viewID ?? ""] = {};
    }
    if (consentErrCache[viewID ?? ""] == null) {
      consentErrCache[viewID ?? ""] = {};
    }
    if (consentCache[viewID ?? ""]?[widget.state] == null) {
      consentCache[viewID ?? ""]![widget.state] = {};
    }
    consentCache[viewID ?? ""]![widget.state]![widget.consent.name] = model.Consent(
      consent: widget.value ?? false, 
      body: widget.consent.body,
      optionnal: widget.consent.optionnal, 
      actionPath: widget.consent.actionPath,
      key: widget.key as GlobalKey<ConsentState>,
    );
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    return Padding( 
      padding: EdgeInsets.only(left: 30, right: 30), 
      child: Stack( 
        children: [  Wrap( 
        spacing: 10,
        alignment: WrapAlignment.center,
        children: [
          Padding( padding: EdgeInsets.only(top: 13),
            child: Text( "${(await getOnFlow(widget.consent.name)).toLowerCase()}${widget.consent.optionnal ? "" : "*"}",
              style: TextStyle( color: error ? Colors.red : Colors.black)
            )
          ),
          Padding( // width: 48, height: 48, 
            padding: EdgeInsets.only(right: 20), 
            child: CheckboxListTile(
              value: widget.value,
              onChanged: (value) { 
                setState(() {
                  widget.value = value ?? false;
                  consentErrCache[viewID ?? ""]?.remove(widget.consent.name);
                  consentCache[viewID ?? ""]![widget.state]![widget.consent.name] = model.Consent(
                    consent: value ?? false, 
                    body: widget.consent.body,
                    optionnal: widget.consent.optionnal, 
                    actionPath: widget.consent.actionPath,
                    key: widget.key as GlobalKey<ConsentState>);
                    widget.value ?? false;
                });  
              }
            ))
          ]) ])
        );
  }
}