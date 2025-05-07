import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/services/router.dart';
import 'package:sqldbui2/core/widget/form/widget/subformulary.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/form/form.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/page/translate.dart';

// ignore: must_be_immutable
class DropDownWidget extends StatefulWidget {
  final FormWidgetState? component;
  final Map<String, dynamic> form;
  final Map<String, dynamic> schema;
  final String schemaName;
  final dynamic name;
  final bool readOnly;
  final bool require;
  dynamic value;
  final String path;
  final String? mainUrl;
  final String? url;
  final String type;
  final String label;
  final bool translatable;
  bool isDark = false;
  bool empty = false;
  final dynamic autofill;
  GlobalKey<SubFormularyWidgetState>? wrappers;
  DropDownWidget ({ super.key, required this.form, required this.schemaName, required this.name, 
                    required this.path, required this.translatable, required this.schema,
                    required this.mainUrl, required this.readOnly, required this.value, required this.wrappers,
                    required this.label, this.isDark = false, required this.empty, required this.autofill,
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
    if (widget.type.contains("enum") || widget.mainUrl == null) {
      if (widget.readOnly) {
        var val = widget.value  ?? widget.autofill;
        if (val == null) {
          val = widget.readOnly ? TranslateConstants.empty : null;
        } else if (widget.translatable) {
          val = await getOnFlow(val);
        }
        return SizedBox(width: 400, height: 30, 
          child: TextFormField(
            readOnly: true,
            initialValue: val,
            style: TextStyle(fontSize: 14, color: widget.isDark ? Theme.of(context).highlightColor : Colors.black),
            decoration: InputDecoration(
              filled: true,
              suffixIcon: InkWell( mouseCursor: widget.path != "" ? null : MouseCursor.defer,
                onTap: () { if (widget.path != "") { AppRouter.navigateTo(widget.path); } }, 
                child: widget.type.contains("enum") ? Icon(Icons.format_list_numbered, color: Theme.of(context).secondaryHeaderColor) 
                  : Icon(Icons.link, color: widget.path == "" ? Theme.of(context).secondaryHeaderColor : Theme.of(context).primaryColor,)),
                errorStyle: const TextStyle(height: -2),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                fillColor: widget.readOnly ? Theme.of(context).splashColor : (widget.isDark ? Theme.of(context).primaryColorLight : Colors.white),
                hintStyle: TextStyle(fontSize: 12, color: Theme.of(context).splashColor),
                border: const OutlineInputBorder(),
                labelStyle: TextStyle(color: widget.isDark ? Theme.of(context).splashColor : Theme.of(context).secondaryHeaderColor),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
                contentPadding: const EdgeInsets.only(top: 17, left: 20.0, right: 20.0),
                hintText: TranslateConstants.selectValue.toLowerCase(),
                labelText: (await getOnFlow("${widget.label.replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ').toLowerCase()}${widget.require ? '*' : ''}")).toLowerCase(),
              )
            )
          );
      }
      var items = <DropdownMenuItem<String>>[];
      var values = widget.type.replaceAll("enum__", "").split("_");
      for (var item in values) { 
        if (items.where((element) => element.value == item).isEmpty) {
          var v = item;
          if (widget.translatable) {
            v = await getOnFlow(item);
          }
          items.add(DropdownMenuItem<String>(value: item, child:  Text(v.toLowerCase(), overflow: TextOverflow.ellipsis)));
        }
      }
      return DropdownButtonFormField<String>( 
          items: items, 
          isExpanded: true,
          hint: Text("${TranslateConstants.select} ${await getOnFlow(widget.label.replaceAll("db", "").replaceAll("_", " "))}...", 
            overflow: TextOverflow.ellipsis, softWrap: true),
          value: widget.value ?? (widget.autofill != null ? "${widget.autofill}" : null),
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
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
            fillColor: widget.readOnly ? Theme.of(context).splashColor : (
              widget.isDark ? Theme.of(context).primaryColorLight : Colors.white),
            hintStyle: TextStyle(fontSize: 12, color: Theme.of(context).splashColor),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.only(top: 17, left: 20.0, right: 20.0),
            labelText: (await getOnFlow("${widget.label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')}${widget.require ? '*' : ''}")).toLowerCase(),
          ),
          validator: (String? value) {
            return (value == null || value.isEmpty) && widget.require ? "" : null;
          },
      ); 
    }
    if (widget.readOnly && !widget.empty) {
      return SizedBox(width: 400, height: 30, child: TextFormField(
                      readOnly: true,
                      initialValue: widget.value ?? widget.autofill,
                      style: TextStyle(fontSize: 14, color: widget.isDark ? Theme.of(context).highlightColor : Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
                        errorStyle: const TextStyle(height: -2),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        fillColor: widget.readOnly ? Theme.of(context).splashColor : Colors.white,
                        hintStyle: TextStyle(fontSize: 12, color: Theme.of(context).splashColor),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.only(top: 17, left: 20.0),
                        hintText: TranslateConstants.selectValue.toLowerCase(),
                        labelText: (await getOnFlow("${widget.label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')}${widget.require ? '*' : ''}")).toLowerCase(),
                      ) ));
    }
    if (widget.empty && widget.value != null) {
      widget.component?.widget.detectChange = true;
      widget.form[widget.name]=widget.value;
      if (widget.url != null) {
        if (widget.wrappers?.currentState?.wrappersURL[widget.name] == null) {
          Future.delayed(const Duration(seconds: 1), () {
            widget.component?.setState( () {
              widget.component?.widget.hideField.add(widget.name);
              widget.wrappers?.currentState?.wrappersURL[widget.name] = widget.url!.replaceAll("rows=all", "rows=${widget.value}");
            });
          });
        }  
      }
      return Container();
    }
    return FutureBuilder<APIResponse<model.Shallowed>>(
        future: APIService().get(widget.mainUrl!, firstAPI, null), 
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
            autofill: widget.autofill,
            schema: widget.schema,
            translatable: widget.translatable,
            wrappers: widget.wrappers,
          );
        });
  }
}

// ignore: must_be_immutable
class SubDropDownWidget extends StatefulWidget {
  final List<model.Shallowed>? data;
  final FormWidgetState? component;
  final Map<String, dynamic> form;
  final Map<String, dynamic> schema;
  final String schemaName;
  final dynamic name;
  final bool readOnly;
  final bool require;
  dynamic value;
  final String path;
  final String? url;
  final String type;
  final String label;
  final bool translatable;
  bool isDark = false;
  final dynamic autofill;
  GlobalKey<SubFormularyWidgetState>? wrappers;

  SubDropDownWidget ({ super.key, required this.form, required this.data,
    required this.schemaName, required this.name, required this.path, required this.wrappers,
    required this.autofill, required this.translatable, required this.schema,
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
    if (widget.data != null && widget.component != null) {
      for (var item in widget.data!) {
        bool f = item.schema["name"]?.translatable ?? false;
        var v = (item.label ?? item.name ?? "${item.id}").replaceAll("db", "").replaceAll("_", " ");
        var t = items.where((element) => element.value == v);        
        if (!mapped.containsKey(v) && t.isEmpty){
          mapped["${item.id}"]=item;
          if((widget.component!.widget.view!.isEmpty || !(widget.component!.widget.view!.isEmpty && !item.actions.contains("post")))
            && items.where((element) => element.value == v).isEmpty) {
            var vv = v;
            if (widget.translatable && f) {
              vv = await getOnFlow(vv);
            }
            items.add(DropdownMenuItem<String>(value: "${item.id}", child: Text(vv.toLowerCase(), overflow: TextOverflow.ellipsis)));
          }
        }
      }
    }
    return DropdownButtonFormField<String>(
      isExpanded: true,
      hint: Text("${TranslateConstants.select} ${await getOnFlow(widget.label.replaceAll("db", "").replaceAll("_", " "))}...", 
        overflow: TextOverflow.ellipsis, softWrap: true),
      value: widget.value ?? (widget.autofill != null ? "${widget.autofill}" : null),
      items: items, 
      dropdownColor: widget.isDark ? Theme.of(context).secondaryHeaderColor : Theme.of(context).highlightColor,
      style: TextStyle(fontSize: 14, color: widget.isDark ? Theme.of(context).highlightColor 
                                                          : Colors.black, overflow: TextOverflow.ellipsis),
      onChanged: (value) {
        widget.component?.widget.detectChange = true;
        if (value == null) { widget.form[widget.name]=null;
        } else { widget.form[widget.name]=mapped[value]?.id; }
        var item = mapped[value];
        if (widget.url != null && item != null && widget.wrappers?.currentState?.wrappersURL[widget.name] == null) {
          widget.wrappers?.currentState?.setState( () { 
            widget.wrappers?.currentState?.wrappersURL[widget.name] = widget.url!.replaceAll("rows=all", "rows=${item.id}");
          }); 
        }
      },
      onSaved: (value) {
        if (value == null) { widget.form[widget.name]=null;
        } else if (mapped[value] != null) { widget.form[widget.name]=mapped[value]!.id; }
      },
      decoration: InputDecoration(
        filled: true, isDense: true,
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
        border: const OutlineInputBorder(),
        errorStyle: const TextStyle(height: -2, fontSize: 0),
        hintStyle: TextStyle(fontSize: 12, color: Theme.of(context).splashColor),
        labelStyle: TextStyle(color: widget.isDark ? Theme.of(context).splashColor : Theme.of(context).secondaryHeaderColor),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.only(top: 17, left: 20.0),
        fillColor: widget.readOnly ? Theme.of(context).splashColor 
                                     : ( widget.isDark ? Theme.of(context).primaryColorLight : Colors.white ),
        labelText: (await getOnFlow("${widget.label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ')}${widget.require ? '*' : ''}")).toLowerCase(),
      ),
      validator: (String? value) {
        return (value == null || value.isEmpty) && widget.require && !widget.readOnly ? "" : null;
      },
    ); 
  }
}