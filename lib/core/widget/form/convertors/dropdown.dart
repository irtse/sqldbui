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

Map<String,String> currentDropdown = {};
Map<String,String> newDropDownValue = {};
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
    var val = widget.value  ?? widget.autofill ?? currentDropdown[viewID!];
        if (val != null) {
          widget.form[widget.name]=val;
        }
        if (val == null) {
          val = widget.readOnly ? TranslateConstants.empty : null;
        } else if (widget.translatable) {
          try {
            val = (await getOnFlow(val)).toLowerCase();
          } catch(e) {}
    }
    if (widget.type.contains("enum") || widget.mainUrl == null) {
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
            try {
              v = await getOnFlow(item);
            } catch(e) {}
          }
          items.add(DropdownMenuItem<String>(value: item, child:  Text(v.toLowerCase(), overflow: TextOverflow.ellipsis)));
        }
      }
      return DropdownButtonFormField<String>( 
          items: items, 
          isExpanded: true,
          hint: Text(TranslateConstants.select.toLowerCase(), 
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
      return SizedBox(
        width: 400, 
        height: 30, 
        child: TextFormField(
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
    var lab = await getOnFlow(widget.label);
    if (val != null) {
      return FutureBuilder<APIResponse<model.Shallowed>>(
        future: APIService().get(widget.mainUrl!.replaceAll("rows=all", "rows=$val"), firstAPI, null), 
        builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.Shallowed>> s) {
           return FutureBuilder<APIResponse<model.Shallowed>>(
            future: APIService().get(widget.mainUrl!, firstAPI, null), 
            builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.Shallowed>> snap) {
              if (snap.data?.data != null) {
                return SubDropDownWidget(
                  label: lab,
                  dp: this,
                  mainUrl: widget.mainUrl!,
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
        future: APIService().get(widget.mainUrl!, firstAPI, null), 
        builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.Shallowed>> snap) {
          if (snap.data?.data != null) {
            return SubDropDownWidget(
              label: lab,
              dp: this,
              mainUrl: widget.mainUrl!,
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
              datas: snap.data!.data!,
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
  MultiSelectController<String> ctrls = MultiSelectController<String>();
  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    List<String> idSet = [];
    List<DropdownItem<String>> items = [];
    Map<String, model.Shallowed> mapped = <String, model.Shallowed>{};
    int max = 0;
    for (var item in widget.datas) {
      max = item.max;
      var v = (item.label ?? item.name ?? "${item.id}").replaceAll("db", "").replaceAll("_", " ");
      var t = items.where((element) => element.value == v);        
      if (!mapped.containsKey(v) && t.isEmpty){
        mapped["${item.id}"]=item;
        if((widget.component!.widget.view!.isEmpty || !(widget.component!.widget.view!.isEmpty && !item.actions.contains("post")))
        && items.where((element) => element.value == v).isEmpty) {
          var vv = v;
          bool select = false;
          if ("${widget.value}" == "${item.id}" || "${widget.autofill}" == "${item.id}" || currentDropdown[viewID!] == "${item.id}") {
            widget.form[widget.name]=widget.value ?? widget.autofill;
            select = true;
            if (widget.url != null) {
               widget.wrappers?.currentState?.setState( () { 
                widget.wrappers?.currentState?.wrappersURL[widget.name] = widget.url!.replaceAll("rows=all", "rows=${item.id}");
              }); 
            }
          }
          try {
            if (widget.translatable || item.translatable) {
              vv = (await getOnFlow(vv)).toLowerCase();
            }
          } catch(e) {}
          idSet.add("${item.id}");
          items.add(DropdownItem<String>(value: "${item.id}", label: vv, selected: select));
        }
      }
    }
    return MultiDropdown<String>(
        max: max,
        changeFunction: (dynamic value) async {
          if (value == "") {
            widget.dp.setState(() {});
          }
          var service = APIService();
          var filters = Filters();
          filters.add("name", Filter(value: value, column: "name"));
          var e = await service.get<model.Shallowed>("${widget.mainUrl}${service.getFilter(widget.mainUrl, true, filters)}", true, context);
          if (e.data != null) {
              for (var item in e.data!) {
                if (!idSet.contains("${item.id}")) {
                   var v = (item.label ?? item.name ?? "${item.id}").replaceAll("db", "").replaceAll("_", " ");
                   try {
                    if (widget.translatable || item.translatable) {
                      v = await getOnFlow(v);
                    }
                  } catch(e) {}
                  mapped["${item.id}"]=item;
                  idSet.add("${item.id}");
                  ctrls.addItem(DropdownItem<String>(value: "${item.id}", label: v.toLowerCase(), selected: false));
                  ctrls.closeDropdown();
                  ctrls.openDropdown();
                }
              }
          }
        },
        enabled:!widget.readOnly,
        addFunction: widget.type == "link_add" ? (String value) {
            for (var e in ctrls.items) {
              e.selected = false;
            }
            ctrls.addItem(DropdownItem<String>(value: value, label: value, selected: true));
            ctrls.closeDropdown();
            ctrls.openDropdown();
            newDropDownValue[widget.url ?? ""] = value;
            searchCtrl.text = "";
        } : null,
                        controller: ctrls,
                        singleSelect: true,
                        items: items,
                        searchEnabled: true,
                        chipDecoration: ChipDecoration(
                          backgroundColor: Theme.of(context).primaryColor,
                          labelStyle: TextStyle(color: Colors.white),
                          wrap: true,
                          runSpacing: 2,
                          spacing: 10,
                        ),
                        fieldDecoration: FieldDecoration(
                          labelText: "${widget.label}${widget.require ? "*" : ""}",
                          backgroundColor: widget.readOnly ? Theme.of(context).splashColor 
                                     : ( widget.isDark ? Theme.of(context).primaryColorLight : Colors.white ),
                          labelStyle: TextStyle(color: widget.isDark ? Theme.of(context).splashColor : Theme.of(context).secondaryHeaderColor),
                          hintText: TranslateConstants.selectValue.toLowerCase(),
                          hintStyle: TextStyle(fontSize: 12, color: Theme.of(context).splashColor),
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
                          widget.component?.widget.detectChange = true;
                          if (values.isEmpty) { widget.form[widget.name]=null;
                          } else { widget.form[widget.name]=mapped[values[0]]?.id; }
                          try {
                            var item = mapped[values[0]];
                            if (widget.url != null && item != null) {
                              currentDropdown[viewID!] = values[0];
                              widget.wrappers?.currentState?.setState( () { 
                                widget.wrappers?.currentState?.wrappersURL[widget.name] = widget.url!.replaceAll("rows=all", "rows=${item.id}");
                              }); 
                            }
                          } catch(e) {

                          } 
                        },
                      );
  }
}