import 'package:sqldbui2/core/widget/dialog/confirm_box.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/widget/form/widget/error_formulary.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/form/form.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/page/translate.dart';

// ignore: must_be_immutable
class OneToManyWidget extends StatefulWidget {
  final String schemaName;
  final dynamic name;
  bool readOnly;
  bool canPost = false;
  final bool require;
  final bool translatable;
  dynamic value;
  final String? url;
  final String type;
  final String label;
  List<DataFormWidget> filtered = [];
  var isFilled = true;
  final FormWidgetState? component;
  List<String> deleted = [];
  OneToManyWidget ({ super.key, required this.schemaName, required this.name,
                      required this.readOnly, required this.value, required this.label,
                      required this.require, required this.type, required this.url, 
                      required this.component, required this.translatable});
  @override
  // ignore: library_private_types_in_public_api
  OneToManyState createState() => OneToManyState();
}
class OneToManyState extends State<OneToManyWidget> {
  bool first = true;
  @override Widget build(BuildContext context) {
    if (first) {
      widget.component?.widget.oneToManiesStateForm.add(this);
      first = false;
    }
    
    var schema =  widget.component?.widget.view!.schema;
    var scheme = schema?[widget.name];

    if (scheme == null) { return Container(); }
    widget.filtered = (widget.component?.widget.oneToManiesForm[widget.name] ?? []).where((e) {
      return (e.view?.id ?? - 1) < 0;
    }).toList();
    print("ONETOMANY ${widget.value}");
    if (widget.value != null) { // TEST => nvnv
      return FutureBuilder<APIResponse<model.View>>(
        future: APIService().get(widget.value, true, null), 
        builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.View>> snap) {
        return SubOneToManyWidget(schemaName: widget.schemaName, 
          name: widget.name, 
          datas: snap.data?.data, 
          readOnly: widget.readOnly, 
          value: widget.value, 
          label: widget.label, 
          require: widget.require, 
          type: widget.type, 
          url: widget.url, 
          state: this,
          scheme: scheme,
          filtered: widget.filtered,
          component: widget.component);
      });
    }
    return Column(children: [
      FutureBuilder(future: controlButtons(widget.readOnly, widget.canPost, scheme), builder: (a,s) {
        if (s.data != null) {
          return Row(children: s.data! );
        }
        return Row(children: [] );
      }), ...widget.filtered]);
  }

  Future<List<Widget>> controlButtons(bool readOnly, bool canPost, model.SchemaField scheme) async {
    var val = widget.label.toLowerCase().toLowerCase().toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ');
    if (widget.translatable) {
      val = await getOnFlow(val);
    }
    List<Widget> rows = [Padding( 
      padding: EdgeInsets.only(left: 30, top: !readOnly && canPost ? 0 : 10, bottom: !readOnly && canPost ? 0 : 10), 
      child: Text("$val ${widget.require ? '*' : ''}:", style: TextStyle( color: widget.require 
      && (widget.component?.widget.oneToManiesForm[widget.name] ?? []).isEmpty && errorFormKey.currentState?.widget.error != null ? Colors.red : null )))]; 
    if (!readOnly && (canPost || widget.component?.widget.view != null) || (widget.component?.widget.view?.isEmpty ?? false)) {
        var filtered = widget.component?.widget.oneToManiesForm[widget.name] ?? [];
        rows.add(IconButton(icon: const Icon(Icons.add), onPressed: (){ 
          widget.component?.widget.detectChange = true;
          var mapped = <String, dynamic>{};
          List<String> order = <String>[];
          for (var fieldName in scheme.schema.keys) { 
            mapped[fieldName] = null; 
            order.add(fieldName);
          }
          var newView = model.View(
            name: "${widget.label} ${(widget.component?.widget.oneToManiesForm[widget.name] ?? []).length + 1}", 
            actions: scheme.actions, actionPath: scheme.actionPath,
            schema: scheme.schema, order: order, isEmpty: true, 
            items: <model.Item>[model.Item(values: mapped)]);
          widget.component?.widget.detectChange = true;
          setState(() { 
            var k = GlobalKey<FormWidgetState>();
            if (widget.component?.widget.oneToManiesForm[widget.name] == null) {
              widget.component?.widget.oneToManiesForm[widget.name] = [];
            }
            widget.component?.widget.oneToManiesForm[widget.name]!.add( 
              DataFormWidget(key: k, noTitle: true, view: newView, scroll: false, subForm: true, isOneToMany: true,
              superFormSchemaName: widget.schemaName)); 
          });
        }));
        if (filtered.isNotEmpty) {
          rows.add(IconButton(icon: const Icon(Icons.remove), onPressed: () {
            widget.component?.widget.detectChange = true;
            setState(() { 
              var val = widget.component?.widget.oneToManiesForm[widget.name]?.where((element) => element.view!.name.contains(widget.label)) ?? [];
              if (val.isNotEmpty) {
                widget.component?.widget.oneToManiesForm[widget.name]?.remove(val.last); 
              }
          });}));
        }
    }
    return rows;
  }
}
// ignore: must_be_immutable
class SubOneToManyWidget extends StatefulWidget {
  final model.SchemaField scheme;
  final List<DataFormWidget> filtered;
  final String schemaName;
  final dynamic name;
  bool readOnly;
  bool canPost = false;
  final bool require;
  dynamic value;
  final String? url;
  final String type;
  final String label;
  List<model.View>? datas;
  var isFilled = true;
  OneToManyState state;
  var flashed = <int, DataFormWidget>{};
  final FormWidgetState? component;
  SubOneToManyWidget ({ super.key, required this.state,
  required this.schemaName, required this.name, required this.datas, required this.filtered,
                      required this.readOnly, required this.value, required this.label,
                      required this.require, required this.type, required this.url, 
                      required this.component, required this.scheme});
  @override
  // ignore: library_private_types_in_public_api
  SubOneToManyState createState() => SubOneToManyState();
}
class SubOneToManyState extends State<SubOneToManyWidget> {
  @override Widget build(BuildContext context) {
    List<Widget> items = <Widget>[];
    if (widget.datas != null) {
      for (var (i, data) in widget.datas!.indexed) {
        if (widget.state.widget.deleted.contains(data.name.toString())) {
          continue;
        }
        widget.readOnly = widget.readOnly || !data.actions.contains("put");
        widget.canPost = data.actions.contains("post");
        for (var item in data.items) {
          item.readonly = widget.readOnly;
          var view = model.View(
            id: int.parse(item.values["id"]), 
            name: "${widget.label} ${(widget.component?.widget.oneToManiesForm[widget.name] ?? []).length + 1}", 
            readOnly: widget.readOnly,
            workflow: data.workflow, 
            actions: data.actions, 
            actionPath: data.actionPath, 
            schemaName: data.schemaName, 
            schema: data.schema, 
            order: data.order, 
            isEmpty: false, 
            items: <model.Item>[item]
          );
          var k = GlobalKey<FormWidgetState>();
          var dataForm = DataFormWidget(key: k, isOneToMany: true,
            noTitle: true, view: view, scroll: false, subForm: true, superFormSchemaName: widget.schemaName);

          if (!widget.readOnly && data.actions.contains("delete")) {
            var w = Stack( children: [ 
              dataForm,
              Positioned(top: 30,  right: 30,  child: IconButton(onPressed: () {
                  showDialog(context: context, builder: (builder) => ConfirmBoxWidget(purpose: "delete occurency", validate: () {
                  widget.component?.widget.detectChange = true;
                  widget.datas?.removeAt(i);
                  widget.state.widget.deleted.add(view.name.toString());
                  widget.component?.widget.oneToManiesForm[widget.name]?.removeWhere( (e) => e.view?.name == view.name);
                  setState(() { });
                })); 
              }, 
              icon: const Icon(Icons.delete, color: Colors.grey)))
            ]);
            items.add(w);
          } else {  
            items.add(dataForm); 
          }
          if (widget.component?.widget.oneToManiesForm[widget.name] == null) {
            widget.component?.widget.oneToManiesForm[widget.name] = [];
          }
          if ((widget.component?.widget.oneToManiesForm[widget.name]?.where(
            (e) => e.view?.name == dataForm.view?.name 
          ) ?? []).isEmpty) {
            if ((widget.component?.widget.oneToManiesForm[widget.name]?.where((e) {
              return e.view?.id == dataForm.view?.id;
            }) ?? []).isEmpty) {
              widget.component?.widget.oneToManiesForm[widget.name]!.add(dataForm);
            }
          }
        }      
      }
    }
    
    try {
      return Column(children: [ 
        FutureBuilder(future: widget.state.controlButtons(widget.readOnly, widget.canPost, widget.scheme), builder: (a,s) {
          if (s.data != null) {
            return Row(children: s.data! );
          }
          return Row(children: [] );
        }),
        ...items, ...widget.filtered
      ]);
    } catch(e, s) {
      print(e);
      print(s);
      return Container();
    }
  }

}