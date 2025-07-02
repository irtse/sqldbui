import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/widget/utils/fork/multi_dropdown/multi_dropdown.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/services/router.dart';
import 'package:sqldbui2/core/widget/form/widget/subformulary.dart';
import 'package:sqldbui2/main.dart';
import 'package:sqldbui2/model/filter.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/form/form.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/page/translate.dart';

Map<String,Map<String,String>> currentDropdown = {};
Map<String, Map<String,String>> newDropDownValue = {};
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
    String? val;
    var label ="${widget.label.replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ').toLowerCase()}${widget.require ? '*' : ''}";
    print("segvr ${widget.name}");
    try {
      label = await getOnFlow(label);
    }  catch(e) {}
    try {
      TranslateConstants.selectValue = await getOnFlow(TranslateConstants.selectValue);
    } catch(e) {}
    if ((currentDropdown[viewID ?? ""]?[widget.name] ?? widget.value  ?? widget.autofill) != null) {
      print("resf ${(currentDropdown[viewID ?? ""]?[widget.name] ?? widget.value  ?? widget.autofill)}");
      val = "${(currentDropdown[viewID ?? ""]?[widget.name] ?? widget.value  ?? widget.autofill)}".replaceAll("''", "'");
    }
    print("esfcgf ${val}");
    if (val != null) {
      widget.form[widget.name]=val;
    }
    if (val == null) {
      val = widget.readOnly ? TranslateConstants.empty : null;
    } else if (widget.translatable) {
      try {
        val = (await getOnFlow(val));
        if (val.toUpperCase() == val) {
          val = val.toUpperCase();
        } else {
          val = val.toLowerCase();
        }
      } catch(e) { print("3 ${widget.name} $e"); }
    }
    print("rddrvd ${widget.mainUrl}");
    if (widget.type.contains("enum")) {
      if (widget.readOnly) {
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
                hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                border: OutlineInputBorder(borderSide: BorderSide(color:Theme.of(context).splashColor, width: 1.0)),
                labelStyle: TextStyle(color: widget.isDark ? Theme.of(context).splashColor : Theme.of(context).secondaryHeaderColor, fontWeight: FontWeight.bold),
                focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red , width: 1.0)),
                errorBorder: OutlineInputBorder(borderSide: BorderSide(color:Colors.red, width: 1.0)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
                disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
                contentPadding: const EdgeInsets.only(top: 17, left: 20.0, right: 20.0),
                hintText: TranslateConstants.selectValue.toLowerCase(),
                labelText: label.toLowerCase(),
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
            try {
              v = await getOnFlow(item);
              if (v.toUpperCase() == v) {
                v = v.toUpperCase();
              } else {
                v = v.toLowerCase();
              }
            } catch(e) {}
          }
          items.add(DropdownMenuItem<String>(value: item, child:  Text(v, overflow: TextOverflow.ellipsis)));
        }
      }
      return DropdownButtonFormField<String>( 
          items: items, 
          isExpanded: true,
          hint: Text(TranslateConstants.selectValue.toLowerCase(), style: TextStyle(fontSize: 12, color: Colors.grey),
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
            labelStyle: TextStyle(color: widget.isDark ? Theme.of(context).splashColor : Theme.of(context).secondaryHeaderColor, fontWeight: FontWeight.bold),
            disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
            focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red , width: 1.0)),
            errorBorder: OutlineInputBorder(borderSide: BorderSide(color:Colors.red, width: 1.0)),
            fillColor: widget.readOnly ? Theme.of(context).splashColor : (
              widget.isDark ? Theme.of(context).primaryColorLight : Colors.white),
            hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
            border: OutlineInputBorder(borderSide: BorderSide(color:Theme.of(context).splashColor, width: 1.0)),
            contentPadding: const EdgeInsets.only(top: 17, left: 20.0, right: 20.0),
            labelText: label.toLowerCase(),
          ),
          validator: (String? value) {
            return (value == null || value.isEmpty) && widget.require ? "" : null;
          },
      ); 
    }
    if (widget.readOnly && !widget.empty) {
      return SizedBox(
        width: 400, 
        height: 30, 
        child: TextFormField(
                      readOnly: true,
                      initialValue: widget.value ?? widget.autofill,
                      style: TextStyle(fontSize: 14, color: widget.isDark ? Theme.of(context).highlightColor : Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red , width: 1.0)),
                        errorBorder: OutlineInputBorder(borderSide: BorderSide(color:Colors.red, width: 1.0)),
                        disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
                        errorStyle: const TextStyle(height: -2),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        fillColor: widget.readOnly ? Theme.of(context).splashColor : Colors.white,
                        hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                        border: OutlineInputBorder(borderSide: BorderSide(color:Theme.of(context).splashColor, width: 1.0)),
                        contentPadding: const EdgeInsets.only(top: 17, left: 20.0),
                        hintText: TranslateConstants.selectValue.toLowerCase(),
                        labelText: label.toLowerCase(),
                      ) ));
    }
    print("${widget.mainUrl} ${widget.url}");
    if ((val ?? "") != "") {
      return FutureBuilder<APIResponse<model.Shallowed>>(
        future: APIService().get<model.Shallowed>("${(widget.url ?? widget.mainUrl!).replaceAll("rows=all", "rows=$val")}&shallow=enable", firstAPI, null), 
        builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.Shallowed>> s) {
           return FutureBuilder<APIResponse<model.Shallowed>>(
            future: APIService().get<model.Shallowed>("${(widget.url ?? widget.mainUrl!)}&shallow=enable", true, null), 
            builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.Shallowed>> snap) {
              if (snap.data?.data != null) {
                return SubDropDownWidget(
                  label: label,
                  dp: this,
                  mainUrl: widget.mainUrl!,
                  component: widget.component,
                  form: widget.form,
                  schemaName: widget.schemaName,
                  name: widget.name,
                  readOnly: widget.readOnly,
                  require: widget.require,
                  value: val,
                  path: widget.path,
                  url: widget.url,
                  type: widget.type,
                  datas: snap.data!.data!..addAll(s.data?.data ?? []),
                  autofill: widget.autofill,
                  schema: widget.schema,
                  translatable: widget.translatable,
                  wrappers: widget.wrappers,
                );
              } else {
                return Container();
              }
            });   
        });
    }
    return FutureBuilder<APIResponse<model.Shallowed>>(
        future: APIService().get(widget.mainUrl!, true, null), 
        builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.Shallowed>> snap) {
          print("${widget.mainUrl} ${snap.data?.data}");
          if (snap.data?.data != null) {
            return SubDropDownWidget(
              label: label,
              dp: this,
              mainUrl: widget.mainUrl!,
              component: widget.component,
              form: widget.form,
              schemaName: widget.schemaName,
              name: widget.name,
              readOnly: widget.readOnly,
              require: widget.require,
              value: val,
              path: widget.path,
              url: widget.url,
              type: widget.type,
              datas: snap.data?.data ?? [],
              autofill: widget.autofill,
              schema: widget.schema,
              translatable: widget.translatable,
              wrappers: widget.wrappers,
            );
          } else {
            return Container();
          }
        });   
  }
}

// ignore: must_be_immutable
class SubDropDownWidget extends StatefulWidget {
  List<model.Shallowed> datas;
  DropDownState dp;
  final Map<String, dynamic> schema;
  final FormWidgetState? component;
  final Map<String, dynamic> form;
  final String schemaName;
  final dynamic name;
  final bool readOnly;
  final bool require;
  dynamic value;
  final String path;
  final String mainUrl;
  final String? url;
  final String type;
  final String label;
  final bool translatable;
  bool isDark = false;
  final dynamic autofill;
  GlobalKey<SubFormularyWidgetState>? wrappers;

  SubDropDownWidget ({ super.key, required this.form, required this.datas, required this.mainUrl,
    required this.schemaName, required this.name, required this.path, required this.wrappers,
    required this.autofill, required this.translatable, required this.schema, required this.dp,
    required this.readOnly, required this.value, required this.label, this.isDark = false,
    required this.require, required this.type, required this.url, required this.component});
  @override
  SubDropDownState createState() => SubDropDownState();
}
class SubDropDownState extends State<SubDropDownWidget> {
  Map<String, model.Shallowed> mapped = <String, model.Shallowed>{};
  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  MultiSelectController<String> ctrls = MultiSelectController<String>();
  
  Future<Widget> futureBuild(BuildContext context) async {
    try {
    List<DropdownItem<String>> items = [];
    int max = 0;
    var l = widget.datas.toList();
    ctrls = MultiSelectController<String>();
    for (var item in l) {
      max = item.max;
      var v = (item.label ?? item.name ?? "${item.id}").replaceAll("db", "").replaceAll("_", " ");
      v = v.replaceAll("''", "'");
      var t = items.where((e) => e.value == "${item.id}"); 
      if (!mapped.containsKey(v) && t.isEmpty){
        mapped["${item.id}"]=item;
        if((widget.component!.widget.view!.isEmpty || !(widget.component!.widget.view!.isEmpty && !item.actions.contains("post")))) {
          var vv = v;
          bool select = false;
          if ("${currentDropdown[viewID!]?[widget.name] ?? widget.value ?? widget.autofill ?? ""}" == "${item.id}") {
            widget.form[widget.name]= currentDropdown[viewID!]?[widget.name] ?? widget.value ?? widget.autofill;
            select = true;
            if (widget.url != null) {
                Future.delayed(Duration(seconds: 1), () {
                  widget.wrappers?.currentState?.setState( () { 
                    widget.wrappers?.currentState?.wrappersURL[widget.name] = widget.url!.replaceAll("rows=all", "rows=${item.id}");
                  });
                });
                
            }
          }
          try {
            if (widget.translatable || item.translatable) {
              vv = (await getOnFlow(vv));
              if (vv.toUpperCase() == vv) {
                vv = vv.toUpperCase();
              } else {
                vv = vv.toLowerCase();
              }
            }
          } catch(e) {  }
          items.add(DropdownItem<String>(value: "${item.id}", label: vv, selected: select));
          //ctrls.addItem(items.last);
        }
      }
    }
    return MultiDropdown<String>(
        max: max,
        changeFunction: (dynamic value) async {
          if (value == "") {
            return;
          }
          var filters = Filters();
          filters.add("name", Filter(value: value, column: "name"));
          load(0, 10, APIService().getFilter(widget.mainUrl, true, filters), value, items);
        },
        enabled:!widget.readOnly,
        addFunction: widget.type == "link_add" ? (String value) {
            for (var e in ctrls.items) {
              e.selected = false;
            }
            ctrls.addItem(DropdownItem<String>(value: value, label: value, selected: true));
            ctrls.closeDropdown();
            ctrls.openDropdown(null, widget.label);
            if (newDropDownValue[widget.url] == null) {
              newDropDownValue[widget.url ?? ""] = {};
            }
            newDropDownValue[widget.url ?? ""]?[widget.name] = value;
        } : null,
                        controller: ctrls,
                        singleSelect: true,
                        items: items,
                        searchEnabled: max > 10,
                        chipDecoration: ChipDecoration(
                          backgroundColor: Theme.of(context).primaryColor,
                          labelStyle: TextStyle(color: Colors.white),
                          wrap: true,
                          runSpacing: 2,
                          spacing: 10,
                        ),
                        fieldDecoration: FieldDecoration(
                          errorBorder: OutlineInputBorder(borderSide: BorderSide(color:Colors.red, width: 1.0)),
                          disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
                          labelText: widget.label,
                          backgroundColor: widget.readOnly ? Theme.of(context).splashColor 
                                     : ( widget.isDark ? Theme.of(context).primaryColorLight : Colors.white ),
                          labelStyle: TextStyle(color: widget.isDark ? Theme.of(context).splashColor : Theme.of(context).secondaryHeaderColor, fontWeight: FontWeight.bold),
                          hintText: TranslateConstants.selectValue.toLowerCase(),
                          hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                          prefixIcon: Icon(Icons.list, color: Colors.grey.shade200),
                          showClearIcon: false,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(color: Theme.of(context).splashColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        searchDecoration: SearchFieldDecoration(
                          hintText: "       ${TranslateConstants.search.toLowerCase()}",
                          border : const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          focusedBorder : const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.all(Radius.circular(5)))
                        ),
                        dropdownDecoration: DropdownDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          marginTop: 2,
                          maxHeight: 400,
                          header: Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              "       ${TranslateConstants.selectValue.toLowerCase()}",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        dropdownItemDecoration: DropdownItemDecoration(
                          backgroundColor: widget.isDark ? Theme.of(context).secondaryHeaderColor : Theme.of(context).highlightColor,
                          selectedIcon:
                              const Icon(Icons.check_box, color: Colors.green),
                          disabledIcon:
                              Icon(Icons.lock, color: Colors.grey.shade300),
                        ),
                        validator: (value) {
                          if ((value == null || value.isEmpty) && widget.require) {
                            return '';
                          }
                          return null;
                        },
                        onSelectionChange: (values) {
                          if (values.isEmpty) { return; }
                          widget.component?.widget.detectChange = true;
                          widget.form[widget.name]=mapped[values[0]]?.id;
                          try {
                            var item = mapped[values[0]];
                            if (widget.url != null && item != null) {
                              if (currentView?.isEmpty ?? false) {
                                if (currentDropdown[viewID] == null) {
                                  currentDropdown[viewID!] = {};
                                }
                                currentDropdown[viewID!]?[widget.name] = values[0];
                              }
                              widget.wrappers?.currentState?.setState( () { 
                                widget.wrappers?.currentState?.wrappersURL[widget.name] = widget.url!.replaceAll("rows=all", "rows=${item.id}");
                              }); 
                            }
                          } catch(e) {} 
                        },
                      );
    } catch(e,s) {
      print(e);
      print(s);
      return Container();
    }
  }

  Future<void> load(int start, int interval, String filter, String? value, List<DropdownItem<String>> items) async {
    if (filter == "") { return; }
    var found = false;
      var e = await APIService().get<model.Shallowed>("${widget.mainUrl}$filter&offset=$start&limit=$interval", filter != "", null);
        if (e.data != null) {
          for (var item in e.data!) {
            if (items.where( (e) => e.value == "${item.id}").isEmpty) {
              found = true;
              var v = (item.label ?? item.name ?? "${item.id}").replaceAll("db", "").replaceAll("_", " ");
              try {
                if (widget.translatable || item.translatable) {
                  v = await getOnFlow(v);
                }
              } catch(e) {}
              mapped["${item.id}"]=item;
              items.add(DropdownItem<String>(value: "${item.id}", label: v, selected: false));
              ctrls.addItem(items.last);
            }
          }
    } 
    if (ctrls.isOpen && found) {
      ctrls.closeDropdown();
      ctrls.openDropdown(value, widget.label);
    }
  }
}