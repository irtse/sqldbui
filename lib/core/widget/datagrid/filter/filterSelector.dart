import 'package:flutter/foundation.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sqldbui2/core/widget/actionbar.dart';
import 'package:sqldbui2/core/widget/datagrid/functions/functions_selector.dart';
import 'package:sqldbui2/core/widget/datagrid/grid.dart';
import 'package:sqldbui2/core/widget/dialog/filter_cols_popup.dart';
import 'package:sqldbui2/core/widget/utils/fork/multi_dropdown/multi_dropdown.dart';
import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/model/filter.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:sqldbui2/page/translate.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/widget/datagrid/datagrid.dart';
import 'package:sqldbui2/core/widget/dialog/confirm_box.dart';
import 'package:sqldbui2/core/widget/datagrid/filter/filterRow.dart';

// ignore: must_be_immutable
class FilterSelectorWidget extends StatefulWidget {
  Filters? filterMain;
  String schemaName;
  Map<String, model.SchemaField> schema = {};
  FilterSelectorWidget ({ super.key, required this.filterMain, 
  required this.schema, required this.schemaName
});
  @override FilterSelectorWidgetState createState() => FilterSelectorWidgetState();
}
bool check = true;
bool forceFilter = false;
class FilterSelectorWidgetState extends State<FilterSelectorWidget> {
  @override Widget build(BuildContext context) {
  return FutureBuilder(future: futureBuild(context), builder: (b,a) {
      if (a.hasData && a.data != null) {
        return a.data!;
      }
      return Container();
    });
  }
  Future<Widget> futureBuild(BuildContext context) async {
    if (filterRestr[viewID] != null && !tempRemoval && check) {
      check = false;
      if ((globalFilter[viewID]?.filters ?? {}).isNotEmpty) {
        filterRowsWidget = globalFilter[viewID]?.toRow(widget.schema) ?? [];
        resetList();
      } else {
        try {
          if (int.parse(filterRestr[viewID]!) > 0) {
             var resp = await APIService().get<model.Shallowed>("${currentView!.filterPath.replaceAll("rows=all", "rows=${filterRestr[viewID]}")}&is_view=false", true, null);
            if ((resp.data ?? []).isNotEmpty) {
              var i = resp.data![0];
              if ((i.selected && !noFilterRetrieval) || (filterRowsWidget.isEmpty && i.fields.isNotEmpty)) { 
                globalNew[viewID] = i.elder;
                refreshFilter(i.fields);
                filterRowsWidget = globalFilter[viewID]?.toRow(widget.schema) ?? [];
                resetList();
              }
            }
          }
        } catch(e) {}
      }
    } else if (tempRemoval) { tempRemoval = false; }
    var index = 0;    
    var subSize = showMore ? (filterRowsWidget.length * 45 < 138 ? filterRowsWidget.length * 45 : 138) : (!(editMode[viewID] == "math") ? 0 : 138);
    if (currentWidth <= 1000) { subSize = 0; }
    for (var i in filterRowsWidget) { 
      if (filterRowsWidget.length - 1 > index && i.connector == "") { 
        filterRowsWidget[index] = FilterRowWidget(
          schema: widget.schema, 
          index: i.index, 
          connector: "and", 
          label: i.label, 
          type: i.type, 
          columnName: i.columnName, 
          value: i.value, 
          comparator: i.comparator, 
          dir: i.dir);
      }
      index++;
    }
    var toggles = ["new", "old", "draft"];
    return Column( children : [ 
      Stack( children: [ 
            currentWidth > 1000 ? 
              Positioned( 
                top: 3.5, left: 32, 
                child: Row( children: [ 
                  Padding( 
                    padding: const EdgeInsets.only(right: 10), 
                    child : Tooltip( 
                      message : (await getOnFlow(showMore ? TranslateConstants.filterHide.toLowerCase() : TranslateConstants.filterShow)).toLowerCase(),
                      child: InkWell( 
                        child : Icon( showMore ? Icons.filter_alt : Icons.filter_alt_outlined, 
                          color: showMore ? Colors.white : Theme.of(context).splashColor, size: 20), 
                        onTap: () { 
                          confirmCache = {};
                          globalGridKey.currentState?.setState(() { showMore = !showMore; }); }
                      )),
                    ),
                    filterRowsWidget.isNotEmpty ? Container(
                      margin: const EdgeInsets.only(right: 5), 
                      padding: const EdgeInsets.only(left: 5), 
                      child:  IconButton( constraints: const BoxConstraints(), tooltip: (await getOnFlow(TranslateConstants.filterSaveT)).toLowerCase(), 
                      style: ButtonStyle( overlayColor: WidgetStateProperty.resolveWith((states) {
                      return Theme.of(context).primaryColor; }) ),
                      icon: Icon( Icons.save, size: 18, color: Theme.of(context).splashColor ),
                      onPressed: () async { 
                        globalFilter[viewID] = Filters(); // empty filter to refill with new
                        for (var filter in filterRowsWidget) {
                          if (filter.formKey.currentState == null || !filter.formKey.currentState!.validate()) { return; }
                          globalFilter[viewID]?.add(filter.beforeColumn.isNotEmpty ? filter.beforeColumn.first : filter.columnName ?? "", Filter(
                            column: filter.beforeColumn.isNotEmpty ? filter.beforeColumn.first : filter.columnName, label: filter.label ?? filter.columnName, realName: filter.beforeColumn.join("."),
                            type: filter.type, value: filter.value, index: filter.index, connector: filter.connector, comparator: filter.comparator));
                        }
                        noFilterRetrieval = true;
                        var body = { 
                          "link" : currentView?.schemaName,
                          "elder" : globalNew[viewID] ?? "all", 
                          "is_selected" : true, 
                          "filter_fields" : globalFilter[viewID]?.serialize() 
                        }; 
                        if (currentView == null) { return; }
                        try {
                          if (viewID != null && filterRestr[viewID] != null && filterRestr[viewID] != "") {
                            throw Exception();
                          }
                          if (int.parse(filterRestr[viewID]!) > 0) {
                            APIService().put<model.Shallowed>(currentView!.filterPath.replaceAll("rows=all", "rows=${filterRestr[viewID]}"), body, context);
                          }
                        } catch(e) {
                          body["name"] = filterRestr[viewID] ?? "";
                          APIService().post<model.Shallowed>(currentView!.filterPath, body, context).then((value) {
                            Future.delayed(Duration(milliseconds: 500), () {
                              setState(() { 
                                try {
                                  filterRestr[viewID] = "${value.data?.first.id}";
                                } catch(e) {}
                                forceFilter = true;
                                check = true;
                                refreshFilter(value.data != null && value.data!.isNotEmpty ? value.data![0].fields : []);
                                setState(() { });
                              }); 
                            });
                          });
                        }
                      })) : Container(),
                    filterRestr[viewID] != null && filterRestr[viewID] != "" ? Padding(padding: const EdgeInsets.only(right: 5), 
                    child: FilterSelectorButtonWidget(parent: this, tooltip: await getOnFlow(TranslateConstants.filterDeleteT), icon: Icons.delete,
                    showDialog: "delete filter", 
                    function: () async {
                      removeFilter(); 
                      confirmCache = {};
                      var id = filterRestr[viewID];
                      filterRestr[viewID] = ""; 
                      globalFilter.remove(viewID);
                      try {
                        if (int.parse(filterRestr[viewID]!) > 0) {
                          await APIService().delete(currentView!.filterPath.replaceAll("rows=all", "rows=$id"), context).then((value) {
                          forceFilter = true; 
                         });
                        } 
                      } catch(e) { }
                    })) : Container() ,
                    currentView!.filterPath != "" ? FutureBuilder(future: APIService().get<model.Shallowed>("${currentView!.filterPath}&is_view=false", firstAPI || forceFilter, null), 
                      builder: (BuildContext context, AsyncSnapshot<APIResponse<model.Shallowed>> snapshot) {
                      forceFilter = false;
                      if (snapshot.data?.data != null) {
                        return SubFilterSelectorWidget( state: this, filterMain: widget.filterMain, schema: widget.schema, datas: snapshot.data?.data);
                      }
                      return SubFilterSelectorWidget(  state: this,  filterMain: widget.filterMain, schema: widget.schema, datas: []);
                    }) : Container(), 
                    Padding(padding: const EdgeInsets.only(left: 5), 
                    child: IconButton( constraints: const BoxConstraints(), tooltip: (await getOnFlow(TranslateConstants.filterNew)).toLowerCase(), 
                    style: ButtonStyle( overlayColor: WidgetStateProperty.resolveWith((states) {
                      return Theme.of(context).primaryColor; }), ),
                      icon: Icon( Icons.add, size: 17, color: Theme.of(context).highlightColor, ),
                      onPressed: () { 
                        showMore = true;
                        confirmCache = {};
                        filterRowsWidget.add(FilterRowWidget(schema: widget.schema, index: filterRowsWidget.length)); 
                        globalGridKey.currentState?.setState(() { });
                        setState(() { });
                      })),
                    if (filterRowsWidget.length > 1)
                      Padding(padding: const EdgeInsets.only(left: 5), 
                      child: IconButton( constraints: const BoxConstraints(), tooltip: (await getOnFlow(TranslateConstants.filterRM)).toLowerCase(), 
                      style: ButtonStyle( overlayColor: WidgetStateProperty.resolveWith((states) {
                        return Theme.of(context).primaryColor; }), ),
                        icon: Icon( Icons.remove, size: 17, color: Theme.of(context).highlightColor, ),
                        onPressed: () { 
                          showMore = true;
                          confirmCache = {};
                          filterRowsWidget.removeLast(); 
                          globalGridKey.currentState?.setState(() { });
                          setState(() { });
                        })),
                    if (filterRowsWidget.isNotEmpty)
                      Padding(padding: const EdgeInsets.only(left: 5), 
                      child: FilterSelectorButtonWidget(function: () async {
                        if (filterRestr[viewID] == null) { filterRestr[viewID] = ""; }
                          globalFilter[viewID] = Filters(); // empty filter to refill with new
                          for (var filter in filterRowsWidget) {
                            if (filter.formKey.currentState == null || !filter.formKey.currentState!.validate()) {
                              return; 
                            }
                            globalFilter[viewID]?.add("${filter.beforeColumn.isNotEmpty ? filter.beforeColumn.first : filter.columnName}", Filter(
                              column: filter.beforeColumn.isNotEmpty ? filter.beforeColumn.first : filter.columnName, 
                              realName: filter.beforeColumn.join("."),
                              label: filter.label ?? filter.columnName,
                              type: filter.type, 
                              value: filter.value, 
                              index: filter.index, 
                              connector: filter.connector, 
                              comparator: filter.comparator));
                          }
                          noFilterRetrieval = true;
                          confirmCache = {};
                      }, icon: Icons.check, tooltip: await getOnFlow(TranslateConstants.filterApplyT), parent: this)),
                    filterRowsWidget.isNotEmpty || (filterRestr[viewID] != null && filterRestr[viewID] != "" ) || (globalNew[viewID] != null && globalNew[viewID] != "all") ? Padding(padding: const EdgeInsets.only(left: 5), 
                    child: FilterSelectorButtonWidget(function: () async {
                        removeFilter();
                        filterRestr[viewID] = ""; 
                        confirmCache = {};
                        await APIService().put<model.Shallowed>(currentView!.filterPath.replaceAll("rows=all", "rows=${filterRestr[viewID]}"), 
                          <String, dynamic> { "is_selected" : false }, null);
                      }, icon: Icons.filter_alt_off, tooltip: await getOnFlow(TranslateConstants.filterResetT), parent: this)) : Container(),
                      Padding(padding: const EdgeInsets.only(left: 10), 
                        child: FutureBuilder(future: getLabels(toggles), builder: (a,s) {
                          if (s.data != null) {
                            return ToggleSwitch( labels: s.data, minHeight: 27.5, minWidth: 90, fontSize: 12, cornerRadius: 5,
                              initialLabelIndex: toggles.indexWhere((element) => element.toLowerCase() == globalNew[viewID]?.toLowerCase()),
                              dividerColor: Colors.white, inactiveFgColor: Theme.of(context).splashColor,
                              totalSwitches: toggles.length, inactiveBgColor: Theme.of(context).secondaryHeaderColor,
                              onToggle: (index) { 
                                if (globalNew[viewID] == toggles[index ?? 0] || index == null) {
                                  globalNew[viewID]="all";
                                } else {
                                  globalNew[viewID] = toggles[index]; 
                                }
                                confirmCache = {};
                                navigate = true;
                                globalMainViewKey.currentState?.setState(() {});
                              },
                            );
                          } else {
                            return ToggleSwitch( labels: toggles, minHeight: 27.5, minWidth: 90, fontSize: 12, cornerRadius: 5,
                              initialLabelIndex: toggles.indexWhere((element) => element.toLowerCase() == globalNew[viewID]?.toLowerCase()),
                              dividerColor: Colors.white, inactiveFgColor: Theme.of(context).splashColor,
                              totalSwitches: toggles.length, inactiveBgColor: Theme.of(context).secondaryHeaderColor,
                              onToggle: (index) { 
                                if (globalNew[viewID] == toggles[index ?? 0] || index == null) {
                                  globalNew[viewID]="all";
                                } else {
                                  globalNew[viewID] = toggles[index]; 
                                }
                                confirmCache = {};
                                resetList();
                              },
                            );
                          }
                        }),
                    )
                  ] )
              ) : Container(),
            Row( mainAxisAlignment: MainAxisAlignment.end, children : [ 
              Padding(padding: const EdgeInsets.symmetric(horizontal: 30), 
                child: FutureBuilder<List<Widget>>(future: getButtons(), builder: (a,s) {
                  if (s.data != null) {
                    return Row(children: [ 
                      ...s.data!, 
                      FilterColsPopUpWidget(key: filterColsPopUpKey, schema: widget.schema) 
                    ]);
                  }
                 return Row(children: [ 
                    FilterColsPopUpWidget(key: filterColsPopUpKey, schema: widget.schema) 
                 ]); 
              })) 
            ]) 
          ]), 
          Container( 
              constraints: BoxConstraints( 
                maxHeight:  (currentHeigth > (120 + subSize) ? subSize : currentHeigth - 120).toDouble()), 
              child: SingleChildScrollView( 
                child: Column( 
                  children : [  
                    modeIndex != 1 ? (filterRowsWidget.isEmpty ?  Container() 
                    : Divider(height: 1, color: Theme.of(context).secondaryHeaderColor)) : ( 
                  editMode[viewID] != "math" || functionMathRowsWidget.isEmpty ? 
                  Container() : Divider(height: 1, color: Theme.of(context).secondaryHeaderColor)
                ),  
              ...(showMore ? filterRowsWidget :  []) ,
              ...(editMode[viewID] == "math" ? functionMathRowsWidget : [])
            ] 
          )))
    ]);
  }
  Future<void> resetList() async {
    var defaultPath = viewID != null ? "${APIConstants.genericEndpost}${subViewID != null ? viewID!.substring(1) : "dbview"}?rows=${subViewID != null ? "$subViewID" : viewID!.substring(1)}" : "";
    var e = await APIService().getWithOffset<model.View>(globalGridKey.currentState?.widget.view?.linkPath ?? defaultPath, true, context);
    globalGridKey.currentState?.widget.view?.items = [];
    for (var view in e.data ?? []) { 
      globalGridKey.currentState?.widget.view?.max = view?.max;
      for (var item in view.items) { 
        if ((globalGridKey.currentState?.widget.view?.items.where((element) => element.values['id'] == item.values['id']) ?? []).isEmpty) { 
          globalGridKey.currentState?.widget.view?.items.add(item); 
        }
      }
    }
    Future.delayed(Duration(seconds: 1), () {
      globalActionBar.currentState?.setState(() {
        globalActionBar.currentState?.widget.view = globalGridKey.currentState?.widget.view;
      });
    }); 
    confirmCache = {};
    globalGridKey.currentState?.setState(() { });
    setState(() { });
  }

  Future<List<String>> getLabels(List<String> toogles) async {
    List<String> labels = [];
    for (var t in toogles) {
      labels.add(await getOnFlow(t));
    }
    return labels;
  }
}

// ignore: must_be_immutable
class SubFilterSelectorWidget extends StatefulWidget {
  List<model.Shallowed>? datas;
  FilterSelectorWidgetState state;
  Filters? filterMain;
  Map<String, model.SchemaField> schema = {};
  SubFilterSelectorWidget ({ super.key, 
  required this.filterMain, 
  required this.state,
  required this.schema, 
  required this.datas});
  @override SubFilterSelectorWidgetState createState() => SubFilterSelectorWidgetState();
}
class SubFilterSelectorWidgetState extends State<SubFilterSelectorWidget> {
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
    List<DropdownItem<String>> dpItems = [];
    if (widget.datas != null) { 
        for (var i in widget.datas!) { 
          if (dpItems.where((element) => element.value == i.id.toString()).isEmpty) {
            dpItems.add( DropdownItem<String>(value: "${i.id}", label: i.label!, selected: (filterRestr[viewID] == "" ? null : filterRestr[viewID]) == "${i.id}"));
            ctrls.addItem(dpItems.last);
          }
          if ((i.selected && ( widget.filterMain == null || widget.filterMain!.isEmpty) && filterRestr[viewID] != ""
            && filterRestr[viewID] != null && !noFilterRetrieval)
            || (filterRowsWidget.isEmpty && i.fields.isNotEmpty && filterRestr[viewID] != "" && filterRestr[viewID] != null)) { 
              globalNew[viewID] = i.elder;
              refreshFilter(i.fields);
              check = true;
              widget.state.setState(() { });
            }
        }
      } 
      if ( (filterRestr[viewID] ?? "") != "" && dpItems.where((element) => element.value == filterRestr[viewID] ).isEmpty) {
        try {
          dpItems.add( DropdownItem<String>(value: filterRestr[viewID]!, label: filterRestr[viewID]!, selected: true));
          ctrls.addItem(dpItems.last);
        } catch(e) { }
        
      }
      return Container(
        padding: EdgeInsets.only(left: 10),
        height: 25,  
        width: (MediaQuery.of(context).size.width - menuSize) / 3, 
        child: MultiDropdown<String>(
        label: "drp",
        addFunction: (String value) {
          for (var e in ctrls.items) {
            e.selected = false;
          }
          filterRestr[viewID] = value; 
          if (ctrls.items.where( (i) => i.value.toString() == value).isEmpty) {
            ctrls.addItem(DropdownItem<String>(value: value, label: value, selected: true));
          }
          ctrls.openDropdown("", value, true);
          setState(() {});
        },
        controller: ctrls,
        singleSelect: true,
        items: dpItems,
        forceVerticalAlignment: true,
        textAlignVertical: TextAlignVertical.center,
        searchEnabled: true,
        style: TextStyle( color: Colors.white ),
        chipDecoration: ChipDecoration(
                          backgroundColor: Theme.of(context).primaryColor,
                          labelStyle: TextStyle(color: Colors.white),
                          wrap: true,
                          runSpacing: 2,
                          spacing: 10,
        ),
        fieldDecoration: FieldDecoration(
          padding: kIsWeb ? EdgeInsets.only(left: 12, right: 12, top: 12) : EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          errorBorder: OutlineInputBorder(borderSide: BorderSide(color:Colors.red, width: 1.0)),
          disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).splashColor, width: 1.0)),
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          labelStyle: TextStyle(fontSize: 0),
          hintText: (await getOnFlow("select a saved filter")).toLowerCase(),
          hintStyle: TextStyle(fontSize: 13, color:Theme.of(context).splashColor, fontWeight: FontWeight.w300),
          prefixIcon: Icon(Icons.list, color: Theme.of(context).splashColor),
          showClearIcon: false,
          border:  OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor, width: 1.0)),
          focusedBorder:  OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor, width: 1.0)),
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
            onSelectionChange: (values) {
              try {
                if (values.isEmpty)  { return; }
                noFilterRetrieval = false;
                filterRestr[viewID] = values[0]; 
                if ( int.parse(values[0]) > 0) {
                  APIService().put<model.Shallowed>(currentView!.filterPath.replaceAll("rows=all", "rows=${values[0]}"), 
                    <String, dynamic> { "is_selected" : true }, null).then( (value) { 
                      check = true;
                      forceFilter = true;
                      refreshFilter(value.data != null && value.data!.isNotEmpty ? value.data![0].fields : []);
                      Future.delayed(Duration(seconds: 1), () {
                        widget.state.setState(() { });
                      });
                    }
                  );
                }
              } catch(e) { }
              },
            )
          );
  }
}

// ignore: must_be_immutable
class FilterSelectorButtonWidget extends StatefulWidget {
  FilterSelectorWidgetState parent;
  String tooltip;
  IconData icon;
  Future<void> Function() function;
  bool isLoading = false;
  String? showDialog;
  FilterSelectorButtonWidget ({ super.key, required this.parent, required this.tooltip, required this.icon, required this.function, this.showDialog,
});
  @override FilterSelectorButtonWidgetState createState() => FilterSelectorButtonWidgetState();
}
class FilterSelectorButtonWidgetState extends State<FilterSelectorButtonWidget> {
  @override Widget build(BuildContext context) {
    if (widget.isLoading) {
      return SpinKitCircle(color: Colors.white, size: 17.0 );
    }
    return IconButton( constraints: const BoxConstraints(), tooltip: widget.tooltip.toLowerCase(), 
                        style: ButtonStyle( overlayColor: WidgetStateProperty.resolveWith((states) { return Theme.of(context).primaryColor; }), ),
                        icon: Icon( widget.icon, size: 17, color: Theme.of(context).highlightColor ),
                        onPressed: () async {
                          if (widget.showDialog != null) {
                              showDialog(context: context, builder: (builder) => ConfirmBoxWidget(purpose: widget.showDialog!, validate: () async {
                                setState(() {
                                widget.isLoading = true;
                              });
                              await widget.function();
                              await widget.parent.resetList();
                              setState(() {
                                widget.isLoading = false;
                              });
                            }));
                            return;
                          }
                          setState(() {
                            widget.isLoading = true;
                          });
                          await widget.function();
                          await widget.parent.resetList();
                          setState(() {
                            widget.isLoading = false;
                          });
                        });
  }
}