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
  final String schemaName;
  final dynamic name;
  final bool readOnly;
  final bool require;
  dynamic value;
  final FormWidgetState? component;
  final String? url;
  final String type;
  final String label;
  final bool translatable;
  var isFilled = true;
  ManyToManyWidget ({ super.key, required this.form, required this.schemaName, required this.name,
                      required this.readOnly, required this.value, required this.label, required this.translatable,
                      required this.require, required this.type, required this.url, required this.component});
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
  var actions = widget.component?.widget.view?.actions ?? [] as List<String>;
  var schema =  widget.component?.widget.view!.schema;
  var scheme = schema?[widget.name];
  if (scheme == null) { return Container(); }
  var readOnly = widget.readOnly || (!actions.contains("post") && !actions.contains("put")) || mainForm.currentState!.widget.view!.readOnly;
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
    } else {
      String url = scheme.valuesPath;
      if (widget.value != null) {
        return FutureBuilder<APIResponse<model.Shallowed>>(
          future: APIService().get(url.replaceAll("rows=all", "rows=${widget.value.join(",")}"), true, null), 
          builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.Shallowed>> s) {
          return FutureBuilder<APIResponse<model.Shallowed>>(
            future: APIService().get(url, true, null), 
            builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.Shallowed>> snap) {
                if (snap.data?.data != null) {
                  return SubManyToManyWidget(
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
      return FutureBuilder<APIResponse<model.Shallowed>>(
        future: APIService().get(url, true, null), 
        builder: (BuildContext cont, AsyncSnapshot<APIResponse<model.Shallowed>> snap) {
            if (snap.data?.data != null) {
              return SubManyToManyWidget(
                form: widget.form,
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
    }
}

// ignore: must_be_immutable
class SubManyToManyWidget extends StatefulWidget {
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
  List<dynamic>? datas;
  SubManyToManyWidget ({ super.key, required this.datas, required this.form, required this.schemaName, required this.name,
                      required this.readOnly, required this.value, required this.label, required this.translatable,
                      required this.require, required this.type, required this.url, required this.component,
                      required this.dp});
  @override
  // ignore: library_private_types_in_public_api
  _SubManyToManyState createState() => _SubManyToManyState();
}
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
  Future<Widget> futureBuild(BuildContext context) async {
    MultiSelectController<String> ctrls = MultiSelectController<String>();
    List<String> idSet = [];
          List<DropdownItem<Map<String, dynamic>>> items = <DropdownItem<Map<String, dynamic>>>[];
          widget.form[widget.name] = <dynamic>[];
          int max = 0;
          if (widget.datas != null) {
            for (var item in widget.datas!) {
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
              idSet.add("${item.id}");
              items.add(DropdownItem<Map<String, dynamic>>(value:ser, label:v.toLowerCase(), selected: select));
              for (var val in (widget.value ?? []) as List<dynamic>) {
                if (val.id == item.id) { widget.form[widget.name].add(ser); }
              }
            }
          }
          return MultiDropdown<Map<String, dynamic>>(
                        items: items,
                        enabled: true,
                        searchEnabled: true,
                        max: max,
                        changeFunction: (dynamic value) async {
                          if (value == "") {
                            widget.dp.setState(() {});
                          }
                          var service = APIService();
                          var filters = Filters();
                          filters.add("name", Filter(value: value, column: "name"));
                          var e = await service.get<model.Shallowed>("${widget.url}${service.getFilter(widget.url ?? "", true, filters)}", true, context);
                          if (e.data != null) {
                              for (var item in e.data!) {
                                if (!idSet.contains("${item.id}")) {
                                  var v = (item.label ?? item.name ?? "${item.id}").replaceAll("db", "").replaceAll("_", " ");
                                  try {
                                    if (widget.translatable || item.translatable) {
                                      v = await getOnFlow(v);
                                    }
                                  } catch(e) {}
                                  idSet.add("${item.id}");
                                  ctrls.addItem(DropdownItem<String>(value: "${item.id}", label: v.toLowerCase(), selected: false));
                                  ctrls.closeDropdown();
                                  ctrls.openDropdown();
                                }
                              }
                          }
                        },
                        chipDecoration: ChipDecoration(
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
}