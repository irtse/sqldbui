import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/core/services/api_service.dart';
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
  ManyToManyWidget ({ super.key, required this.form, required this.schemaName, required this.name, required this.schema,
                      required this.readOnly, required this.value, required this.label, required this.translatable,
                      required this.require, required this.type, required this.url, required this.component,
                      required this.mainURL});
  @override
  // ignore: library_private_types_in_public_api
  ManyToManyState createState() => ManyToManyState();
}
class ManyToManyState extends State<ManyToManyWidget> {
  List<DataFormWidget> widgets = <DataFormWidget>[];
  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    var actions = widget.component?.widget.view?.actions ?? currentView?.actions ?? [];
    var scheme = widget.schema[widget.name];
    if (scheme == null) { return Container(); }
    var readOnly = widget.readOnly || (!actions.contains("post") && !actions.contains("put")) || (mainForm.currentState?.widget.view?.readOnly ?? false);
    print("$actions $scheme ${widget.name} ${widget.value } $readOnly");
    if (readOnly) {
      List<Container> tags = <Container>[];
      if (widget.value != null && widget.value is List) {
        for (var val in widget.value) {
          val = val as model.Shallowed;
          String str = (val.label ?? val.name ?? "${val.id}").replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ');
          if (widget.translatable) {
            str = await getOnFlow(str);
          }
          tags.add(Container( margin: const EdgeInsets.only(top:5, left: 10, right: 10), 
            child: TextButton(onPressed: (){}, 
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Theme.of(context).primaryColor),
                  mouseCursor: WidgetStateProperty.all(MouseCursor.uncontrolled),
                ),
                child: Text(str.toLowerCase(), style: const TextStyle(color: Colors.white))
              )
            )
          );
        }
      }
      String str =widget.label.toLowerCase().replaceAll('db', '').replaceAll('_id', '').replaceAll('_', ' ');
      if (widget.translatable) {
        str = await getOnFlow(str);
      }
      return Padding(padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),child: Column(children: [
        Row(children: [Text("$str${widget.require ? '*' : ''}:", 
            style:  const TextStyle( color: Colors.black, fontSize: 14, ), )]),
        Row(children: [Wrap(children: tags)]) ]),);
    } else if ((widget.url ?? "") != "") {
      print("$actions $scheme ${widget.name} ${widget.value }");
      if (widget.value != null) {
        return FutureBuilder<APIResponse<model.Shallowed>>(
          future: APIService().get(widget.url!.replaceAll("rows=all", "rows=${widget.value.join(",")}"), true, null), 
          builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.Shallowed>> s) {
          return FutureBuilder<APIResponse<model.Shallowed>>(
            future: APIService().get(widget.url!, true, null), 
            builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.Shallowed>> snap) {
                if (snap.data?.data != null) {
                  return SubManyToManyWidget(
                    mainURL: widget.mainURL,
                    form: widget.form,
                    dp: this,
                    schemaName: widget.schemaName,
                    name: widget.name,
                    readOnly: widget.readOnly,
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
      print("$actions $scheme ${widget.name} ${widget.url}");

      return FutureBuilder<APIResponse<model.Shallowed>>(
        future: APIService().get(widget.url ?? "", true, null), 
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
  SubManyToManyWidget ({ super.key, required this.datas, required this.form, required this.schemaName, required this.name,
                      required this.readOnly, required this.value, required this.label, required this.translatable,
                      required this.require, required this.type, required this.url, required this.component,
                      required this.dp, required this.mainURL});
  @override
  // ignore: library_private_types_in_public_api
  _SubManyToManyState createState() => _SubManyToManyState();
}
Map<String, Map<String,String>> newManyToManyValue = {};

class _SubManyToManyState extends State<SubManyToManyWidget> {
  List<DataFormWidget> widgets = <DataFormWidget>[];
  @override Widget build(BuildContext context) {
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
    widget.form[widget.name] = <dynamic>[];
    int max = 0;
    if (widget.datas != null) {
            for (var item in widget.datas!) {
              if (items.where( (e) => e.value["id"] != "${item.id}").isNotEmpty) {
                continue;
              }
              max = item.max;
              var v = item.label ?? item.name ?? "${item.id}";
              var ser = item.serialize();
              bool select = false;
              for (var val in widget.value ?? []) {
                val = val as model.Shallowed;
                if (val.id == item.id) {
                  select = true;
                  break;
                }
              }
              try {
                if (widget.translatable || item.translatable) {
                  v = await getOnFlow(v);
                }
              } catch(e) {}
              items.add(DropdownItem<Map<String, dynamic>>(value:ser, label:v.toLowerCase(), selected: select));
              for (var val in (widget.value ?? []) as List<dynamic>) {
                if (val.id == item.id) { widget.form[widget.name].add(ser); }
              }
            }
    }
    return MultiDropdown<Map<String, dynamic>>(
                        addFunction: widget.type == "manytomany_add" ? (String value) {
                            ctrls.addItem(DropdownItem<Map<String,dynamic>>(value: {
                              "name": value,
                            }, label: value, selected: true));
                            widget.form[widget.name].add( {
                              "name": value,
                            });
                            ctrls.closeDropdown();
                            ctrls.openDropdown(null, widget.label);
                            if (newManyToManyValue[widget.mainURL] == null) {
                              newManyToManyValue[widget.mainURL ?? ""] = {};
                            }
                            newManyToManyValue[widget.mainURL ?? ""]?[widget.name] = value;
                        } : null,
                        controller: ctrls,
                        items: items,
                        enabled: true,
                        searchEnabled: true,
                        max: max,
                        changeFunction: (String value) async {
                          if (value == "") {
                            return;
                          }
                          var filters = Filters();
                          filters.add("name", Filter(value: value, column: "name"));
                          load(0, 10, APIService().getFilter(widget.url ?? "", true, filters), value, items);
                        },
                        chipDecoration: ChipDecoration(
                          deleteIcon: Icon(Icons.close, size: 15, color: Colors.white),
                          backgroundColor: Theme.of(context).primaryColor,
                          labelStyle: TextStyle(color: Colors.white),
                          wrap: true,
                          runSpacing: 2,
                          spacing: 10,
                        ),
                        fieldDecoration: FieldDecoration(
                          labelText: "${widget.label}${widget.require ? "*" : ""}",
                          labelStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor),
                          hintText: TranslateConstants.selectValue.toLowerCase(),
                          hintStyle: TextStyle(fontSize: 12, color: Theme.of(context).splashColor),
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
                              "     ${TranslateConstants.selectValue.toLowerCase()}",
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
                          hintText: "       ${TranslateConstants.search.toLowerCase()}",
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
                          widget.component?.widget.detectChange = true;
                          widget.form[widget.name]=values;
                        },
                      );
  }

  Future<void> load(int start, int interval, String filter, String value, List<DropdownItem<Map<String, dynamic>>> items) async {
    if (filter == "") { return; }
    var found = false;
      var e = await APIService().get<model.Shallowed>("${widget.url}$filter&offset=$start&limit=$interval", filter != "", null);
        if (e.data != null) {
          for (var item in e.data!) {
            if (items.where( (e) => e.value["id"] == "${item.id}").isEmpty) {
              found = true;
              var v = (item.label ?? item.name ?? "${item.id}").replaceAll("db", "").replaceAll("_", " ");
              try {
                if (widget.translatable || item.translatable) {
                  v = await getOnFlow(v);
                }
              } catch(e) {}
              items.add(DropdownItem<Map<String, dynamic>>(
                value: item.serialize(), label: v.toLowerCase(), selected: false));
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