import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/core/widget/form/form.dart';
import 'package:sqldbui2/page/translate.dart';

// ignore: must_be_immutable
class BooleanWidget extends StatefulWidget {
  final FormWidgetState? component;
  final Map<String, dynamic> form;
  final String schemaName;
  final dynamic name;
  final bool require;
  final bool readOnly;
  dynamic value;
  final String label;
  final String type;
  final dynamic autofill;
  bool error = false;
  BooleanWidget ({ super.key, required this.form, required this.schemaName, required this.name,
                      required this.readOnly, required this.type, required this.value, required this.label,
                      required this.component, this.require = false, required this.autofill});
  @override
  // ignore: library_private_types_in_public_api
  _BooleanState createState() => _BooleanState();
}
class _BooleanState extends State<BooleanWidget> {
  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    widget.value = "${(widget.form[widget.name]) ?? false}" == "true"; 
    var label = widget.label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ');
    try { 
      label = await getOnFlow(label);
    } catch(e,s) { }
    if (label.length > 10) {
      return Padding( 
      padding: EdgeInsets.only(left: 30, right: 30, top: 10), 
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [ 
          widget.readOnly ? Container() 
          : Container( width: 48,
            padding: EdgeInsets.only(right: 20), 
            child: Checkbox(
              value: widget.value,
              onChanged: (value) { 
                widget.value = value;
                widget.form[widget.name] = value; 
                setState(() { });
              },
            ),
          ),
          Container( padding: EdgeInsets.only(left: 40), child: Text( "${label.toLowerCase()}${widget.require ? "" : "*"}", overflow: TextOverflow.ellipsis,
              style: TextStyle( color: widget.error ? Colors.red : Colors.black)
          )),
          widget.readOnly ? Container( width: 60, height: 30, 
            padding: EdgeInsets.only(right: 20), 
            child: FutureBuilder(future: getOnFlow(widget.value == true ? "yes" : "no"), builder: (a, s) {
              if (s.data != null) {
                return Text("${s.data!} :", style: TextStyle( fontWeight: FontWeight.bold) );
              }
              return Text("${widget.value == true ? "yes" : "no"} :", style: TextStyle( fontWeight: FontWeight.bold) );
            })) 
          : Container()
         ]) 
      );
    }
    ValueNotifier<bool> ctrl = ValueNotifier(widget.value ?? ("${widget.autofill}" == "true"));
    return AdvancedSwitch( width : 200,
          enabled: !widget.readOnly,
          controller: ctrl,
          activeColor: Colors.green, inactiveColor: Colors.grey,
          activeChild: Text("$label${widget.require ? '*' : ''}".toLowerCase()), 
          inactiveChild: Text("$label${widget.require ? '*' : ''}".toLowerCase()), 
          borderRadius:  const BorderRadius.all(Radius.circular(15)),
          height: 30.0, disabledOpacity: 0.5,
          onChanged: (value) {
            widget.component?.widget.detectChange = true;
            widget.form[widget.name]=value;
            ctrl.value = value;
          }
    );
  }
}
