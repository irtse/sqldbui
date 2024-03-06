import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/form.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

// ignore: must_be_immutable
class DropDownWidget extends StatefulWidget {
  final FormWidgetState component;
  final Map<String, dynamic> form;
  final String schemaName;
  final dynamic name;
  final bool readOnly;
  final bool require;
  dynamic value;
  final String? url;
  final String type;
  final String label;
  DropDownWidget ({ Key? key, required this.form, required this.schemaName, required this.name,
                      required this.readOnly, required this.value, required this.label,
                      required this.require, required this.type, required this.url, required this.component}): super(key: key);
  @override
  _DropDownState createState() => _DropDownState();
}
class _DropDownState extends State<DropDownWidget> {
  @override Widget build(BuildContext context) {
    if (widget.type.contains("enum") || widget.url == null) {
      if (widget.readOnly) {
      return SizedBox(width: 400, height: 30, child: TextFormField(
                      readOnly: true,
                      initialValue: widget.value,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        filled: true,
                        errorStyle: const TextStyle(height: -2),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        fillColor: widget.readOnly ? Theme.of(context).splashColor : Colors.white,
                        hintStyle: const TextStyle(fontSize: 12, ),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.only(top: 17, left: 20.0, right: 20.0),
                        hintText: "enter your ${widget.label.replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ').toLowerCase()}",
                        labelText: "${widget.label.replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ').toLowerCase()}${widget.require ? '*' : ''}",
                      ) ));
      }
      var items = <DropdownMenuItem<String>>[];
      var values = widget.type.replaceAll("enum:", "").split(",");
      for (var item in values) { 
        if (item == widget.value) { items.insert(0, DropdownMenuItem<String>(child: Text(item), value: item,)); 
        } else { items.add(DropdownMenuItem<String>(value: item,child: Text(item),));  }
        
      }
      return DropdownButtonFormField<String>( items: items, 
        value: widget.value ?? ( values.isNotEmpty ? values[0] : null),
        style: const TextStyle(fontSize: 14, color: Colors.black),
        onChanged: (value) {
          widget.component.widget.detectChange = true;
          if (value == null) { widget.form[widget.name]=null;
          } else { widget.form[widget.name]=value; }
        },
        onSaved: (value) {
          if (value == null) { widget.form[widget.name]=null;
          } else { widget.form[widget.name]=value; }
        },
        decoration: InputDecoration(
          errorStyle: const TextStyle(height: -2),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          filled: true,
          fillColor: widget.readOnly ? Theme.of(context).splashColor : Colors.white,
          hintStyle: const TextStyle(fontSize: 12, ),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.only(top: 17, left: 20.0, right: 20.0),
          labelText: widget.label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' '),
        ),
        validator: (String? value) {
          return (value == null || value.isEmpty) && widget.require ? 'enter a proper value.' : null;
        },
      );
    }
    if (widget.readOnly) {
      return SizedBox(width: 400, height: 30, child: TextFormField(
                      readOnly: true,
                      initialValue: widget.value,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        filled: true,
                        errorStyle: const TextStyle(height: -2),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        fillColor: widget.readOnly ? Theme.of(context).splashColor : Colors.white,
                        hintStyle: const TextStyle(fontSize: 12, ),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.only(top: 17, left: 20.0, right: 20.0),
                        hintText: "enter your ${widget.label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')}",
                        labelText: widget.label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' '),
                      ) ));
    }
    return FutureBuilder<APIResponse<model.Shallowed>>(
        future: APIService().get(widget.url!, true, null), 
        builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.Shallowed>> snap) {
          List<DropdownMenuItem<String>> items = <DropdownMenuItem<String>>[];
          String? initialValue;
          model.Shallowed? first;
          Map<String, model.Shallowed> mapped = <String, model.Shallowed>{};
          if (snap.hasData && snap.data!.data != null) {
            initialValue = "";
            if(widget.form[widget.name] != null && !widget.component.widget.view!.isEmpty) {
              for (var data in snap.data!.data!) {
                if (data.id == widget.form[widget.name]) { first = data; initialValue=data.name ?? "${data.id!}"; break; }
              }
            } else {  first = snap.data!.data![0]; initialValue = first.label ?? first.name ?? "${first.id}";  }
            if (first != null && first.linkPath != "" && widget.url != null && !widget.component.widget.wrappersURL.containsKey(widget.name)) {
                Future.delayed(const Duration(microseconds: 100), () {
                  if (!widget.component.widget.wrappersURL.containsKey(widget.name)) {
                    widget.component.setState( () { 
                      globalFormsKey = <GlobalKey<FormState>>[];
                        widget.component.widget.wrappersURL[widget.name] = "${widget.url!.replaceAll("rows=all", "rows=${first!.id}")}";
                    }); 
                  }
                   
              });
            }
            for (var item in snap.data!.data!) {
              var v = item.name ?? "${item.id}";
              if (!mapped.containsKey(v)) {
                mapped[v]=item;
                if(widget.component.widget.view!.isEmpty || !(widget.component.widget.view!.isEmpty && !item.actions.contains("post"))) {
                  items.add(DropdownMenuItem<String>(value: v, child: Text(v),));
                }
              }
            }
          }
          return DropdownButtonFormField<String>(
              value: widget.value ?? initialValue,
              items: items, 
              style: const TextStyle(fontSize: 14, color: Colors.black),
              onChanged: (value) {
                widget.component.widget.detectChange = true;
                if (value == null) { widget.form[widget.name]=null;
                } else { widget.form[widget.name]=mapped[value]!.id; }
                var item = mapped[value];
                if (item != null && item.linkPath != "") {
                  widget.component.setState( () { 
                    globalFormsKey = <GlobalKey<FormState>>[];
                    widget.component.widget.wrappersURL[widget.name] = "${widget.url!.replaceAll("rows=all", "rows=${item.id}")}";
                  }); 
                }
              },
              onSaved: (value) {
                if (value == null) { widget.form[widget.name]=null;
                } else if (mapped[value] != null) { widget.form[widget.name]=mapped[value]!.id; }
              },
              decoration: InputDecoration(
                filled: true,
                border: const OutlineInputBorder(),
                errorStyle: const TextStyle(height: -2),
                hintStyle: const TextStyle(fontSize: 12),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                contentPadding: const EdgeInsets.only(top: 17, left: 20.0, right: 20.0),
                fillColor: widget.readOnly ? Theme.of(context).splashColor : Colors.white,
                labelText: "${widget.label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')}${widget.require ? '*' : ''}",
              ),
              validator: (String? value) {
                return (value == null || value.isEmpty) && widget.require ? 'enter a proper value.' : null;
              },
            );
        });
  }
}