import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/form.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

// ignore: must_be_immutable
class DropDownWidget extends StatefulWidget {
  final FormWidgetState? component;
  final Map<String, dynamic> form;
  final String schemaName;
  final dynamic name;
  final bool readOnly;
  final bool require;
  dynamic value;
  final String? url;
  final String type;
  final String label;
  bool isDark = false;
  DropDownWidget ({ Key? key, required this.form, required this.schemaName, required this.name,
                      required this.readOnly, required this.value, required this.label, this.isDark = false,
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
                      style: TextStyle(fontSize: 14, color: widget.isDark ? Theme.of(context).highlightColor : Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        suffixIcon: widget.type.contains("enum") ? const Icon(Icons.format_list_numbered) : const Icon(Icons.link),
                        errorStyle: const TextStyle(height: -2),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        fillColor: widget.readOnly ? Theme.of(context).splashColor : (widget.isDark ? Theme.of(context).primaryColorLight : Colors.white),
                        hintStyle: TextStyle(fontSize: 12, color: Theme.of(context).splashColor),
                        border: const OutlineInputBorder(),
                        labelStyle: TextStyle(color: widget.isDark ? Theme.of(context).splashColor : Theme.of(context).secondaryHeaderColor),
                        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 1.0)),
                        contentPadding: const EdgeInsets.only(top: 17, left: 20.0, right: 20.0),
                        hintText: "enter ${widget.schemaName.replaceAll("_", " ").replaceAll("db", "")} ${widget.label.replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ').toLowerCase()}",
                        labelText: "${widget.label.replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ').toLowerCase()}${widget.require ? '*' : ''}",
                      ) ));
      }
      var items = <DropdownMenuItem<String>>[];
      var values = widget.type.replaceAll("enum__", "").split("_");
      for (var item in values) { 
        if (items.where((element) => element.value == item).isEmpty) {
          items.add(DropdownMenuItem<String>(value: item, child:  Text(item, overflow: TextOverflow.ellipsis,),));
        }
      }

      return DropdownButtonFormField<String>( items: items, 
        hint: Text("select a ${widget.schemaName.replaceAll("db", "").replaceAll("_", " ")}...", overflow: TextOverflow.ellipsis,),
        value: widget.value ?? ( values.isNotEmpty ? values[0] : null),
        style: TextStyle(fontSize: 14, color: widget.isDark ? Theme.of(context).highlightColor : Colors.black),
        onChanged: (value) {
          widget.component?.widget.detectChange = true;
          if (value == null) { widget.form[widget.name]=null;
          } else { widget.form[widget.name]=value; }
        },
        onSaved: (value) {
          if (value == null) { widget.form[widget.name]=null;
          } else { widget.form[widget.name]=value; }
        },
        dropdownColor: widget.isDark ? Theme.of(context).secondaryHeaderColor : Theme.of(context).highlightColor,
        decoration: InputDecoration(
          suffixIconColor: Theme.of(context).primaryColor,
          errorStyle: const TextStyle(height: -2),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          filled: true,
          labelStyle: TextStyle(color: widget.isDark ? Theme.of(context).splashColor : Theme.of(context).secondaryHeaderColor),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 1.0)),
          fillColor: widget.readOnly ? Theme.of(context).splashColor : (widget.isDark ? Theme.of(context).primaryColorLight : Colors.white),
          hintStyle: TextStyle(fontSize: 12, color: Theme.of(context).splashColor),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.only(top: 17, left: 20.0, right: 20.0),
          labelText: "${widget.label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')}${widget.require ? '*' : ''}",
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
                      style: TextStyle(fontSize: 14, color: widget.isDark ? Theme.of(context).highlightColor : Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 1.0)),
                        errorStyle: const TextStyle(height: -2),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        fillColor: widget.readOnly ? Theme.of(context).splashColor : Colors.white,
                        hintStyle: TextStyle(fontSize: 12, color: Theme.of(context).splashColor),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.only(top: 17, left: 20.0, right: 20.0),
                        hintText: "enter your ${widget.label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')}",
                        labelText: "${widget.label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')}${widget.require ? '*' : ''}",
                      ) ));
    }
    return FutureBuilder<APIResponse<model.Shallowed>>(
        future: APIService().get(widget.url!, true, null), 
        builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.Shallowed>> snap) {
          List<DropdownMenuItem<String>> items = <DropdownMenuItem<String>>[];
          String? initialValue;
          Map<String, model.Shallowed> mapped = <String, model.Shallowed>{};
          if (snap.hasData && snap.data!.data != null) {
            initialValue = "";
            if (widget.component != null) {
              if(widget.form[widget.name] != null && !widget.component!.widget.view!.isEmpty) {
              for (var data in snap.data!.data!) {
                if (data.id == widget.form[widget.name]) { initialValue=data.name ?? "${data.id!}"; break; }
              }
            } else {  initialValue = null;  }
              for (var item in snap.data!.data!) {
                var v = item.name ?? "${item.id}";
                v = v.replaceAll("db", "").replaceAll("_", " ");
                if (!mapped.containsKey(v)) {
                  mapped[v]=item;
                  if(widget.component!.widget.view!.isEmpty || !(widget.component!.widget.view!.isEmpty && !item.actions.contains("post"))) {
                    items.add(DropdownMenuItem<String>(value: v, child: Text(v, overflow: TextOverflow.ellipsis,),));
                  }
                }
              }
            }
          }
          return DropdownButtonFormField<String>(
              hint: Text("select a ${widget.schemaName.replaceAll("db", "").replaceAll("_", " ")}...", overflow: TextOverflow.ellipsis,),
              value: widget.value ?? initialValue,
              items: items, 
              dropdownColor: widget.isDark ? Theme.of(context).secondaryHeaderColor : Theme.of(context).highlightColor,
              style: TextStyle(fontSize: 14, color: widget.isDark ? Theme.of(context).highlightColor : Colors.black),
              onChanged: (value) {
                widget.component?.widget.detectChange = true;
                if (value == null) { widget.form[widget.name]=null;
                } else { widget.form[widget.name]=mapped[value]!.id; }
                var item = mapped[value];
                if (widget.url != null && item != null && item.linkPath != "") {
                  widget.component?.setState( () { 
                    widget.component?.widget.wrappersURL[widget.name] = widget.url!.replaceAll("rows=all", "rows=${item.id}");
                  }); 
                }
              },
              onSaved: (value) {
                if (value == null) { widget.form[widget.name]=null;
                } else if (mapped[value] != null) { widget.form[widget.name]=mapped[value]!.id; }
              },
              decoration: InputDecoration(
                filled: true,
                enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 1.0)),
                border: const OutlineInputBorder(),
                errorStyle: const TextStyle(height: -2),
                hintStyle: TextStyle(fontSize: 12, color: Theme.of(context).splashColor),
                labelStyle: TextStyle(color: widget.isDark ? Theme.of(context).splashColor : Theme.of(context).secondaryHeaderColor),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                contentPadding: const EdgeInsets.only(top: 17, left: 20.0, right: 20.0),
                fillColor: widget.readOnly ? Theme.of(context).splashColor : ( widget.isDark ? Theme.of(context).primaryColorLight : Colors.white ),
                labelText: "${widget.label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')}${widget.require ? '*' : ''}",
              ),
              validator: (String? value) {
                return (value == null || value.isEmpty) && widget.require ? 'enter a proper value.' : null;
              },
            );
        });
  }
}