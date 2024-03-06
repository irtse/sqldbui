import 'package:flutter_login/flutter_login.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/form.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class ManyToManyWidget extends StatefulWidget {
  final Map<String, dynamic> form;
  final String schemaName;
  final dynamic name;
  final bool readOnly;
  final bool require;
  dynamic value;
  final FormWidgetState component;
  final String? url;
  final String type;
  final String label;
  var isFilled = true;
  ManyToManyWidget ({ Key? key, required this.form, required this.schemaName, required this.name,
                      required this.readOnly, required this.value, required this.label,
                      required this.require, required this.type, required this.url, required this.component}): super(key: key);
  @override
  _ManyToManyState createState() => _ManyToManyState();
}
class _ManyToManyState extends State<ManyToManyWidget> {
  List<DataFormWidget> widgets = <DataFormWidget>[];
  @override Widget build(BuildContext context) {
  var view = widget.component.widget.view!;
  var schema =  widget.component.widget.view!.schema;
  var scheme = schema[widget.name];
  if (scheme == null) { return Container(); }
  var readOnly = (!view.actions.contains("post") && !view.actions.contains("put")) || mainForm.currentState!.widget.view!.readOnly;
  if (readOnly) {
      List<Container> tags = <Container>[];
      if (widget.value != null && widget.value is List) {
        for (var val in widget.value) {
        val = val as model.Shallowed;
        tags.add(Container( margin: const EdgeInsets.only(top:5, left: 10, right: 10), child: TextButton(onPressed: (){}, 
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
            mouseCursor: MaterialStateProperty.all(MouseCursor.uncontrolled),
          ),
          child: Text(val.label ?? val.name ?? "${val.id}", style: const TextStyle(color: Colors.white)), )));
        }
      }
      return Padding(child: Column(children: [
        Row(children: [Text("${widget.label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')}${widget.require ? '*' : ''}:", style: TextStyle( color: Colors.black, fontSize: 14, ), )]),
        Row(children: [Wrap(children: tags,)]) ]), 
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),);
    } else {
      String? url;
      for (var fieldName in scheme.schema.keys) {
        if (!fieldName.contains(widget.schemaName) && scheme.schema[fieldName]!.valuesPath != "") {
          url = scheme.schema[fieldName]!.valuesPath;  break;
        }
      }
      return FutureBuilder<APIResponse<model.Shallowed>>(
      future: APIService().get(url ?? "", true, null), 
      builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.Shallowed>> snap) {
        List<MultiSelectItem> items = <MultiSelectItem>[];
        widget.form[widget.name] = <dynamic>[];
        if (snap.hasData && snap.data!.data != null) {
          developer.log('LOG D ${widget.label} ${widget.value}', name: 'my.app.category');
          for (var item in snap.data!.data!) {
            var v = item.label ?? item.name ?? "${item.id}";
            var ser = item.serialize();
            items.add(MultiSelectItem(ser, v.toLowerCase()));
            if (widget.value != null) { 
              for (var val in widget.value as List<model.Shallowed>) {
                if (val.id == item.id) { widget.form[widget.name].add(ser); }
              }
            }
          }
        }
        return Padding( padding: const EdgeInsets.only(left: 25, right: 25, bottom: 15), child: MultiSelectDialogField(
                                initialValue: widget.form[widget.name],
                                validator: (value) => (value == null || value.isEmpty) && widget.require ? 'do not leave empty' : null,
                                title: Padding(padding: const EdgeInsets.only(left: 30), child: Text( "${widget.label.toUpperCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')}${widget.require ? '*' : ''}", style: TextStyle( color: Theme.of(context).primaryColor ), )),
                                buttonText: Text("${widget.label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')}${widget.require ? '*' : ''}", style: TextStyle( color: Colors.black, fontSize: 14, ), ),
                                items: items,
                                listType: MultiSelectListType.CHIP,
                                onConfirm: (values) { widget.form[widget.name]=values; },
                                onSaved: (values) { widget.form[widget.name]=values; },
                                onSelectionChanged: (values) { widget.form[widget.name]=values; },
                            ));
        });
      }
    }
}