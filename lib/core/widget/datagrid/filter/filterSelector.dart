

import 'package:sqldbui2/main.dart';
import 'package:flutter/material.dart';
import 'package:sqldbui2/model/filter.dart';
import 'package:sqldbui2/model/response.dart';
import 'package:sqldbui2/core/sections/menu/menu.dart';
import 'package:sqldbui2/page/translate.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:sqldbui2/core/sections/view.dart';
import 'package:sqldbui2/model/view.dart' as model;
import 'package:sqldbui2/core/services/api_service.dart';
import 'package:sqldbui2/core/widget/datagrid/datagrid.dart';
import 'package:sqldbui2/core/widget/dialog/confirm_box.dart';
import 'package:sqldbui2/core/widget/datagrid/filter/filterRow.dart';

// ignore: must_be_immutable
class FilterSelectorWidget extends StatefulWidget {
  Filters? filterMain;
  Map<String, model.SchemaField> schema = {};
  List<DropdownMenuItem<String>> dpItems = [];
  FilterSelectorWidget ({ super.key, required this.dpItems, required this.filterMain, 
  required this.schema
});
  @override FilterSelectorWidgetState createState() => FilterSelectorWidgetState();
}
class FilterSelectorWidgetState extends State<FilterSelectorWidget> {
  @override Widget build(BuildContext context) {
    var toggles = ["all", "new", "old"];
    return Row( children: [ 
      Padding( 
        padding: const EdgeInsets.only(right: 10), 
        child : Tooltip( 
          message: show ? TranslateConstants.filterHide.toLowerCase() : TranslateConstants.filterShow.toLowerCase(),
          child: InkWell( 
            child : Icon( show ? Icons.filter_alt : Icons.filter_alt_outlined, 
              color: show ? Colors.white : Theme.of(context).splashColor, size: 20), 
            onTap: () { globalMainViewKey.currentState?.setState(() { show = !show; }); }
          )),
        ),
        filterRowsWidget.isNotEmpty ? Padding(
          padding: const EdgeInsets.only(left: 5), 
          child:  IconButton( constraints: const BoxConstraints(), tooltip: TranslateConstants.filterSaveT.toLowerCase(), 
          style: ButtonStyle( overlayColor: WidgetStateProperty.resolveWith((states) {
          return Theme.of(context).primaryColor; }), ),
          icon: Icon( Icons.save, size: 18, color: Theme.of(context).splashColor, ),
          onPressed: () async { 
            globalFilter[viewID] = Filters(); // empty filter to refill with new
            for (var filter in filterRowsWidget) {
              if (filter.formKey.currentState == null || !filter.formKey.currentState!.validate()) { return; }
              globalFilter[viewID]?.add(filter.columnName ?? "", Filter(
                column: filter.columnName, label: filter.label ?? filter.columnName,
                type: filter.type, value: filter.value, index: filter.index, connector: filter.connector, comparator: filter.comparator));
            }
            noFilterRetrieval = true;
            var body = { "link" : currentView?.schemaName, "elder" : globalNew[viewID] ?? "all", "is_selected" : true, "filter_fields" : globalFilter[viewID]?.serialize() }; 
            if (currentView == null) { return; }
            (viewID != null && filterRestr[viewID] != null ? APIService().put<model.Shallowed>(currentView!.filterPath.replaceAll("rows=all", "rows=${filterIDName[filterRestr[viewID]]}"), body, context) :
            APIService().post<model.Shallowed>(currentView!.filterPath, body, context)).then((value) => refreshFilter(value.data != null && value.data!.isNotEmpty ? value.data![0].fields : []));
          })) : Container(),
        filterRestr[viewID] != null && filterRestr[viewID] != "" ? Padding(padding: const EdgeInsets.only(left: 5), 
        child: IconButton( constraints: const BoxConstraints(), 
        tooltip: TranslateConstants.filterDeleteT.toLowerCase(), style: ButtonStyle( overlayColor: WidgetStateProperty.resolveWith((states) {
          return Theme.of(context).primaryColor; }), ),
          icon: Icon(Icons.delete, size: 18, color: Theme.of(context).splashColor, ),
          onPressed: () { 
            showDialog(context: context, builder: (builder) => ConfirmBoxWidget(purpose: "delete filter", validate: () {
                      globalMainViewKey.currentState?.setState(() { 
                        APIService().delete(currentView!.filterPath.replaceAll("rows=all", "rows=${filterIDName[filterRestr[viewID]]}"), context).then((value) {
                        removeFilter(); 
                        filterRestr[viewID] = ""; 
                         globalMainViewKey.currentState?.refresh(viewID, subViewID, null, true);
                      },); });
                    }));
              })) : Container() ,
        currentView!.filterPath != "" ? FutureBuilder(future: APIService().get<model.Shallowed>("${currentView!.filterPath}&is_view=false", true, null), 
          builder: (BuildContext context, AsyncSnapshot<APIResponse<model.Shallowed>> snapshot) {
          return SubFilterSelectorWidget(dpItems: widget.dpItems, filterMain: widget.filterMain, schema: widget.schema,
            datas: snapshot.data?.data);
        }) : Container(), 
        filterRowsWidget.isEmpty ? Padding(padding: const EdgeInsets.only(left: 5), 
        child: IconButton( constraints: const BoxConstraints(), tooltip: TranslateConstants.filterNew.toLowerCase(), 
        style: ButtonStyle( overlayColor: WidgetStateProperty.resolveWith((states) {
          return Theme.of(context).primaryColor; }), ),
          icon: Icon( Icons.add, size: 17, color: Theme.of(context).highlightColor, ),
          onPressed: () { 
            show = true;
            filterRestr.remove(viewID);
            filterRowsWidget.add(FilterRowWidget(schema: widget.schema, index: filterRowsWidget.length)); 
            globalMainViewKey.currentState?.setState(() { });
          })) 
        : Padding(padding: const EdgeInsets.only(left: 5), 
        child: IconButton( constraints: const BoxConstraints(), tooltip: TranslateConstants.filterApplyT.toLowerCase(), 
          style: ButtonStyle( overlayColor: WidgetStateProperty.resolveWith((states) { return Theme.of(context).primaryColor; }), ),
          icon: Icon( Icons.check, size: 17, color: Theme.of(context).highlightColor, ),
          onPressed: () {
            if (filterRestr[viewID] == null) { filterRestr[viewID] = ""; }
            globalFilter[viewID] = Filters(); // empty filter to refill with new
            for (var filter in filterRowsWidget) {
              if (filter.formKey.currentState == null || !filter.formKey.currentState!.validate()) { return; }
              globalFilter[viewID]?.add(filter.columnName ?? "", Filter(column: filter.columnName, label: filter.label ?? filter.columnName,
                type: filter.type, value: filter.value, index: filter.index, connector: filter.connector, comparator: filter.comparator));
            }
            noFilterRetrieval = true;
            globalMainViewKey.currentState?.refresh(viewID, subViewID, null, true);
          })),
        filterRowsWidget.isNotEmpty || (filterRestr[viewID] != null && filterRestr[viewID] != "" ) || (globalNew[viewID] != null && globalNew[viewID] != "all") ? Padding(padding: const EdgeInsets.only(left: 5), 
        child: IconButton( constraints: const BoxConstraints(), 
        tooltip: TranslateConstants.filterResetT.toLowerCase(), 
        style: ButtonStyle( overlayColor: WidgetStateProperty.resolveWith((states) {
          return Theme.of(context).primaryColor; }), ),
          icon: Icon( Icons.filter_alt_off, size: 18, color: Theme.of(context).highlightColor ),
          onPressed: () async { 
            removeFilter();
            if (filterRestr[viewID] == null || filterRestr[viewID] == "") { 
              filterRestr[viewID] = ""; 
              return Future.delayed(const Duration(seconds: 1), 
                () => globalMainViewKey.currentState?.refresh(viewID, subViewID, null, true)); 
            }
            APIService().put<model.Shallowed>(currentView!.filterPath.replaceAll("rows=all", "rows=${filterIDName[filterRestr[viewID]]}"), <String, dynamic> { "is_selected" : false }, null).then((value) {
              filterRestr[viewID] = "";
              Future.delayed(const Duration(seconds: 1), 
                () => globalMainViewKey.currentState?.refresh(viewID, subViewID, null, true));
          }); })) : Container(),
          Padding(padding: const EdgeInsets.only(left: 10), 
            child: ToggleSwitch( labels: toggles, minHeight: 27.5, minWidth: 60, fontSize: 12, cornerRadius: 5,
                initialLabelIndex: toggles.indexWhere((element) => element.toLowerCase() == globalNew[viewID]?.toLowerCase()),
                dividerColor: Colors.white, inactiveFgColor: Theme.of(context).splashColor,
                totalSwitches: toggles.length, inactiveBgColor: Theme.of(context).secondaryHeaderColor,
                onToggle: (index) { 
                    globalNew[viewID] = toggles[index ?? 0]; 
                    globalMainViewKey.currentState?.refresh(viewID, subViewID, null, true);
                  },
              ),
        )
      ] );
  }
}

// ignore: must_be_immutable
class SubFilterSelectorWidget extends StatefulWidget {
  List<model.Shallowed>? datas;
  Filters? filterMain;
  Map<String, model.SchemaField> schema = {};
  List<DropdownMenuItem<String>> dpItems = [];
  SubFilterSelectorWidget ({ super.key, required this.dpItems, required this.filterMain, 
  required this.schema, required this.datas});
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
    if (widget.datas != null) { 
            for (var i in widget.datas!) { 
              if (widget.dpItems.where((element) => element.value == i.label).isEmpty) {
                widget.dpItems.add(
                  DropdownMenuItem<String>(value: i.label, child: Text(await getOnFlow(i.label!), overflow: TextOverflow.ellipsis)));
              }
              filterIDName[i.label!] = i.id!;
              if (i.selected && filterRestr[viewID] != "") { 
                filterRestr[viewID] = i.label!;                 
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
                    items: widget.dpItems, value: filterRestr[viewID] == "" ? null : filterRestr[viewID],
                    hint: Text(TranslateConstants.filterPlaceholder.toLowerCase(), overflow: TextOverflow.ellipsis, 
                    style: TextStyle(color: Theme.of(context).splashColor)),
                    isExpanded: true, style: TextStyle(fontSize: 14, color: Theme.of(context).highlightColor),
                    onChanged: (value) async {
                      if (value == null) { return; }
                      noFilterRetrieval = false;
                      filterRestr[viewID] = value; 
                      APIService().put<model.Shallowed>(currentView!.filterPath.replaceAll("rows=all", "rows=${filterIDName[value]}"), 
                        <String, dynamic> { "is_selected" : true }, null).then( (value) => refreshFilter(value.data != null && value.data!.isNotEmpty ? value.data![0].fields : []));
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