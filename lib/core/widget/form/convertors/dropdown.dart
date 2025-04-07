import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/services/router.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/form/form.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/page/translate.dart';

// ignore: must_be_immutable
class DropDownWidget extends StatefulWidget {
  final FormWidgetState? component;
  final Map<String, dynamic> form;
  final String schemaName;
  final dynamic name;
  final bool readOnly;
  final bool require;
  dynamic value;
  final String path;
  final String? url;
  final String type;
  final String label;
  bool isDark = false;
  DropDownWidget ({ super.key, required this.form, required this.schemaName, required this.name, required this.path,
                      required this.readOnly, required this.value, required this.label, this.isDark = false,
                      required this.require, required this.type, required this.url, required this.component});
  @override
  DropDownState createState() => DropDownState();
}
class DropDownState extends State<DropDownWidget> {
  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    if (widget.type.contains("enum") || widget.url == null) {
      if (widget.readOnly) {
        return SizedBox(width: 400, height: 30, child: TextFormField(
                      readOnly: true,
                      initialValue: widget.value != null ? await getOnFlow(widget.value) : null,
                      style: TextStyle(fontSize: 14, color: widget.isDark ? Theme.of(context).highlightColor : Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        suffixIcon: InkWell( mouseCursor: widget.path != "" ? null : MouseCursor.defer,
                          onTap: () { if (widget.path != "") { AppRouter.navigateTo(widget.path); } }, child: 
                          widget.type.contains("enum") ? Icon(Icons.format_list_numbered, color: Theme.of(context).secondaryHeaderColor) 
                          : Icon(Icons.link, color: widget.path == "" ? Theme.of(context).secondaryHeaderColor : Theme.of(context).primaryColor,)),
                        errorStyle: const TextStyle(height: -2),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        fillColor: widget.readOnly ? Theme.of(context).splashColor : (widget.isDark ? Theme.of(context).primaryColorLight : Colors.white),
                        hintStyle: TextStyle(fontSize: 12, color: Theme.of(context).splashColor),
                        border: const OutlineInputBorder(),
                        labelStyle: TextStyle(color: widget.isDark ? Theme.of(context).splashColor : Theme.of(context).secondaryHeaderColor),
                        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 1.0)),
                        contentPadding: const EdgeInsets.only(top: 17, left: 20.0, right: 20.0),
                        hintText: (await getOnFlow("enter ${widget.schemaName.replaceAll("_", " ").replaceAll("db", "")} ${widget.label.replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ').toLowerCase()}")).toLowerCase(),
                        labelText: (await getOnFlow("${widget.label.replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ').toLowerCase()}${widget.require ? '*' : ''}")).toLowerCase(),
                      ) ));
      }
      var items = <DropdownMenuItem<String>>[];
      var values = widget.type.replaceAll("enum__", "").split("_");
      for (var item in values) { 
        if (items.where((element) => element.value == item).isEmpty) {
          items.add(DropdownMenuItem<String>(value: item, child:  Text(await getOnFlow(item), overflow: TextOverflow.ellipsis,),));
        }
      }
      var found = items.where((element) => element.value == widget.value);
      if (found.isEmpty && widget.value != null) {
        items.add(DropdownMenuItem<String>(value: widget.value, child: Text(await getOnFlow(widget.value), overflow: TextOverflow.ellipsis,),));
      }
      return DropdownButtonFormField<String>( items: items, 
        isExpanded: true,
        hint: Text(await getOnFlow("${"select a"} ${widget.label.replaceAll("db", "").replaceAll("_", " ")}..."), 
          overflow: TextOverflow.ellipsis, softWrap: true),
        value: await getOnFlow(widget.value),
        style: TextStyle(fontSize: 14, 
          color: widget.isDark ? Theme.of(context).highlightColor : Colors.black, 
          overflow: TextOverflow.ellipsis),
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
        decoration: InputDecoration( isDense: true,
          suffixIconColor: Theme.of(context).primaryColor,
          errorStyle: const TextStyle(height: -2),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          filled: true,
          constraints: const BoxConstraints(minWidth: 0),
          labelStyle: TextStyle(color: widget.isDark ? Theme.of(context).splashColor : Theme.of(context).secondaryHeaderColor),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 1.0)),
          fillColor: widget.readOnly ? Theme.of(context).splashColor : (
            widget.isDark ? Theme.of(context).primaryColorLight : Colors.white),
          hintStyle: TextStyle(fontSize: 12, color: Theme.of(context).splashColor),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.only(top: 17, left: 20.0, right: 20.0),
          labelText: (await getOnFlow("${widget.label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')}${widget.require ? '*' : ''}")).toLowerCase(),
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
                        contentPadding: const EdgeInsets.only(top: 17, left: 20.0),
                        hintText: (await getOnFlow("enter your ${widget.label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')}")).toLowerCase(),
                        labelText: (await getOnFlow("${widget.label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')}${widget.require ? '*' : ''}")).toLowerCase(),
                      ) ));
    }
    return FutureBuilder<APIResponse<model.Shallowed>>(
        future: APIService().get(widget.url!, firstAPI, null), 
        builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.Shallowed>> snap) {
          return SubDropDownWidget(
            label: widget.label,
            component: widget.component,
            form: widget.form,
            schemaName: widget.schemaName,
            name: widget.name,
            readOnly: widget.readOnly,
            require: widget.require,
            value: widget.value,
            path: widget.path,
            url: widget.url,
            type: widget.type,
            data: snap.data?.data,
          );
        });
  }
}

// ignore: must_be_immutable
class SubDropDownWidget extends StatefulWidget {
  final List<model.Shallowed>? data;
  final FormWidgetState? component;
  final Map<String, dynamic> form;
  final String schemaName;
  final dynamic name;
  final bool readOnly;
  final bool require;
  dynamic value;
  final String path;
  final String? url;
  final String type;
  final String label;
  bool isDark = false;
  SubDropDownWidget ({ super.key, required this.form, required this.data,
    required this.schemaName, required this.name, required this.path,
    required this.readOnly, required this.value, required this.label, this.isDark = false,
    required this.require, required this.type, required this.url, required this.component});
  @override
  SubDropDownState createState() => SubDropDownState();
}
class SubDropDownState extends State<SubDropDownWidget> {
  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    List<DropdownMenuItem<String>> items = <DropdownMenuItem<String>>[];
          Map<String, model.Shallowed> mapped = <String, model.Shallowed>{};
          if (widget.data != null) {
              if (widget.component != null) {
              for (var item in widget.data!) {
                var v = item.name ?? "${item.id}";
                v = v.replaceAll("db", "").replaceAll("_", " ");
                var t = items.where((element) => element.value == v);
                if (!mapped.containsKey(v) && t.isEmpty){
                  mapped[v]=item;
                  if((widget.component!.widget.view!.isEmpty || !(widget.component!.widget.view!.isEmpty && !item.actions.contains("post")))
                  && items.where((element) => element.value == v,).isEmpty) {
                    items.add(DropdownMenuItem<String>(value: v, child: Text(await getOnFlow(v), overflow: TextOverflow.ellipsis,),));
                  }
                }
              }
            }
          }
          return DropdownButtonFormField<String>(
              isExpanded: true,
              hint: Text(await getOnFlow("${"select a "}${widget.label.replaceAll("db", "").replaceAll("_", " ")}..."), 
                overflow: TextOverflow.ellipsis, softWrap: true,),
              value: widget.value,
              items: items, 
              dropdownColor: widget.isDark ? Theme.of(context).secondaryHeaderColor : Theme.of(context).highlightColor,
              style: TextStyle(fontSize: 14, color: widget.isDark ? Theme.of(context).highlightColor : Colors.black, overflow: TextOverflow.ellipsis),
              onChanged: (value) {
                widget.component?.widget.detectChange = true;
                if (value == null) { widget.form[widget.name]=null;
                } else { widget.form[widget.name]=mapped[value]!.id; }
                var item = mapped[value];
                if (widget.url != null && item != null) {
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
                filled: true, isDense: true,
                enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 1.0)),
                border: const OutlineInputBorder(),
                errorStyle: const TextStyle(height: -2, fontSize: 0),
                hintStyle: TextStyle(fontSize: 12, color: Theme.of(context).splashColor),
                labelStyle: TextStyle(color: widget.isDark ? Theme.of(context).splashColor : Theme.of(context).secondaryHeaderColor),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                contentPadding: const EdgeInsets.only(top: 17, left: 20.0),
                fillColor: widget.readOnly ? Theme.of(context).splashColor : ( widget.isDark ? Theme.of(context).primaryColorLight : Colors.white ),
                labelText: (await getOnFlow("${widget.label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')}${widget.require ? '*' : ''}")).toLowerCase(),
              ),
              validator: (String? value) {
                return (value == null || value.isEmpty) && widget.require && !widget.readOnly ? 'enter a proper value.' : null;
              },
            ); 
  }
}