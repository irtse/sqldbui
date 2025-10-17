

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
    var toggles = ["new", "old", "draft"];
    return Row( children: [ 
      Padding( 
        padding: const EdgeInsets.only(right: 10), 
        child : Tooltip( 
          message : (await getOnFlow(showMore ? TranslateConstants.filterHide.toLowerCase() : TranslateConstants.filterShow)).toLowerCase(),
          child: InkWell( 
            child : Icon( showMore ? Icons.filter_alt : Icons.filter_alt_outlined, 
              color: showMore ? Colors.white : Theme.of(context).splashColor, size: 20), 
            onTap: () { 
              confirmCache = {};
              navigate = true;
              globalMainViewKey.currentState?.setState(() { showMore = !showMore; }); }
          )),
        ),
        filterRowsWidget.isNotEmpty ? Container(
          margin: const EdgeInsets.only(right: 5), 
          padding: const EdgeInsets.only(left: 5), 
          child:  IconButton( constraints: const BoxConstraints(), tooltip: (await getOnFlow(TranslateConstants.filterSaveT)).toLowerCase(), 
          style: ButtonStyle( overlayColor: WidgetStateProperty.resolveWith((states) {
          return Theme.of(context).primaryColor; }) ),
          icon: Icon( Icons.save, size: 18, color: Theme.of(context).splashColor, ),
          onPressed: () async { 
            globalFilter[viewID] = Filters(); // empty filter to refill with new
            for (var filter in filterRowsWidget) {
              if (filter.formKey.currentState == null || !filter.formKey.currentState!.validate()) { return; }
              globalFilter[viewID]?.add(filter.beforeColumn.isNotEmpty ? filter.beforeColumn.first : filter.columnName ?? "", Filter(
                column: filter.beforeColumn.isNotEmpty ? filter.beforeColumn.first : filter.columnName, label: filter.label ?? filter.columnName, realName: filter.beforeColumn.join("."),
                type: filter.type, value: filter.value, index: filter.index, connector: filter.connector, comparator: filter.comparator));
            }
            noFilterRetrieval = true;
            var body = { "link" : currentView?.schemaName,
              "elder" : globalNew[viewID] ?? "all", "is_selected" : true, "filter_fields" : globalFilter[viewID]?.serialize() }; 
            if (currentView == null) { return; }
            (viewID != null && filterRestr[viewID] != null && filterRestr[viewID] != "" ? 
            APIService().put<model.Shallowed>(currentView!.filterPath.replaceAll("rows=all", "rows=${filterRestr[viewID]}"), body, context) :
            APIService().post<model.Shallowed>(currentView!.filterPath, body, context)).then((value) {
              Future.delayed(Duration(seconds: 1), () {
                setState(() { 
                  try {
                    filterRestr[viewID] = "${value.data?.first.id}";
                  } catch(e) {}
                  forceFilter = true;
                  refreshFilter(value.data != null && value.data!.isNotEmpty ? value.data![0].fields : []); 
                  navigate = true;
                  confirmCache = {};
                  globalMainViewKey.currentState?.setState(() { });
                }); 
              });
            });
          })) : Container(),
        filterRestr[viewID] != null && filterRestr[viewID] != "" ? Padding(padding: const EdgeInsets.only(right: 5), 
        child: IconButton( constraints: const BoxConstraints(), 
        tooltip: (await getOnFlow(TranslateConstants.filterDeleteT)).toLowerCase(), style: ButtonStyle( overlayColor: WidgetStateProperty.resolveWith((states) {
          return Theme.of(context).primaryColor; }), ),
          icon: Icon(Icons.delete, size: 18, color: Theme.of(context).splashColor, ),
          onPressed: () { 
            showDialog(context: context, builder: (builder) => ConfirmBoxWidget(purpose: "delete filter", validate: () {
                removeFilter(); 
                navigate = true;
                confirmCache = {};
                var id = filterRestr[viewID];
                filterRestr[viewID] = ""; 
                APIService().delete(currentView!.filterPath.replaceAll("rows=all", "rows=$id"), context).then((value) {
                  forceFilter = true; 
                  setState(() {});
                  globalMainViewKey.currentState?.setState(() { }); });
              }));
            })) : Container() ,
        currentView!.filterPath != "" ? FutureBuilder(future: APIService().get<model.Shallowed>("${currentView!.filterPath}&is_view=false", firstAPI || forceFilter, null), 
          builder: (BuildContext context, AsyncSnapshot<APIResponse<model.Shallowed>> snapshot) {
          forceFilter = false;
          if (snapshot.data?.data != null) {
            return SubFilterSelectorWidget( filterMain: widget.filterMain, schema: widget.schema, datas: snapshot.data?.data);
          }
          return SubFilterSelectorWidget( filterMain: widget.filterMain, schema: widget.schema, datas: []);
        }) : Container(), 
        Padding(padding: const EdgeInsets.only(left: 5), 
        child: IconButton( constraints: const BoxConstraints(), tooltip: (await getOnFlow(TranslateConstants.filterNew)).toLowerCase(), 
        style: ButtonStyle( overlayColor: WidgetStateProperty.resolveWith((states) {
          return Theme.of(context).primaryColor; }), ),
          icon: Icon( Icons.add, size: 17, color: Theme.of(context).highlightColor, ),
          onPressed: () { 
            showMore = true;
            navigate = true;
            confirmCache = {};
            filterRestr.remove(viewID);
            filterRowsWidget.add(FilterRowWidget(schema: widget.schema, index: filterRowsWidget.length)); 
            globalMainViewKey.currentState?.setState(() { });
          })),
        if (filterRowsWidget.length > 1)
          Padding(padding: const EdgeInsets.only(left: 5), 
          child: IconButton( constraints: const BoxConstraints(), tooltip: (await getOnFlow(TranslateConstants.filterRM)).toLowerCase(), 
          style: ButtonStyle( overlayColor: WidgetStateProperty.resolveWith((states) {
            return Theme.of(context).primaryColor; }), ),
            icon: Icon( Icons.remove, size: 17, color: Theme.of(context).highlightColor, ),
            onPressed: () { 
              showMore = true;
              navigate = true;
              confirmCache = {};
              filterRestr.remove(viewID);
              filterRowsWidget.removeLast(); 
              globalMainViewKey.currentState?.setState(() { });
            })),
        if (filterRowsWidget.isNotEmpty)
          Padding(padding: const EdgeInsets.only(left: 5), 
          child: IconButton( constraints: const BoxConstraints(), tooltip: (await getOnFlow(TranslateConstants.filterApplyT)).toLowerCase(), 
            style: ButtonStyle( overlayColor: WidgetStateProperty.resolveWith((states) { return Theme.of(context).primaryColor; }), ),
            icon: Icon( Icons.check, size: 17, color: Theme.of(context).highlightColor ),
            onPressed: () {
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
              navigate = true;
              confirmCache = {};
              globalMainViewKey.currentState?.refresh(viewID, subViewID, null, true);
            })),
        filterRowsWidget.isNotEmpty || (filterRestr[viewID] != null && filterRestr[viewID] != "" ) || (globalNew[viewID] != null && globalNew[viewID] != "all") ? Padding(padding: const EdgeInsets.only(left: 5), 
        child: IconButton( constraints: const BoxConstraints(), 
        tooltip: (await getOnFlow(TranslateConstants.filterResetT)).toLowerCase(), 
        style: ButtonStyle( overlayColor: WidgetStateProperty.resolveWith((states) {
          return Theme.of(context).primaryColor; }), ),
          icon: Icon( Icons.filter_alt_off, size: 18, color: Theme.of(context).highlightColor ),
          onPressed: () async { 
            setState(() { });
            Future.delayed(const Duration(seconds: 1), 
              () {
                removeFilter();
                filterRestr[viewID] = ""; 
                navigate = true; 
                confirmCache = {};
                globalMainViewKey.currentState?.refresh(viewID, subViewID, null, true); 
              }); 
            
            APIService().put<model.Shallowed>(currentView!.filterPath.replaceAll("rows=all", "rows=${filterRestr[viewID]}"), 
              <String, dynamic> { "is_selected" : false }, null); })) : Container(),
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
                    navigate = true;
                    confirmCache = {};
                    globalMainViewKey.currentState?.refresh(viewID, subViewID, null, true);
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
                    navigate = true;
                    confirmCache = {};
                    globalMainViewKey.currentState?.refresh(viewID, subViewID, null, true);
                  },
                );
              }
            }),
        )
      ] );
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
  Filters? filterMain;
  Map<String, model.SchemaField> schema = {};
  SubFilterSelectorWidget ({ super.key, 
  required this.filterMain, 
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
    List<DropdownMenuItem<String>> dpItems = [];
    if (widget.datas != null) { 
            for (var i in widget.datas!) { 
              if (dpItems.where((element) => element.value == i.id.toString()).isEmpty) {
                dpItems.add( DropdownMenuItem<String>(value: "${i.id}", child: Text(await getOnFlow(i.label!), overflow: TextOverflow.ellipsis)));
              }
              if (i.selected && filterRestr[viewID] != "") { 
                filterRestr[viewID] = "${i.id}";                 
              }
              if ((i.selected && ( widget.filterMain == null || widget.filterMain!.isEmpty) && filterRestr[viewID] != ""
              && filterRestr[viewID] != null && !noFilterRetrieval)
              || (filterRowsWidget.isEmpty && i.fields.isNotEmpty && filterRestr[viewID] != "" && filterRestr[viewID] != null)) { 
                Future.delayed(const Duration(milliseconds: 500), () {
                  globalNew[viewID] = i.elder;
                  refreshFilter(i.fields);
                }); 
              }
              // if (filterRestr[viewID] == "") { filterRestr.remove(viewID); }
            }
          } 
          return SizedBox( height: 25, width: (currentWidth - menuSize) / 3, 
            child: DropdownButtonFormField<String>( 
                    items: dpItems, 
                    value: filterRestr[viewID] == "" ? null : filterRestr[viewID],
                    hint: Text((await getOnFlow(TranslateConstants.filterPlaceholder)).toLowerCase(), overflow: TextOverflow.ellipsis, 
                    style: TextStyle(color: Theme.of(context).splashColor)),
                    isExpanded: true, style: TextStyle(fontSize: 14, color: Theme.of(context).highlightColor),
                    onChanged: (value) async {
                      if (value == null) { return; }
                      noFilterRetrieval = false;
                      filterRestr[viewID] = value; 
                      APIService().put<model.Shallowed>(currentView!.filterPath.replaceAll("rows=all", "rows=$value"), 
                        <String, dynamic> { "is_selected" : true }, null).then( 
                          (value) => setState(() { 
                            forceFilter = true;
                            refreshFilter(value.data != null && value.data!.isNotEmpty ? value.data![0].fields : []);
                            navigate = true;
                            confirmCache = {};
                            globalMainViewKey.currentState?.setState(() { });
                          }));
                    }, dropdownColor: Theme.of(context).secondaryHeaderColor,
                    decoration: InputDecoration(
                      suffixIconColor: Theme.of(context).primaryColor,  errorStyle: const TextStyle(height: -2),
                      floatingLabelBehavior: FloatingLabelBehavior.always, filled: true,
                      labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor, width: 1.0)),
                      fillColor: (Theme.of(context).secondaryHeaderColor),  hintStyle: TextStyle(fontSize: 10, color: Theme.of(context).splashColor),
                      border: const OutlineInputBorder(), contentPadding: const EdgeInsets.only(top: 12, left: 20.0, right: 20.0),
                    ),
                    validator: (String? value) { return null; }
                  ));
  }
}