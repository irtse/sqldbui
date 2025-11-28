import 'package:sqldbui2/core/sections/view.dart';
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
  OneToManyWidget ({  required this.schemaName, required this.name,
                      required this.readOnly, required this.value, required this.label,
                      required this.require, required this.type, required this.url, 
                      required this.component, required this.translatable}): super(key: GlobalKey<State<OneToManyWidget>>());
  @override
  // ignore: library_private_types_in_public_api
  OneToManyState createState() => OneToManyState();
}
class OneToManyState extends State<OneToManyWidget> {
  bool first = true;
  @override Widget build(BuildContext context) {
    if ((widget.component?.widget.view?.rules ?? []).where( (r) => r.trigger == widget.name).isNotEmpty) {
      for (var r in (widget.component?.widget.view?.rules ?? [])) {
        if (r.trigger == widget.name) {
          r.key = widget.key as GlobalKey<State<OneToManyWidget>>;
        }
      }
    }
    if (first) {
      oneToManiesStateForm[widget.component?.widget.view?.name]?.add(this);
      first = false;
    }
    var schema =  widget.component?.widget.view!.schema;
    var scheme = schema?[widget.name];

    if (scheme == null) { return Container(); }
    widget.filtered = (oneToManiesForm[widget.component?.widget.view?.name]?[widget.name] ?? []).where((e) {
      return (e.view?.id ?? - 1) < 0;
    }).toList();
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
      FutureBuilder(future: controlButtons(widget.readOnly, widget.canPost, scheme, 0), builder: (a,s) {
        if (s.data != null) {
          return Row(children: s.data! );
        }
        return Row(children: [] );
      }), ...widget.filtered]);
  }

  Future<List<Widget>> controlButtons(bool readOnly, bool canPost, model.SchemaField scheme,  int datasLen) async {
    var val = widget.label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ');
    if (widget.translatable) {
      val = await getOnFlow(val);
    }
    List<Widget> rows = [Padding( 
      padding: EdgeInsets.only(left: 30, top: !readOnly && canPost ? 0 : 10, bottom: !readOnly && canPost ? 0 : 10), 
      child: Text("$val ${widget.require ? '*' : ''}:", style: TextStyle( color: widget.require 
      && (oneToManiesForm[widget.component?.widget.view?.name]?[widget.name] ?? []).isEmpty && errorFormKey[widget.component?.widget.formKey]?.currentState?.widget.error != null ? Colors.red : null )))]; 
    if (!readOnly && (canPost || widget.component?.widget.view != null) || (widget.component?.widget.view?.isEmpty ?? false)) {
        var filtered = oneToManiesForm[widget.component?.widget.view?.name]?[widget.name] ?? [];
        rows.add(IconButton(icon: const Icon(Icons.add), onPressed: (){ 
          var mapped = <String, dynamic>{};
          List<String> order = <String>[];
          for (var fieldName in scheme.schema.keys) { 
            mapped[fieldName] = null; 
            order.add(fieldName);
          }
          var newView = model.View(
            name: "${widget.label} ${(oneToManiesForm[widget.component?.widget.view?.name]?[widget.name] ?? []).length + 2}", 
            actions: scheme.actions, actionPath: scheme.actionPath,
            schema: scheme.schema, order: order, isEmpty: true, 
            items: <model.Item>[model.Item(values: mapped)]);
          setState(() { 
            var k = GlobalKey<FormWidgetState>();
            if (oneToManiesForm[widget.component?.widget.view?.name]?[widget.name] == null) {
              oneToManiesForm[widget.component?.widget.view?.name]?[widget.name] = [];
            }
            oneToManiesForm[widget.component?.widget.view?.name]?[widget.name]?.add( 
              DataFormWidget(key: k, noTitle: true, view: newView, scroll: false, subForm: true, isOneToMany: true,
              superFormSchemaName: widget.schemaName)); 
          });
        }));
        if (filtered.isNotEmpty && filtered.length > datasLen) {
          rows.add(IconButton(icon: const Icon(Icons.remove), onPressed: () {
            setState(() { 
              if ((oneToManiesForm[widget.component?.widget.view?.name]?[widget.name] ?? []).isNotEmpty) {
                oneToManiesForm[widget.component?.widget.view?.name]?[widget.name]?.removeLast(); 
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
  bool isFirst = true;
  List<Widget> items = <Widget>[];
  @override Widget build(BuildContext context) {
    if (widget.datas != null && isFirst) {
      isFirst = false;
      items = [];
      for (var ( data) in widget.datas!) {
        widget.readOnly = widget.readOnly || !data.actions.contains("put");
        widget.canPost = data.actions.contains("post");
        print(data!.items);
        for (var (i,item ) in data!.items.indexed) {
          item.readonly = widget.readOnly;
          var view = model.View(
            id: int.parse(item.values["id"]), 
            name: "${widget.label} ${(oneToManiesForm[widget.component?.widget.view?.name]?[widget.name] ?? []).length + 1}", 
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

          if (!widget.readOnly && (currentView?.actions.contains("put") ?? false)) {
            var w = Stack( children: [ 
              dataForm,
              Positioned(top: 30,  right: 30,  child: IconButton(onPressed: () {
                try{
                  items.removeAt(i);
                  oneToManiesForm[widget.component?.widget.view?.name]?[widget.name]?.removeAt(i);
                  setState(() { });
                } catch(e) {}
                  
              }, 
              icon: const Icon(Icons.delete, color: Colors.grey)))
            ]);
            items.add(w);
          } else {  
            items.add(dataForm); 
          }
          if (oneToManiesForm[widget.component?.widget.view?.name]?[widget.name] == null) {
            oneToManiesForm[widget.component?.widget.view?.name]?[widget.name] = [];
          }
          oneToManiesForm[widget.component?.widget.view?.name]?[widget.name]!.add(dataForm); 
        }      
      }
    }
    try {
      return Column(children: [ 
        FutureBuilder(future: widget.state.controlButtons(widget.readOnly, widget.canPost, widget.scheme, items.length), builder: (a,s) {
          if (s.data != null) {
            return Row(children: s.data! );
          }
          return Row(children: [] );
        }),
        ...items, ...widget.filtered
      ]);
    } catch(e) {
      return Container();
    }
  }

}