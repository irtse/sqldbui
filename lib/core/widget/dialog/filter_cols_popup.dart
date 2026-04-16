import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/page/translate.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/widget/datagrid/grid.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/widget/datagrid/datagrid.dart';
import 'package:sqldbui2/core/widget/dialog/confirm_box.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:sqldbui2/core/widget/datagrid/buttons/popup_button.dart';
import 'package:sqldbui2/core/widget/utils/fork/multi_dropdown/multi_dropdown.dart';
import 'package:uuid/uuid.dart';

// ignore: must_be_immutable
bool setLatest = false;

Map<String?, List<dynamic>> filterIndexOrderView = <String?, List<dynamic>>{};

Map<String?, List<dynamic>> filterOrderView = <String?, List<dynamic>>{};
Map<String?, bool> filterTempID = <String?, bool>{};
Map<String?, List<dynamic>> filterTempOrderView = <String?, List<dynamic>>{};
Map<String?, String?> filterView = <String?, String?>{};
GlobalKey<FilterColsPopUpState> filterColsPopUpKey = GlobalKey<FilterColsPopUpState>();
// ignore: must_be_immutable
class FilterColsPopUpWidget extends StatefulWidget{
  Map<String, model.SchemaField> schema = <String, model.SchemaField>{};

  FilterColsPopUpWidget ({ super.key, required this.schema });
  @override
  FilterColsPopUpState createState() => FilterColsPopUpState();
}
bool forceViewFilter = false;
class FilterColsPopUpState extends State<FilterColsPopUpWidget> {
  @override Widget build(BuildContext context) {
    if (viewID == null || (currentView?.filterPath ?? "") == "") { return Container(); }
    return FutureBuilder(future: APIService().get<model.Shallowed>("${currentView!.filterPath}&is_view=true", forceViewFilter, null), 
    builder: (BuildContext context, AsyncSnapshot<APIResponse<model.Shallowed>> snapshot) {
      forceViewFilter = false;
      if (snapshot.hasData && snapshot.data!.data != null && snapshot.data!.data!.isNotEmpty) {
        return FutureMenuColsPopUpWidget(comp: this, datas: snapshot.data!.data!, schema: widget.schema);
      }
      return FutureMenuColsPopUpWidget(comp: this, datas: [], schema: widget.schema);
    }); 
  }
}

// ignore: must_be_immutable
class FutureMenuColsPopUpWidget extends StatefulWidget{
  FilterColsPopUpState comp;
  Map<String, model.SchemaField> schema = <String, model.SchemaField>{};
  List<model.Shallowed> datas = [];
  FutureMenuColsPopUpWidget ({ 
    super.key, 
    required this.comp,
    required this.schema, 
    required this.datas });
  @override
  FutureMenuColsPopUpState createState() => FutureMenuColsPopUpState();
}

class FutureMenuColsPopUpState extends State<FutureMenuColsPopUpWidget> {
  bool noSelection =false;
  @override Widget build(BuildContext context) {
      var dpItems = <DropdownItem<String>>[];
        for (var i in widget.datas) { 
          if (setLatest) {
            filterView[viewID] = i.id.toString();
            setLatest = false;
          }
          if (i.selected && (i.label ?? i.name) == filterView[viewID]) { 
            for (var field in i.fields) {
              if (filterTempOrderView[viewID] == null) { filterTempOrderView[viewID] = []; }
              if (rects[viewID] == null) { rects[viewID] = {}; }
              filterTempOrderView[viewID]!.add(field.column);
              if (field.width != null) { rects[viewID]![field.column!] = Rect.fromCenter(
                center: MediaQuery.of(context).size.center(Offset.zero),
                width: field.width!, height: 55,
              ); }
            }
            filterTempOrderView[viewID] = i.fields.map((e) => e.column).toList();
          }
          var filterLabel =i.label ?? i.name ?? "";
          dpItems.add(DropdownItem<String>(value: i.id.toString(), label: filterLabel.toLowerCase()));
        }
      return FutureBuilder(future: getOnFlow(TranslateConstants.filterViewPlaceholder), builder: (a,s) {
        return PopupButtonWidget(
          color: Colors.white,
          width: 277,
          tooltip: (s.data ?? TranslateConstants.filterViewPlaceholder).toLowerCase(), 
          icon: Icons.settings, 
          widget: MenuColsPopUpWidget(comp: widget.comp, items: dpItems, schema: widget.schema,),
        );
      }); 
  }
}

// ignore: must_be_immutable
class MenuColsPopUpWidget extends StatefulWidget{
  String value = "";
  FilterColsPopUpState comp;
  List<DropdownItem<String>> items = [];
  Map<String, model.SchemaField> schema = <String, model.SchemaField>{};
  MenuColsPopUpWidget ({ 
    super.key, 
    required this.comp,
    required this.schema, 
    required this.items,
    this.value = "", });
  @override
  MenuColsPopUpState createState() => MenuColsPopUpState();
}

class MenuColsPopUpState extends State<MenuColsPopUpWidget> {
  bool force = false;
  bool noSelection =false;
  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    var title = await getOnFlow(TranslateConstants.filterTitle);
    var apply = await getOnFlow(TranslateConstants.filterApply);
    var cancel = await getOnFlow(TranslateConstants.filterCancel);
    var save = await getOnFlow(TranslateConstants.filterSave);
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column( children: [ 
            Padding( 
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10), 
              child: Row( mainAxisAlignment: MainAxisAlignment.center, children: [ const Padding( padding: EdgeInsets.only(right: 10), child: Icon(Icons.list)), 
                    Text(title.toUpperCase(), style: TextStyle(fontSize: 15, color: Theme.of(context).primaryColor)) ])),
                  Divider(color: Theme.of(context).splashColor),
                  // select all
                  ColsPopUpWidget(schema: widget.schema, items: widget.items, comp: this),
                  Padding(padding: const EdgeInsets.only(bottom: 10), child: Divider(color: Theme.of(context).splashColor,)),
                  Row( mainAxisAlignment: MainAxisAlignment.center, children : [ Padding( padding: const EdgeInsets.only(right: 10), 
                    child: TextButton(onPressed: () { 
                      filterOrderView[viewID] = filterTempOrderView[viewID]!;
                      globalOffset = 0; 
                      globalMainViewKey.currentState?.refresh(viewID, subViewID, null, true);
                      for (var row in filterRowsWidget[viewID] ?? []) {
                        row.rowKey.currentState?.setState(() {});
                      }
                  }, style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Theme.of(context).primaryColor)), 
                    child: Padding( padding: EdgeInsets.all(10), 
                      child: Text(apply.toUpperCase(), style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1), fontSize: 12))))),
                  filterView[viewID] != null && filterView[viewID] != "" ? 
                  Padding( padding: const EdgeInsets.only(right: 10), 
                    child: TextButton(onPressed: () async { 
                    await APIService().put<model.View>(currentView!.filterPath.replaceAll("rows=all", 
                      "rows=${filterView[viewID]}"), <String, dynamic> { "is_selected" : false }, null);
                      widget.value = "";
                      filterView.remove(viewID);
                      filterOrderView.remove(viewID);
                      filterTempOrderView.remove(viewID);  
                      globalMainViewKey.currentState?.refresh(viewID, subViewID, null, true);    
                      Future.delayed(const Duration(seconds: 1), () {
                        setState((){});
                        Navigator.pop(context);
                      });
                  }, style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Theme.of(context).primaryColor)), 
                  child: Padding( padding: EdgeInsets.all(10), 
                  child: Text(cancel.toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 12))),))
                  : TextButton(onPressed: () {
                    List<Map<String, dynamic>> fields = [];
                    for (var (index, fieldName) in filterTempOrderView[viewID]!.indexed) {
                      fields.add(<String, dynamic>{ "name" : fieldName, "index" : index, "width" : rects[viewID]?[fieldName]?.width, });
                    }
                    filterOrderView[viewID] = filterTempOrderView[viewID]!;
                    var body = <String, dynamic>{ "link" : currentView!.schemaName, "is_selected" : true, "view_fields" : fields, "name": widget.value,  };
                    APIService().post<model.Shallowed>(currentView!.filterPath, body, context).then((v) async { 
                        forceViewFilter = true;
                        globalOffset = 0; 
                        setLatest = true;
                        if (v.data != null && v.data!.isNotEmpty) {
                          var i = v.data?[0];
                          filterView[viewID] = i!.id.toString();
                          var filterLabel = await getOnFlow(i.label ?? i.name ?? "");
                          var l = await getOnFlow(filterLabel);
                          widget.items.add(DropdownItem<String>(value: i.id.toString(), label: l));
                        }
                        setState((){});
                        widget.comp.setState((){});
                        Future.delayed( const Duration(seconds: 1), () {
                          globalMainViewKey.currentState?.refresh(viewID, subViewID, null, true);
                        });
                    });
                  }, style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Theme.of(context).primaryColor)), 
                  child: Padding( padding: EdgeInsets.all(10), 
                  child: Text(save.toUpperCase(), 
                    style: const TextStyle(color: Colors.white, fontSize: 12))),) ])
      ]); } ) );
  }
}

// ignore: must_be_immutable
class ColsPopUpWidget extends StatefulWidget{
  Map<String, model.SchemaField> schema = <String, model.SchemaField>{};
  List<DropdownItem<String>> items = [];
  MenuColsPopUpState comp;
  String? search;
  ColsPopUpWidget ({ super.key, required this.schema, required this.items, required this.comp });
  @override
  ColsPopUpState createState() => ColsPopUpState();
}

class ColsPopUpState extends State<ColsPopUpWidget> {
  List<String> order = [];
  bool force = false;
  bool noSelection =false;
  @override Widget build(BuildContext context) {
    return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }

  bool isValidUUID(String value) {
  final regex = RegExp(
    r'^[0-9a-fA-F]{8}-'
    r'[0-9a-fA-F]{4}-'
    r'[1-5][0-9a-fA-F]{3}-'
    r'[89abAB][0-9a-fA-F]{3}-'
    r'[0-9a-fA-F]{12}$',
  );
  return regex.hasMatch(value);
}
  Future<Widget> futureBuild(BuildContext context) async {
    String? fView;
    if (filterView[viewID] != null) {
      var f = filterView[viewID];
      fView = f?.toLowerCase();
    }
    List<Widget> items = [];
    if (filterTempOrderView[viewID] == null) { 
      filterTempOrderView[viewID] = currentView != null ? currentView!.order : []; 
    }
    filterIndexOrderView[viewID] = filterIndexOrderView[viewID] ?? currentView!.order.where( (fieldName) => !(widget.schema[fieldName] == null)).toList();
    if ("id".contains(widget.search ?? "")) {
      items.add(
        Center( 
          child: Padding( padding: const EdgeInsets.symmetric(vertical: 10), 
            child: Row( children : [ 
              Container( width: 44),
              Padding( padding: const EdgeInsets.only(right: 10), 
              child: Tooltip( message: "id", child: AdvancedSwitch(
                initialValue: filterTempOrderView[viewID]!.contains("id"),
                activeColor: Colors.green, inactiveColor: Colors.grey,
                activeChild: Padding( padding: EdgeInsets.symmetric(horizontal: 10), child: Text("id", overflow: TextOverflow.ellipsis)), 
                inactiveChild: Padding( padding: EdgeInsets.symmetric(horizontal: 10), child:Text("id", overflow: TextOverflow.ellipsis)), 
                borderRadius:  const BorderRadius.all(Radius.circular(15)),
                width: 165, height: 30.0, disabledOpacity: 0.5,
                onChanged: (value) { 
                  filterTempID[viewID] = value; 
                }
              ))),
              Container()
          ]))));
    }
    
    for (var (index,fieldName) in (filterIndexOrderView[viewID] ?? []).where( (el) => widget.schema[el] != null).indexed) {
        if (widget.schema[fieldName] == null) { continue; }
        var scheme =  widget.schema[fieldName]!; 
        items.add(FutureBuilder(future: getOnFlow(scheme.label), builder: (a,s) { 
          if (!(s.data ?? scheme.label).contains(widget.search ?? "")) {
            return Container();
          }
          return Center( 
            child: Padding( padding: const EdgeInsets.symmetric(vertical: 5), 
            child: Row( children : [ 
            index == 0 ? Container(width: 44) : Padding( padding: const EdgeInsets.symmetric(horizontal: 10), child: InkWell(
              onTap: () {
                var tmp = filterIndexOrderView[viewID]!;
                var i = tmp.removeAt(index);
                var b = tmp.sublist(0, index > 0 ? index - 1 : 0);
                b.add(i);
                b.addAll(tmp.sublist(index > 0 ? index - 1 : 0, tmp.length));
                setState(() { 
                  filterIndexOrderView[viewID] = b; 
                  filterTempOrderView[viewID] = filterIndexOrderView[viewID]?.where( (e) => filterTempOrderView[viewID]?.contains(e) ?? false).toList() ?? [];
                }); 
              }, child: const Icon(Icons.arrow_upward))),
            Padding( padding: const EdgeInsets.only(right: 10), 
            child: Tooltip( message: (s.data ?? scheme.label).toLowerCase(), child: AdvancedSwitch(
                initialValue: filterTempOrderView[viewID]!.contains(fieldName),
                activeColor: Colors.green, inactiveColor: Colors.grey,
                activeChild: Padding( padding: EdgeInsets.symmetric(horizontal: 10), child: Text((s.data ?? scheme.label).toLowerCase(), overflow: TextOverflow.ellipsis)), 
                inactiveChild: Padding( padding: EdgeInsets.symmetric(horizontal: 10), child:Text((s.data ?? scheme.label).toLowerCase(), overflow: TextOverflow.ellipsis)), 
                borderRadius:  const BorderRadius.all(Radius.circular(15)),
                width: 165, height: 30.0, disabledOpacity: 0.5,
                onChanged: (value) { 
                  if (value) { 
                    filterTempOrderView[viewID]?.add(fieldName);      
                    filterTempOrderView[viewID] = filterIndexOrderView[viewID]?.where( (e) => filterTempOrderView[viewID]?.contains(e) ?? false).toList() ?? [];
                  } else { 
                    filterTempOrderView[viewID]?.remove(fieldName); 
                  }
                }
              ))
            ),
            index == filterIndexOrderView[viewID]!.length -1 ? Container() : Padding( padding: const EdgeInsets.only(right: 10), child: InkWell( onTap: () {
                var tmp = filterIndexOrderView[viewID]!;
                var i = tmp.removeAt(index);
                var b = tmp.sublist(0, index + 1);
                b.add(i);
                b.addAll(tmp.sublist(index + 1, tmp.length));
                setState(() { 
                  filterIndexOrderView[viewID] = b; 
                  filterTempOrderView[viewID] = filterIndexOrderView[viewID]?.where( (e) => filterTempOrderView[viewID]?.contains(e) ?? false).toList() ?? [];
                }); 
            }, child: const Icon(Icons.arrow_downward))),
          ]))); 
        }));
      }
    var ctrls = MultiSelectController<String>();
    for (var item in widget.items) {
      item.selected = false;
      if (fView == item.value) {
        item.selected = true;
      }
      ctrls.addItem(item);
    }

    var gk = GlobalKey<OptionsListState>();
    return Column(children: [
      Padding(padding: EdgeInsets.symmetric(horizontal: 10),
        child: SizedBox( height: 30, 
          child: MultiDropdown<String>(
            gk: gk,
            addFunction: (String value) {
              for (var e in ctrls.items) {
                e.selected = false;
              }
              filterView[viewID] = value; 
              if (widget.items.where( (i) => i.value.toString() == value).isEmpty) {
                widget.items.add(DropdownItem<String>(value: value, label: value, selected: true));
              }
              Future.delayed(Duration(milliseconds: 500), () {
                gk.currentState?.setState(() {
                  gk.currentState?.widget.items = widget.items;
                });
              }); 
              setState(() {});
            },
            controller: ctrls,
            singleSelect: true,
            items: widget.items,
            searchEnabled: true,
            chipDecoration: ChipDecoration(
                              backgroundColor: Theme.of(context).primaryColor,
                              labelStyle: TextStyle(color: Colors.white),
                              wrap: true,
                              runSpacing: 2,
                              spacing: 10,
            ),
            fieldDecoration: FieldDecoration(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              errorBorder: OutlineInputBorder(borderSide: BorderSide(color:Colors.red, width: 1.0)),
              disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(fontSize: 0),
              hintText: (await getOnFlow("select a filter")).toLowerCase(),
              hintStyle: TextStyle(overflow: TextOverflow.ellipsis, fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w300),
              prefixIcon: Icon(Icons.list, color: Colors.grey),
              showClearIcon: false,
              border:  OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
              focusedBorder:  OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
            ),
            searchDecoration: SearchFieldDecoration(
              hintText: "       ${(await getOnFlow(TranslateConstants.search)).toLowerCase()}",
              border : const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              focusedBorder : const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.all(Radius.circular(5))
              )
            ),
            dropdownDecoration: DropdownDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              marginTop: 2,
              maxHeight: 400,
              header: Padding(
                padding: EdgeInsets.all(8),
                  child: Text(
                    "       ${(await getOnFlow(TranslateConstants.selectValue)).toLowerCase()}",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              dropdownItemDecoration: DropdownItemDecoration(
                backgroundColor: Theme.of(context).highlightColor,
                selectedIcon: const Icon(Icons.check_box, color: Colors.green),
                disabledIcon: Icon( Icons.lock, color: Colors.grey.shade300) ),
                validator: (value) {
                  if ((value == null || value.isEmpty)) {
                    return '';
                  }
                  return null;
                },
                onSelectionChange: (values) async {
                  widget.comp.widget.value = values[0];
                  if (int.tryParse(values[0]) == null) {
                    return;
                  }
                  await APIService().put<model.Shallowed>(currentView!.filterPath.replaceAll(
                            "rows=all", "rows=${values[0]}"), <String, dynamic> { "is_selected" : true }, null).then((v) {
                            globalOffset = 0; 
                            filterView[viewID] = values[0];
                            filterTempOrderView.remove(viewID);
                            noSelection=false;
                            if (v.data != null && v.data!.isNotEmpty) { 
                              filterTempOrderView[viewID] = v.data![0].fields.map((e) => e.column ?? "id").toList();
                              filterOrderView[viewID] = filterTempOrderView[viewID]!;
                            } 
                            setState((){});
                            widget.comp.setState((){});
                            globalMainViewKey.currentState?.refresh(viewID, subViewID, null, true);
                          });
                  },
                )
              )
            ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, 
                    children: filterView[viewID] != null && filterView[viewID] != "" ? [
                    IconButton(onPressed: () {
                      List<Map<String, dynamic>> fields = [];
                      for (var (index, fieldName) in filterTempOrderView[viewID]!.indexed) {
                        fields.add(<String, dynamic>{ "name" : fieldName, "index" : index, "width" : rects[viewID]?[fieldName]?.width, });
                      }
                      widget.comp.force = true;
                      filterOrderView[viewID] = filterTempOrderView[viewID]!;
                      if (int.tryParse(filterView[viewID] ?? "") == null) {
                        var body = <String, dynamic>{  "name" : filterView[viewID], "link" : currentView!.schemaName, "view_fields" : fields  };
                        APIService().post<model.View>(currentView!.filterPath, body, null).then((value) {
                            globalMainViewKey.currentState?.refresh(viewID, subViewID, null, true);
                        });
                      } else {
                        var body = <String, dynamic>{ "link" : currentView!.schemaName, "view_fields" : fields  };
                        APIService().put<model.View>(currentView!.filterPath.replaceAll(
                          "rows=all", "rows=${filterView[viewID]}"), body, null).then((value) {
                            globalMainViewKey.currentState?.refresh(viewID, subViewID, null, true);
                        });
                      }
                     
                    }, icon: const Icon(Icons.save), color: Theme.of(context).secondaryHeaderColor),
                    IconButton(onPressed: () { 
                      showDialog(context: context, builder: (builder) => ConfirmBoxWidget(purpose: "delete filter", validate: () {
                        APIService().delete<model.View>(currentView!.filterPath.replaceAll("rows=all", "rows=${filterView[viewID]}"), null).then((value) {
                          widget.items.removeWhere((element) => element.value == filterView[viewID]);
                          filterView[viewID] = null;
                          filterTempOrderView.remove(viewID);
                          filterOrderView.remove(viewID);
                          noSelection=true;
                          widget.comp.force = true;
                          widget.comp.setState((){ });
                          globalMainViewKey.currentState?.refresh(viewID, subViewID, null, true);
                        },);
                      }));
                    }, icon: const Icon(Icons.delete), color: Theme.of(context).secondaryHeaderColor),
                  ] : [],),
                  Divider(color: Theme.of(context).splashColor),
                  FutureBuilder(future: getOnFlow("search in names"), builder: (a,s) {
                    return Container( height: 30, padding: EdgeInsets.only(left: 10, right: 10), child: TextFormField(
                      initialValue: widget.search,
                      style: TextStyle( fontSize: 13, color: Theme.of(context).secondaryHeaderColor),
                      enabled: true,
                      autocorrect: true,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red , width: 1.0)),
                        errorBorder: OutlineInputBorder(borderSide: BorderSide(color:Colors.red, width: 1.0)),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
                        disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
                        border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
                        isDense: true,
                        suffixIconColor: Theme.of(context).primaryColor,
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        filled: true,
                        fillColor:  Colors.white,
                        contentPadding: EdgeInsets.only(left: 20.0, right: 20.0, top: 0, bottom:0),
                        suffixIcon: Icon(Icons.search, color:  Theme.of(context).secondaryHeaderColor),
                        hintText: s.data ?? TranslateConstants.search.toLowerCase(),
                        errorStyle: const TextStyle(fontSize: 0,),
                      ),
                      onChanged: (String? value) {
                        setState(() {
                          widget.search = value;
                        });
                      },
                      validator: (String? value) {
                        return null;
                      },
                    )); 
                  }),
                  Divider(color: Theme.of(context).splashColor,),
                  Container( constraints: const BoxConstraints(maxHeight: 200), 
                    child: SingleChildScrollView( 
                      child: Column(children: items)
                    )
                  ),
    ]);
  }
}