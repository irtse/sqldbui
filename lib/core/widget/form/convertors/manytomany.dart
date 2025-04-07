import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/form/form.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/page/translate.dart';

// ignore: must_be_immutable
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
  ManyToManyWidget ({ super.key, required this.form, required this.schemaName, required this.name,
                      required this.readOnly, required this.value, required this.label,
                      required this.require, required this.type, required this.url, required this.component});
  @override
  // ignore: library_private_types_in_public_api
  _ManyToManyState createState() => _ManyToManyState();
}
class _ManyToManyState extends State<ManyToManyWidget> {
  List<DataFormWidget> widgets = <DataFormWidget>[];
  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
  var view = widget.component.widget.view!;
  var schema =  widget.component.widget.view!.schema;
  var scheme = schema[widget.name];
  if (scheme == null) { return Container(); }
  var readOnly = widget.readOnly || (!view.actions.contains("post") && !view.actions.contains("put")) || mainForm.currentState!.widget.view!.readOnly;
  if (readOnly) {
      List<Container> tags = <Container>[];
      if (widget.value != null && widget.value is List) {
        for (var val in widget.value) {
        val = val as model.Shallowed;
        tags.add(Container( margin: const EdgeInsets.only(top:5, left: 10, right: 10), 
          child: TextButton(onPressed: (){}, 
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Theme.of(context).primaryColor),
              mouseCursor: WidgetStateProperty.all(MouseCursor.uncontrolled),
            ),
            child: Text((await getOnFlow(val.label ?? val.name ?? "${val.id}")).toLowerCase(), 
              style: const TextStyle(color: Colors.white))
            )
          ));
        }
      }
      return Padding(padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),child: Column(children: [
        Row(children: [Text((await getOnFlow("${widget.label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')}${widget.require ? '*' : ''}:")).toLowerCase(), 
            style:  const TextStyle( color: Colors.black, fontSize: 14, ), )]),
        Row(children: [Wrap(children: tags)]) ]),);
    } else {
      String url = scheme.valuesPath;
      return FutureBuilder<APIResponse<model.Shallowed>>(
        future: APIService().get(url, true, null), 
        builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.Shallowed>> snap) {
            return SubManyToManyWidget(
              form: widget.form,
              schemaName: widget.schemaName,
              name: widget.name,
              readOnly: widget.readOnly,
              value: widget.value,
              component: widget.component,
              datas: snap.data?.data,
              require: widget.require,
              label: widget.label,
              type: widget.type,
              url: widget.url
            );
        });
      }
    }
}

class SubManyToManyWidget extends StatefulWidget {
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
  List<model.Shallowed>? datas;
  SubManyToManyWidget ({ super.key, required this.datas, required this.form, required this.schemaName, required this.name,
                      required this.readOnly, required this.value, required this.label,
                      required this.require, required this.type, required this.url, required this.component});
  @override
  // ignore: library_private_types_in_public_api
  _SubManyToManyState createState() => _SubManyToManyState();
}
class _SubManyToManyState extends State<SubManyToManyWidget> {
  List<DataFormWidget> widgets = <DataFormWidget>[];
  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    List<MultiSelectItem> items = <MultiSelectItem>[];
          widget.form[widget.name] = <dynamic>[];
          if (widget.datas != null) {
            for (var item in widget.datas!) {
              var v = item.label ?? item.name ?? "${item.id}";
              var ser = item.serialize();
              items.add(MultiSelectItem(ser, v.toLowerCase()));
              for (var val in (widget.value ?? []) as List<model.Shallowed>) {
                if (val.id == item.id) { widget.form[widget.name].add(ser); }
              }
            }
          }
          return Padding( padding: const EdgeInsets.only(left: 25, right: 25, bottom: 15), child: MultiSelectDialogField(
            initialValue: widget.form[widget.name],
            validator: (value) => (value == null || value.isEmpty) && widget.require && !widget.readOnly ? 'do not leave empty' : null,
            title: Padding(padding: const EdgeInsets.only(left: 30), child: Text( "${widget.label.toUpperCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')}${widget.require ? '*' : ''}", style: TextStyle( color: Theme.of(context).primaryColor ), )),
            buttonText: Text((await getOnFlow("${widget.label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')}${widget.require ? '*' : ''}")).toLowerCase(), 
              style: TextStyle( color: Colors.black, fontSize: 14, ), ),
            items: items,
            listType: MultiSelectListType.CHIP,
            onConfirm: (values) { widget.form[widget.name]=values; },
            onSaved: (values) { widget.form[widget.name]=values; },
            onSelectionChanged: (values) { 
              widget.component.widget.detectChange = true;
              widget.form[widget.name]=values; 
            },
          ));
  }
}
