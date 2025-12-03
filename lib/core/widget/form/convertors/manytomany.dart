import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/widget/form/convertors/convertor.dart';
import 'package:sqldbui2/model/filter.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/form/form.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/page/translate.dart';
import 'package:sqldbui2/core/widget/utils/fork/multi_dropdown/multi_dropdown.dart';

// ignore: must_be_immutable
class ManyToManyWidget extends StatefulWidget {
  final Map<String, dynamic> form;
  final Map<String, dynamic> schema;
  final String schemaName;
  final dynamic name;
  final bool readOnly;
  final bool require;
  dynamic value;
  final FormWidgetState? component;
  final String? mainURL;
  final String? url;
  final String type;
  final String label;
  final bool translatable;
  var isFilled = true;
  ManyToManyWidget ({ required this.form, required this.schemaName, required this.name, required this.schema,
                      required this.readOnly, required this.value, required this.label, required this.translatable,
                      required this.require, required this.type, required this.url, required this.component,
                      required this.mainURL}): super(key: GlobalKey());
  @override
  // ignore: library_private_types_in_public_api
  ManyToManyState createState() => ManyToManyState();
}
class ManyToManyState extends State<ManyToManyWidget> {
  List<DataFormWidget> widgets = <DataFormWidget>[];
  @override Widget build(BuildContext context) {
    var actions = widget.component?.widget.view?.actions ?? currentView?.actions ?? [];
    var scheme = widget.schema[widget.name];
    if (scheme == null) { return Container(); }
    var readOnly = widget.readOnly || (!actions.contains("post") && !actions.contains("put")) || (mainForm.currentState?.widget.view?.readOnly ?? false);
    if ((widget.url ?? "") != "") {
      if (widget.value != null && widget.value is List && widget.value.isNotEmpty) {
        List<String> ids = [];
        for (var v in widget.value) {
          try {
            if (v is model.Shallowed && v.id != null) {
              ids.add("${v.id}");
            } else if (v["id"] != null) {
              ids.add("${v["id"]}");
            }
          } catch(e) {}
        }
        if (ids.isNotEmpty) {
          return FutureBuilder<APIResponse<model.Shallowed>>(
          future: APIService().get(widget.url!.replaceAll("rows=all", "rows=${ids.join(",")}"), false, null), 
          builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.Shallowed>> s) {
          return FutureBuilder<APIResponse<model.Shallowed>>(
            future: APIService().get(widget.url!, false, null), 
            builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.Shallowed>> snap) {
                if (snap.data?.data != null) {
                  return SubManyToManyWidget(
                    mainURL: widget.mainURL,
                    form: widget.form,
                    dp: this,
                    schemaName: widget.schemaName,
                    name: widget.name,
                    readOnly: readOnly,
                    value: widget.value,
                    component: widget.component,
                    datas: snap.data!.data!..addAll(s.data?.data ?? []),
                    require: widget.require,
                    label: widget.label,
                    type: widget.type,
                    url: widget.url,
                    translatable: widget.translatable,
                  );
                }
                return Container();
            });
          });
        }
      }
      return FutureBuilder<APIResponse<model.Shallowed>>(
        future: APIService().get(widget.url ?? "", false, null), 
        builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.Shallowed>> snap) {
            if (snap.data?.data != null) {
              return SubManyToManyWidget(
                form: widget.form,
                mainURL: widget.mainURL,
                dp: this,
                schemaName: widget.schemaName,
                name: widget.name,
                readOnly: widget.readOnly,
                value: widget.value,
                component: widget.component,
                datas: snap.data!.data,
                require: widget.require,
                label: widget.label,
                type: widget.type,
                url: widget.url,
                translatable: widget.translatable,
              );
            }
            return Container();
            
        });
      }
      return Container();
    }
}

// ignore: must_be_immutable
class SubManyToManyWidget extends StatefulWidget {
  final String? mainURL;
  final Map<String, dynamic> form;
  final String schemaName;
  final dynamic name;
  final ManyToManyState dp;
  final bool readOnly;
  final bool require;
  final bool translatable;
  dynamic value;
  final FormWidgetState? component;
  final String? url;
  final String type;
  final String label;
  var isFilled = true;
  List<model.Shallowed>? datas;
  SubManyToManyWidget ({ required this.datas, required this.form, required this.schemaName, required this.name,
                      required this.readOnly, required this.value, required this.label, required this.translatable,
                      required this.require, required this.type, required this.url, required this.component,
                      required this.dp, required this.mainURL}): super(key: GlobalKey<State<SubManyToManyWidget>>());
  @override
  // ignore: library_private_types_in_public_api
  _SubManyToManyState createState() => _SubManyToManyState();
}
class _SubManyToManyState extends State<SubManyToManyWidget> {
  List<DataFormWidget> widgets = <DataFormWidget>[];
  @override Widget build(BuildContext context) {
    if ((widget.component?.widget.view?.rules ?? []).where( (r) => r.trigger == widget.name).isNotEmpty) {
      for (var r in (widget.component?.widget.view?.rules ?? [])) {
        if (r.trigger == widget.name) {
          r.key = widget.key as GlobalKey<State<SubManyToManyWidget>>;
          /*if (r.value != null && r.value != "") {
            widget.value = "${r.value}".split(",").map( (e) => { "name" : e, });
          }*/
        }
      }
    }
  return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }

  MultiSelectController<Map<String, dynamic>> ctrls = MultiSelectController<Map<String, dynamic>>();

  Future<Widget> futureBuild(BuildContext context) async {
    List<DropdownItem<Map<String, dynamic>>> items = <DropdownItem<Map<String, dynamic>>>[];
    ctrls = MultiSelectController<Map<String, dynamic>>();
    widget.value = (widget.form[widget.name]) ?? widget.value ?? []; 
    saveChange(widget.component?.widget.view, widget.form, widget.name, widget.value);
    var l = widget.label;
    try {
      l = await getOnFlow(widget.label);
    } catch(e) {}
    int max = 0;
    if (widget.datas != null) {
      
      for (var item in widget.datas!) {
        if (items.where( (e) => "${e.value["id"]}" == "${item.id}").isNotEmpty) {
          continue;
        }
        max = item.max;
        var v = item.label ?? item.name ?? "${item.id}";
        var ser = item.serialize();
        bool select = false;
        try {
          if (widget.value is String) {
            for (var val in widget.value?.split(",") ?? []) {
              val = val as model.Shallowed;
              if (val.id == item.id) {
                select = true;
                break;
              }
            }
            if (widget.readOnly) {
              if (widget.value == null) {
                return Container();
              }
              return GestureDetector( onLongPress:  () {
          copyToClipboard("${widget.value}", context);
        }, child:  Tooltip( message: "${widget.value}", child: SizedBox(width: 400, height: 30, 
                child: TextFormField(
                  readOnly: true,
                  initialValue: widget.value,
                  style: TextStyle(fontSize: 14, color: Colors.black),
                  decoration: InputDecoration(
                    focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red , width: 1.0)),
                    errorBorder: OutlineInputBorder(borderSide: BorderSide(color:Colors.red, width: 1.0)),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
                    disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
                    border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
                    isDense: true,
                    suffixIconColor: Theme.of(context).primaryColor,
                    hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    filled: true,
                    fillColor: widget.readOnly ? Theme.of(context).splashColor : (Colors.white),
                    contentPadding: EdgeInsets.only(left: 20.0, right: 20.0, 
                      top: widget.type.contains("text") && !widget.label.contains("password") ? 20 : 0,
                      bottom: widget.type.contains("text") && !widget.label.contains("password") ? 20 : 0),
                    suffixIcon: Icon(Icons.text_fields, color: Theme.of(context).secondaryHeaderColor),
                    hintText: (await getOnFlow(TranslateConstants.writeValue)).toLowerCase(),
                    labelStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontWeight: FontWeight.bold),
                    labelText: l.toLowerCase(),
                    errorStyle: const TextStyle(fontSize: 0,),
                  ),
                )))
              );
            }
          } else {
            for (var val in widget.value ?? []) {
              val = val as model.Shallowed;
              if (val.id == null) {
                if (items.where( (e)  => e.value["name"] == val.name).isEmpty) {
                  items.add(DropdownItem<Map<String, dynamic>>(value: val.serialize(), label:val.label ?? val.name ?? "", selected: true));
                }
                
              } else if (val.id == item.id) {
                select = true;
                break;
              }
            }
            if (widget.readOnly) {
              if (widget.value == null) {
                return Container();
              }
              return SizedBox(width: 400, height: 30, 
                child: TextFormField(
                  readOnly: true,
                  initialValue: widget.value.map( (e) => e.name).join(","),
                  style: TextStyle(fontSize: 14, color: Colors.black),
                  decoration: InputDecoration(
                    focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red , width: 1.0)),
                    errorBorder: OutlineInputBorder(borderSide: BorderSide(color:Colors.red, width: 1.0)),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
                    disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
                    border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
                    isDense: true,
                    suffixIconColor: Theme.of(context).primaryColor,
                    hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    filled: true,
                    fillColor: widget.readOnly ? Theme.of(context).splashColor : (Colors.white),
                    contentPadding: EdgeInsets.only(left: 20.0, right: 20.0, 
                      top: widget.type.contains("text") && !widget.label.contains("password") ? 20 : 0,
                      bottom: widget.type.contains("text") && !widget.label.contains("password") ? 20 : 0),
                    suffixIcon: Icon(Icons.text_fields, color: Theme.of(context).secondaryHeaderColor),
                    hintText: (await getOnFlow(TranslateConstants.writeValue)).toLowerCase(),
                    labelStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontWeight: FontWeight.bold),
                    labelText: l.toLowerCase(),
                    errorStyle: const TextStyle(fontSize: 0),
                  )
                )
              );
            }
          }
        } catch(e) { print(e); }
        
        try {
          if (widget.translatable) {
            v = await getOnFlow(v);
            if (v.toUpperCase() == v) {
                v = v.toUpperCase();
            } else {
              v = v.toLowerCase();
            }
          }
        } catch(e) {}
        items.add(DropdownItem<Map<String, dynamic>>(value:ser, label:v, selected: select));
      }
    }
    return MultiDropdown<Map<String, dynamic>>(
                        addFunction: widget.type == "manytomany_add" ? (String value) {
                          if (ctrls.items.where( (i) => i.label.toString() == value).isEmpty) {
                            ctrls.addItem(DropdownItem<Map<String,dynamic>>(value: {
                              "name": value,
                            }, label: value, selected: true));
                          }
                          ctrls.openDropdown(null, widget.label, true);
                        } : null,
                        controller: ctrls,
                        items: items,
                        enabled: !widget.readOnly,
                        searchEnabled: max > 10,
                        max: max,
                        changeFunction: (String value) async {
                            if (value == "") {
                              return;
                            }
                            var filters = Filters();
                            filters.add("name", Filter(value: value, column: "name", realName: "name"));
                            load(0, 10, APIService().getFilter(widget.url ?? "", true, filters), value, items);
                          
                        },
                        chipDecoration: ChipDecoration(
                          deleteIcon: Icon(Icons.close, size: 15, color: Colors.white),
                          backgroundColor: Theme.of(context).primaryColor,
                          labelStyle: TextStyle(color: widget.readOnly ? Colors.black : Colors.white),
                          wrap: true,
                          runSpacing: 2,
                          spacing: 10,
                        ),
                        fieldDecoration: FieldDecoration(
                          backgroundColor: Colors.white,
                          labelText: "${l.toLowerCase()}${widget.require ? "*" : ""}",
                          labelStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontWeight: FontWeight.bold),
                          hintText: (await getOnFlow(TranslateConstants.selectValue)).toLowerCase(),
                          hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                          prefixIcon: Icon(Icons.checklist_rtl, color: Colors.grey.shade200),
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
                        dropdownDecoration: DropdownDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          marginTop: 2,
                          maxHeight: 400,
                          header: Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              "     ${(await getOnFlow(TranslateConstants.selectValue)).toLowerCase()}",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        searchDecoration: SearchFieldDecoration(
                          border : const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          focusedBorder : const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                          hintText: "       ${(await getOnFlow(TranslateConstants.search)).toLowerCase()}",
                        ),
                        dropdownItemDecoration: DropdownItemDecoration(
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
                          saveChange(widget.component?.widget.view, widget.form, widget.name, values);
                        },
                      );
  }

  Future<void> load(int start, int interval, String filter, String value, List<DropdownItem<Map<String, dynamic>>> items) async {
    if (filter == "") { return; }
    var found = false;
    try {
      var e = await APIService().get<model.Shallowed>("${widget.url}$filter&offset=$start&limit=$interval", filter != "", null);
      if (e.data != null) {
        for (var item in e.data!) {
          if (items.where( (e) => "${e.value["id"]}" == "${item.id}").isEmpty) {
            found = true;
            var v = (item.label ?? item.name ?? "${item.id}").replaceAll("db", "").replaceAll("_", " ");
            try {
              if (widget.translatable) {
                v = await getOnFlow(v);
                if (v.toUpperCase() == v) {
                  v = v.toUpperCase();
                } else {
                  v = v.toLowerCase();
                }
              }
            } catch(e) {}
            items.add(DropdownItem<Map<String, dynamic>>(
              value: item.serialize(), label: v, selected: false));
            ctrls.addItem(items.last);
          }
        }
      } 
      if (widget.type.toLowerCase().contains("add")) {
        var e = await APIService().get<model.Shallowed>("${widget.mainURL}$filter&offset=$start&limit=$interval", filter != "", null);
        if (e.data != null) {
          for (var item in e.data!) {
            if (items.where( (e) => "${e.value["label"]}" == "${item.label ??  item.name}" || "${e.value["name"]}" == "${item.label ??  item.name}").isEmpty) {
              found = true;
              var v = (item.label ?? item.name ?? "${item.id}").replaceAll("db", "").replaceAll("_", " ");
              try {
                if (widget.translatable) {
                  v = await getOnFlow(v);
                  if (v.toUpperCase() == v) {
                    v = v.toUpperCase();
                  } else {
                    v = v.toLowerCase();
                  }
                }
              } catch(e) {}
              items.add(DropdownItem<Map<String, dynamic>>(
                value: item.serialize(), label: v, selected: false));
              ctrls.addItem(items.last);
            }
          }
        } 
      }
      if (ctrls.isOpen && found) {
        ctrls.openDropdown(value, widget.label, true);
      }
    } catch(e) {
        ctrls.openDropdown(value, "", true);
    }
  }
}