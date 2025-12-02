import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/widget/dialog/confirm_box.dart';
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
  List<model.View>? deleted;
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
    var schema =  widget.component?.widget.view!.schema;
    var scheme = schema?[widget.name];
    if (scheme == null) { return Container(); }
    if (widget.deleted != null) {
        return SubOneToManyWidget(schemaName: widget.schemaName, 
          name: widget.name, 
          datas: widget.deleted, 
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
    }
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
    return SubOneToManyWidget(schemaName: widget.schemaName, 
          name: widget.name, 
          datas: [], 
          readOnly: widget.readOnly, 
          value: widget.value, 
          label: widget.label, 
          require: widget.require, 
          type: widget.type, 
          url: widget.url, 
          state: this,
          scheme: scheme,
          filtered: [],
          component: widget.component
        );
    }
 }

// ignore: must_be_immutables
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
  List<Widget> items = <Widget>[];
  var isFirst = true;

  @override Widget build(BuildContext context) {
    if (widget.datas != null && isFirst) {
      isFirst = false;
      items = [];
      oneToManiesForm[widget.component?.widget.view?.name]?[widget.name] = [];
      for (var data in widget.datas!) {
        widget.readOnly = widget.readOnly || !data.actions.contains("put");
        widget.canPost = data.actions.contains("post");
        for (var (item) in data.items) {
          items.add(SubSubOneToManyWidget(data: data, item: item, schemaName: widget.schemaName,
          label: widget.label, name: widget.name, viewName: widget.component?.widget.view?.name ?? "", readOnly: widget.readOnly,));
        }      
      }
      for (var f in widget.filtered) {
        oneToManiesForm[widget.component?.widget.view?.name]?[widget.name]?.add(f);
      }
    }
    
    try {
      return Column(children: [ 
        FutureBuilder(future: controlButtons(widget.readOnly, widget.canPost, widget.scheme, items.length), builder: (a,s) {
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


  Future<List<Widget>> controlButtons(bool readOnly, bool canPost, model.SchemaField scheme,  int datasLen) async {
    var val = widget.label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ');
    if (widget.state.widget.translatable) {
      val = await getOnFlow(val);
    }
    List<Widget> rows = [Padding( 
      padding: EdgeInsets.only(left: 30, top: !readOnly && canPost ? 0 : 10, bottom: !readOnly && canPost ? 0 : 10), 
      child: Text("$val ${widget.require ? '*' : ''}:", style: TextStyle( color: widget.require 
      && widget.filtered.isEmpty && errorFormKey[widget.component?.widget.formKey]?.currentState?.widget.error != null ? Colors.red : null )))]; 
    if (!readOnly && (canPost || currentView!.isEmpty) ) {
        rows.add(IconButton(icon: const Icon(Icons.add), onPressed: (){ 
          var mapped = <String, dynamic>{};
          List<String> order = <String>[];
          for (var fieldName in scheme.schema.keys) { 
            mapped[fieldName] = null; 
            order.add(fieldName);
          }
          var newView = model.View(
            name: "${widget.label} ${(oneToManiesForm[widget.component?.widget.view?.name]?[widget.name] ?? []).length + 100}", 
            actions: scheme.actions, actionPath: scheme.actionPath,
            schema: scheme.schema, order: order, isEmpty: true, 
            items: <model.Item>[model.Item(values: mapped)]);
          setState(() { 
            var k = GlobalKey<FormWidgetState>();
            if (oneToManiesForm[widget.component?.widget.view?.name]?[widget.name] == null) {
              oneToManiesForm[widget.component?.widget.view?.name]?[widget.name] = [];
            }
            var d = DataFormWidget(key: k, noTitle: true, view: newView, scroll: false, subForm: true, isOneToMany: true,
              superFormSchemaName: widget.schemaName);
            widget.filtered.add(d);
            oneToManiesForm[widget.component?.widget.view?.name]?[widget.name]?.add(d); 
          });
        }));
        if (widget.filtered.isNotEmpty) {
          rows.add(IconButton(icon: const Icon(Icons.remove), onPressed: () {
            setState(() { 
              if (widget.filtered.isNotEmpty) {
                widget.filtered.removeLast();
              }
              if ((oneToManiesForm[widget.component?.widget.view?.name]?[widget.name] ?? []).isNotEmpty) {
                oneToManiesForm[widget.component?.widget.view?.name]?[widget.name]?.removeLast(); 
              }
          });}));
        }
    }
    return rows;
  }

}

class SubSubOneToManyWidget extends StatefulWidget {
  bool show = true;
  model.Item item;
  String viewName;
  String name;
  String label;
  model.View data;
  String schemaName;
  bool readOnly;
  bool isFirst = true;
  GlobalKey? k;
  DataFormWidget? dataForm;
  SubSubOneToManyWidget ({ super.key, required this.schemaName,
   required this.label, required this.data, required this.item, required this.viewName, required this.readOnly, required this.name});
  @override
  // ignore: library_private_types_in_public_api
  SubSubOneToManyState createState() => SubSubOneToManyState();
}
class SubSubOneToManyState extends State<SubSubOneToManyWidget> {
  @override Widget build(BuildContext context) {
    if (!widget.show) {
      return Container();
    }
          widget.item.readonly = widget.readOnly;
          var view = model.View(
            id: int.parse(widget.item.values["id"]), 
            name: "${widget.label} ${(oneToManiesForm[widget.viewName]?[widget.name] ?? []).length + 1}", 
            readOnly: widget.readOnly,
            workflow: widget.data.workflow, 
            actions: widget.data.actions, 
            actionPath: widget.data.actionPath, 
            schemaName: widget.data.schemaName, 
            schema: widget.data.schema, 
            order: widget.data.order, 
            isEmpty: false, 
            items: <model.Item>[widget.item]
          );
          
         
          if (widget.isFirst) {
            widget.k = GlobalKey<FormWidgetState>();
            widget.dataForm = DataFormWidget(key: widget.k, isOneToMany: true,
            noTitle: true, view: view, scroll: false, subForm: true, 
            superFormSchemaName: widget.schemaName);
             if (oneToManiesForm[widget.viewName]?[widget.name] == null) {
              oneToManiesForm[widget.viewName]?[widget.name] = [];
            }
            oneToManiesForm[widget.viewName]?[widget.name]?.add(widget.dataForm!); 
          }
          

          if (!widget.readOnly && (currentView?.actions.contains("put") ?? false)) {
            var w = Stack( children: [ 
              widget.dataForm!,
              Positioned(top: 30,  right: 30,  child: IconButton(onPressed: (

              ) => showDialog(context: context, builder: (builder) => ConfirmBoxWidget(purpose: "delete element", validate: () async {
                try{
                  oneToManiesForm[widget.viewName]?[widget.name]?.removeWhere( (d) => d.key == widget.k);
                  widget.show = false;
                  setState(() { });
                } catch(e) { print(e); }
              })), 
              icon: const Icon(Icons.delete, color: Colors.grey)))
            ]);
            return w;
          } else {  
            return widget.dataForm!;
          }
  }
}